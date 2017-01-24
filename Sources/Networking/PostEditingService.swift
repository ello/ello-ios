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

func == (lhs: PostEditingService.PostContentRegion, rhs: PostEditingService.PostContentRegion) -> Bool {
    switch (lhs, rhs) {
    case let (.text(a), .text(b)):
        return a == b
    case let (.imageData(leftImage, leftData, _), .imageData(rightImage, rightData, _)):
        return leftImage == rightImage && leftData == rightData
    case let (.image(leftImage), .image(rightImage)):
        return leftImage == rightImage
    default:
        return false
    }
}


struct ImageRegionData {
    let image: UIImage
    let data: Data?
    let contentType: String?
    let buyButtonURL: URL?

    init(image: UIImage, buyButtonURL: URL? = nil) {
        self.image = image
        self.data = nil
        self.contentType = nil
        self.buyButtonURL = buyButtonURL
    }

    init(image: UIImage, data: Data, contentType: String, buyButtonURL: URL? = nil) {
        self.image = image
        self.data = data
        self.contentType = contentType
        self.buyButtonURL = buyButtonURL
    }
}

extension ImageRegionData: Equatable{}

func == (lhs: ImageRegionData, rhs: ImageRegionData) -> Bool {
    guard lhs.image == rhs.image else { return false }

    if let lhData = lhs.data, let rhData = rhs.data, let lhContentType = lhs.contentType, let rhContentType = rhs.contentType {
        return lhData == rhData && lhContentType == rhContentType
    }
    return true
}


class PostEditingService {
    // this can return either a Post or Comment
    typealias CreatePostSuccessCompletion = (_ post: AnyObject) -> Void
    typealias UploadImagesSuccessCompletion = ([(Int, ImageRegion)]) -> Void

    enum PostContentRegion {
        case text(String)
        case imageData(UIImage, Data, String)
        case image(UIImage)
    }

    var editPostId: String?
    var editComment: ElloComment?
    var parentPostId: String?

    convenience init(parentPostId postId: String) {
        self.init()
        parentPostId = postId
    }

    convenience init(editPostId postId: String) {
        self.init()
        editPostId = postId
    }

    convenience init(editComment comment: ElloComment) {
        self.init()
        editComment = comment
    }

    // rawSections is String or UIImage objects
    func create(content rawContent: [PostContentRegion], buyButtonURL: URL?, success: @escaping CreatePostSuccessCompletion, failure: @escaping ElloFailureCompletion) {
        var textEntries = [(Int, String)]()
        var imageDataEntries = [(Int, ImageRegionData)]()

        // if necessary, the rawSource should be converted to API-ready content,
        // e.g. entitizing Strings and adding HTML markup to NSAttributedStrings
        for (index, section) in rawContent.enumerated() {
            switch section {
            case let .text(text):
                textEntries.append((index, text))
            case let .image(image):
                imageDataEntries.append((index, ImageRegionData(image: image, buyButtonURL: buyButtonURL)))
            case let .imageData(image, data, type):
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

                self.create(self.sortedRegions(indexedRegions), success: success, failure: failure)
            }, failure: failure)
        }
        else {
            create(sortedRegions(indexedRegions), success: success, failure: failure)
        }
    }

    func create(_ regions: [Regionable], success: @escaping CreatePostSuccessCompletion, failure: @escaping ElloFailureCompletion) {
        let body = NSMutableArray(capacity: regions.count)
        for region in regions {
            body.add(region.toJSON())
        }
        let params = ["body": body]

        let endpoint: ElloAPI
        if let parentPostId = parentPostId {
            endpoint = ElloAPI.createComment(parentPostId: parentPostId, body: params)
        }
        else if let editPostId = editPostId {
            endpoint = ElloAPI.updatePost(postId: editPostId, body: params)
        }
        else if let editComment = editComment {
            endpoint = ElloAPI.updateComment(postId: editComment.postId, commentId: editComment.id, body: params)
        }
        else {
            endpoint = ElloAPI.createPost(body: params)
        }

        ElloProvider.shared.elloRequest(endpoint,
            success: { data, responseConfig in
                let post: AnyObject = data

                switch endpoint {
                case .createComment:
                    let comment = data as! ElloComment
                    comment.content = self.replaceLocalImageRegions(comment.content, regions: regions)
                case .createPost, .updatePost:
                    let post = data as! Post
                    post.content = self.replaceLocalImageRegions(post.content ?? [], regions: regions)
                default:
                    break
                }

                success(post as AnyObject)
            },
            failure: failure
        )
    }

    func replaceLocalImageRegions(_ content: [Regionable], regions: [Regionable]) -> [Regionable] {
        var replacedContent = content
        for (index, regionable) in content.enumerated() {
            if let replaceRegion = regions.safeValue(index) as? ImageRegion, regionable is ImageRegion
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
    func uploadImages(_ imageEntries: [(Int, ImageRegionData)], success: @escaping UploadImagesSuccessCompletion, failure: @escaping ElloFailureCompletion) {
        var uploaded = [(Int, ImageRegion)]()

        // if any upload fails, the entire post creationg fails
        var anyError: NSError?
        var anyStatusCode: Int?

        let operationQueue = OperationQueue.main
        let doneOperation = BlockOperation(block: {
            if let error = anyError {
                failure(error, anyStatusCode)
            }
            else {
                success(uploaded)
            }
        })
        var prevUploadOperation: Operation?

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
                if let data = data, let contentType = contentType {
                    uploadService.upload(data, contentType: contentType,
                        success: { url in
                            let imageRegion = ImageRegion(alt: nil)
                            imageRegion.url = url
                            imageRegion.buyButtonURL = buyButtonURL

                            if let url = url {
                                let asset = Asset(url: url, gifData: data, posterImage: image)

                                ElloLinkedStore.sharedInstance.setObject(asset, forKey: asset.id, type: .assetsType)
                                imageRegion.addLinkObject("assets", key: asset.id, type: .assetsType)
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
                                ElloLinkedStore.sharedInstance.setObject(asset, forKey: asset.id, type: .assetsType)
                                imageRegion.addLinkObject("assets", key: asset.id, type: .assetsType)
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
            uploadOperation.queuePriority = .low
            uploadOperation.qualityOfService = .background
            operationQueue.addOperation(uploadOperation)
            prevUploadOperation = uploadOperation
        }
        operationQueue.addOperation(doneOperation)
    }

    // this happens just before create(regions:).  The original index of each
    // section has been stored in `entry.0`, and this is used to sort the
    // entries, and then the sorted regions are returned.
    fileprivate func sortedRegions(_ indexedRegions: [(Int, Regionable)]) -> [Regionable] {
        return indexedRegions.sorted() { left, right in
            let (indexLeft, indexRight) = (left.0, right.0)
            return indexLeft < indexRight
        }.map() { (index: Int, region: Regionable) -> Regionable in
            return region
        }
    }

}
