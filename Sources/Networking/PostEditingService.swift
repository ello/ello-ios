//
//  PostEditingService.swift
//  Ello
//
//  Created by Colin Gray on 2/12/14.
//  Copyright (c) 2015 Ello. All rights reserved.
//
// This service converts "raw" content (String, NSAttributedString, UIImage)
// into Regionables (TextRegion, ImageRegion) suitable for the API, and uploads
// or updates those.
//
// Retaining the index of each section is crucial, since the images are uploaded
// asynchronously, they could come back in any order.  In this context "entry"
// refers to the tuple of (index, Region) or (index, String/UIImage)

import Foundation
import UIKit

public func == (lhs: PostEditingService.PostContentRegion, rhs: PostEditingService.PostContentRegion) -> Bool {
    switch (lhs, rhs) {
    case let (.Text(a), .Text(b)):
        return a == b
    case let (.ImageData(leftImage, leftData, _), .ImageData(rightImage, rightData, _)):
        return leftImage == rightImage && leftData == rightData
    case let (.Image(leftImage), .Image(rightImage)):
        return leftImage == rightImage
    default:
        return false
    }
}


public struct ImageRegionData {
    let image: UIImage
    let data: NSData?
    let contentType: String?
    let buyButtonURL: NSURL?

    public init(image: UIImage, buyButtonURL: NSURL? = nil) {
        self.image = image
        self.data = nil
        self.contentType = nil
        self.buyButtonURL = buyButtonURL
    }

    public init(image: UIImage, data: NSData, contentType: String, buyButtonURL: NSURL? = nil) {
        self.image = image
        self.data = data
        self.contentType = contentType
        self.buyButtonURL = buyButtonURL
    }
}

extension ImageRegionData: Equatable{}

public func == (lhs: ImageRegionData, rhs: ImageRegionData) -> Bool {
    guard lhs.image == rhs.image else { return false }

    if let lhData = lhs.data, rhData = rhs.data, lhContentType = lhs.contentType, rhContentType = rhs.contentType {
        return lhData == rhData && lhContentType == rhContentType
    }
    return true
}


public class PostEditingService: NSObject {
    // this can return either a Post or Comment
    typealias CreatePostSuccessCompletion = (post: AnyObject) -> Void
    typealias UploadImagesSuccessCompletion = ([(Int, ImageRegion)]) -> Void

    public enum PostContentRegion {
        case Text(String)
        case ImageData(UIImage, NSData, String)
        case Image(UIImage)
    }

    var editPost: Post?
    var editComment: ElloComment?
    var parentPost: Post?

    convenience init(parentPost post: Post) {
        self.init()
        parentPost = post
    }

    convenience init(editPost post: Post) {
        self.init()
        editPost = post
    }

    convenience init(editComment comment: ElloComment) {
        self.init()
        editComment = comment
    }

    // rawSections is String or UIImage objects
    func create(content rawContent: [PostContentRegion], buyButtonURL: NSURL?, success: CreatePostSuccessCompletion, failure: ElloFailureCompletion) {
        var textEntries = [(Int, String)]()
        var imageDataEntries = [(Int, ImageRegionData)]()

        // if necessary, the rawSource should be converted to API-ready content,
        // e.g. entitizing Strings and adding HTML markup to NSAttributedStrings
        for (index, section) in rawContent.enumerate() {
            switch section {
            case let .Text(text):
                textEntries.append((index, text))
            case let .Image(image):
                imageDataEntries.append((index, ImageRegionData(image: image, buyButtonURL: buyButtonURL)))
            case let .ImageData(image, data, type):
                imageDataEntries.append((index, ImageRegionData(image: image, data: data, contentType: type, buyButtonURL: buyButtonURL)))
            }
        }

        var indexedRegions: [(Int, Regionable)] = textEntries.map() { (index, text) -> (Int, Regionable) in
            return (index, TextRegion(content: text))
        }

        if imageDataEntries.count > 0 {
            uploadImages(imageDataEntries, success: { imageRegions in
                indexedRegions += imageRegions.map() { entry in
                    let (index, region) = entry
                    return (index, region as Regionable)
                }

                self.create(regions: self.sortedRegions(indexedRegions), success: success, failure: failure)
            }, failure: failure)
        }
        else {
            create(regions: sortedRegions(indexedRegions), success: success, failure: failure)
        }
    }

    func create(regions regions: [Regionable], success: CreatePostSuccessCompletion, failure: ElloFailureCompletion) {
        let body = NSMutableArray(capacity: regions.count)
        for region in regions {
            body.addObject(region.toJSON())
        }
        let params = ["body": body]

        let endpoint: ElloAPI
        if let parentPost = parentPost {
            endpoint = ElloAPI.CreateComment(parentPostId: parentPost.id, body: params)
        }
        else if let editPost = editPost {
            endpoint = ElloAPI.UpdatePost(postId: editPost.id, body: params)
        }
        else if let editComment = editComment {
            endpoint = ElloAPI.UpdateComment(postId: editComment.postId, commentId: editComment.id, body: params)
        }
        else {
            endpoint = ElloAPI.CreatePost(body: params)
        }

        ElloProvider.shared.elloRequest(endpoint,
            success: { data, responseConfig in
                let post: AnyObject = data

                switch endpoint {
                case .CreateComment:
                    let comment = data as! ElloComment
                    comment.content = self.replaceLocalImageRegions(comment.content, regions: regions)
                case .CreatePost, .UpdatePost:
                    let post = data as! Post
                    post.content = self.replaceLocalImageRegions(post.content ?? [], regions: regions)
                default:
                    break
                }

                success(post: post as AnyObject)
            },
            failure: failure
        )
    }

    func replaceLocalImageRegions(content: [Regionable], regions: [Regionable]) -> [Regionable] {
        var replacedContent = content
        for (index, regionable) in content.enumerate() {
            if let _ = regionable as? ImageRegion,
                replaceRegion = regions.safeValue(index) as? ImageRegion
            {
                replacedContent[index] = replaceRegion
            }
        }
        return replacedContent
    }

    // Each image is given its own "uploader", which will fetch new credentials
    // and thus a unique S3 storage bucket.
    //
    // Another way to upload the images would be to generate one AmazonCredentials
    // object, and pass that to the uploader.  The uploader would need to
    // generate unique image names in that case.
    func uploadImages(imageEntries: [(Int, ImageRegionData)], success: UploadImagesSuccessCompletion, failure: ElloFailureCompletion) {
        var uploaded = [(Int, ImageRegion)]()

        // if any upload fails, the entire post creationg fails
        var anyError: NSError?
        var anyStatusCode: Int?

        let operationQueue = NSOperationQueue.mainQueue()
        let doneOperation = NSBlockOperation(block: {
            if let error = anyError {
                failure(error: error, statusCode: anyStatusCode)
            }
            else {
                success(uploaded)
            }
        })
        var prevUploadOperation: NSOperation?

        for dataEntry in imageEntries {
            let uploadOperation = AsyncOperation(block: { done in
                if anyError != nil {
                    done()
                    return
                }

                let (imageIndex, imageRegionData) = dataEntry
                let (image, data, contentType, buyButtonURL) = (imageRegionData.image, imageRegionData.data, imageRegionData.contentType, imageRegionData.buyButtonURL)

                let failureHandler: ElloFailureCompletion = { error, statusCode in
                    anyError = error
                    anyStatusCode = statusCode
                    done()
                }

                let uploadService = S3UploadingService()
                if let data = data, contentType = contentType {
                    uploadService.upload(data, contentType: contentType,
                        success: { url in
                            let imageRegion = ImageRegion(alt: nil)
                            imageRegion.url = url
                            imageRegion.buyButtonURL = buyButtonURL

                            if let url = url {
                                let asset = Asset(url: url, gifData: data, posterImage: image)

                                ElloLinkedStore.sharedInstance.setObject(asset, forKey: asset.id, inCollection: MappingType.AssetsType.rawValue)
                                imageRegion.addLinkObject("assets", key: asset.id, collection: MappingType.AssetsType.rawValue)
                            }

                            uploaded.append((imageIndex, imageRegion))
                            done()
                        },
                        failure: failureHandler)
                }
                else {
                    uploadService.upload(image,
                        success: { url in
                            let imageRegion = ImageRegion(alt: nil)
                            imageRegion.url = url
                            imageRegion.buyButtonURL = buyButtonURL

                            if let url = url {
                                let asset = Asset(url: url, image: image)
                                ElloLinkedStore.sharedInstance.setObject(asset, forKey: asset.id, inCollection: MappingType.AssetsType.rawValue)
                                imageRegion.addLinkObject("assets", key: asset.id, collection: MappingType.AssetsType.rawValue)
                            }

                            uploaded.append((imageIndex, imageRegion))
                            done()
                        },
                        failure: failureHandler)
                }
            })

            doneOperation.addDependency(uploadOperation)
            if let prevUploadOperation = prevUploadOperation {
                uploadOperation.addDependency(prevUploadOperation)
            }
            uploadOperation.queuePriority = .Low
            uploadOperation.qualityOfService = .Background
            operationQueue.addOperation(uploadOperation)
            prevUploadOperation = uploadOperation
        }
        operationQueue.addOperation(doneOperation)
    }

    // this happens just before create(regions:).  The original index of each
    // section has been stored in `entry.0`, and this is used to sort the
    // entries, and then the sorted regions are returned.
    private func sortedRegions(indexedRegions: [(Int, Regionable)]) -> [Regionable] {
        return indexedRegions.sort() { left, right in
            let (indexLeft, indexRight) = (left.0, right.0)
            return indexLeft < indexRight
        }.map() { (index: Int, region: Regionable) -> Regionable in
            return region
        }
    }

}
