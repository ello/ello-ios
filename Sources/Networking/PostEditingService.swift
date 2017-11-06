////
///  PostEditingService.swift
//
// This service converts "raw" content (String, NSAttributedString, UIImage)
// into Regionables (TextRegion, ImageRegion) suitable for the API, and uploads
// or updates those.
//
// Retaining the index of each section is crucial, since the images are uploaded
// asynchronously, they could come back in any order.  In this context "entry"
// refers to the tuple of (index, Region) or (index, String/UIImage)

import PromiseKit


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


class PostEditingService {

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
    func create(content rawContent: [PostContentRegion], buyButtonURL: URL? = nil, artistInviteId: String? = nil) -> Promise<Any> {
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

        var indexedRegions: [(Int, Regionable)] = textEntries.map { (index, text) -> (Int, Regionable) in
            return (index, TextRegion(content: text))
        }

        if imageDataEntries.count > 0 {
            return uploadImages(imageDataEntries)
                .then { imageRegions -> Promise<Any> in
                    indexedRegions += imageRegions.map { entry in
                        let (index, region) = entry
                        return (index, region as Regionable)
                    }

                    return self.create(self.sortedRegions(indexedRegions), artistInviteId: artistInviteId)
                }
        }
        else {
            return create(sortedRegions(indexedRegions), artistInviteId: artistInviteId)
        }
    }

    func create(_ regions: [Regionable], artistInviteId: String?) -> Promise<Any> {
        var body: [[String: Any]] = []
        for region in regions {
            body.append(region.toJSON())
        }

        var params: [String: Any]  = ["body": body]
        if let artistInviteId = artistInviteId {
            params["artist_invite_id"] = artistInviteId
        }

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

        return ElloProvider.shared.request(endpoint)
            .then { response -> Any in
                let data = response.0
                let post: Any = data

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

                return post
            }
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
    func uploadImages(_ imageEntries: [(Int, ImageRegionData)]) -> Promise<[(Int, ImageRegion)]> {
        var uploaded = [(Int, ImageRegion)]()

        // if any upload fails, the entire post creationg fails
        var anyError: Error?

        let operationQueue = OperationQueue.main
        let (promise, resolve, reject) = Promise<[(Int, ImageRegion)]>.pending()

        let doneOperation = BlockOperation(block: {
            if let error = anyError {
                reject(error)
            }
            else {
                resolve(uploaded)
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

                let failureHandler: (Error) -> Void = { error in
                    anyError = error
                    done()
                }

                let uploadService = S3UploadingService()
                let promise: Promise<URL?>
                if let data = data, let contentType = contentType {
                    promise = uploadService.upload(data, contentType: contentType)
                }
                else {
                    promise = uploadService.upload(image)
                }

                promise
                    .then { url -> Void in
                        let imageRegion = ImageRegion(alt: nil)
                        imageRegion.url = url
                        imageRegion.buyButtonURL = buyButtonURL

                        if let url = url {
                            let asset: Asset
                            if let data = data {
                                asset = Asset(url: url, gifData: data, posterImage: image)
                            }
                            else {
                                asset = Asset(url: url, image: image)
                            }

                            ElloLinkedStore.shared.setObject(asset, forKey: asset.id, type: .assetsType)
                            imageRegion.addLinkObject("assets", key: asset.id, type: .assetsType)
                        }

                        uploaded.append((imageIndex, imageRegion))
                        done()

                    }
                    .catch(execute: failureHandler)
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
        return promise
    }

    // this happens just before create(regions:).  The original index of each
    // section has been stored in `entry.0`, and this is used to sort the
    // entries, and then the sorted regions are returned.
    private func sortedRegions(_ indexedRegions: [(Int, Regionable)]) -> [Regionable] {
        return indexedRegions.sorted { left, right in
            let (indexLeft, indexRight) = (left.0, right.0)
            return indexLeft < indexRight
        }.map { (index: Int, region: Regionable) -> Regionable in
            return region
        }
    }

}
