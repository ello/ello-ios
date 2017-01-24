////
///  ProfileService.swift
//

import Moya
import SwiftyJSON

typealias AccountDeletionSuccessCompletion = () -> Void
typealias ProfileSuccessCompletion = (User) -> Void
typealias ProfileUploadSuccessCompletion = (URL, User) -> Void
typealias ProfileUploadBothSuccessCompletion = (URL?, URL?, User) -> Void

struct ProfileService {

    init(){}

    func loadCurrentUser(success: @escaping ProfileSuccessCompletion, failure: @escaping ElloFailureCompletion) {
        let endpoint: ElloAPI = .currentUserProfile
        ElloProvider.shared.elloRequest(endpoint,
            success: { (data, _) in
                if let user = data as? User {
                    success(user)
                }
                else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: failure )
    }

    func updateUserProfile(_ content: [String: AnyObject], success: @escaping ProfileSuccessCompletion, failure: @escaping ElloFailureCompletion) {
        ElloProvider.shared.elloRequest(ElloAPI.profileUpdate(body: content),
            success: { data, responseConfig in
                if let user = data as? User {
                    success(user)
                } else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: failure
        )
    }

    func updateUserCoverImage(
        _ image: ImageRegionData,
        properties: [String: AnyObject] = [:],
        success: @escaping ProfileUploadSuccessCompletion, failure: @escaping ElloFailureCompletion) {
        updateUserImage(image, key: "remote_cover_image_url", properties: properties, success: { (url, user) in
            user.updateDefaultImages(avatarURL: nil, coverImageURL: url)
            TemporaryCache.save(.coverImage, image: image.image)
            success(url, user)
        }, failure: failure)
    }

    func updateUserAvatarImage(
        _ image: ImageRegionData,
        properties: [String: AnyObject] = [:],
        success: @escaping ProfileUploadSuccessCompletion, failure: @escaping ElloFailureCompletion) {
        updateUserImage(image, key: "remote_avatar_url", properties: properties, success: { (url, user) in
            user.updateDefaultImages(avatarURL: url, coverImageURL: nil)
            TemporaryCache.save(.avatar, image: image.image)
            success(url, user)
        }, failure: failure)
    }

    func updateUserImages(
        avatarImage: ImageRegionData?,
        coverImage: ImageRegionData?,
        properties: [String: AnyObject] = [:],
        success: @escaping ProfileUploadBothSuccessCompletion,
        failure: @escaping ElloFailureCompletion
    ) {
        var avatarURL: URL?
        var coverImageURL: URL?
        var error: NSError?
        var statusCode: Int?
        let bothImages = after(2) {
            if let error = error {
                failure(error, statusCode)
            }
            else {
                var mergedProperties: [String: AnyObject] = properties

                if let avatarImage = avatarImage, let avatarURL = avatarURL {
                    TemporaryCache.save(.avatar, image: avatarImage.image)
                    mergedProperties["remote_avatar_url"] = avatarURL.absoluteString as AnyObject
                }

                if let coverImage = coverImage, let coverImageURL = coverImageURL {
                    TemporaryCache.save(.coverImage, image: coverImage.image)
                    mergedProperties["remote_cover_image_url"] = coverImageURL.absoluteString as AnyObject
                }

                self.updateUserProfile(mergedProperties, success: { user in
                    user.updateDefaultImages(avatarURL: avatarURL, coverImageURL: coverImageURL)
                    success(avatarURL, coverImageURL, user)
                }, failure: failure)
            }
        }

        if let avatarImage = avatarImage {
            S3UploadingService().upload(imageRegionData: avatarImage, success: { url in
                avatarURL = url as URL?
                bothImages()
            }, failure: { uploadError, uploadStatusCode in
                error = error ?? uploadError
                statusCode = statusCode ?? uploadStatusCode
                bothImages()
            })
        }
        else {
            bothImages()
        }

        if let coverImage = coverImage {
            S3UploadingService().upload(imageRegionData: coverImage, success: { url in
                coverImageURL = url as URL?
                bothImages()
            }, failure: { uploadError, uploadStatusCode in
                error = error ?? uploadError
                statusCode = statusCode ?? uploadStatusCode
                bothImages()
            })
        }
        else {
            bothImages()
        }
    }

    func updateUserDeviceToken(_ token: Data) {
        log(comment: "push token", object: String(token.description.characters.filter { !"<> ".characters.contains($0) }))
        ElloProvider.shared.elloRequest(ElloAPI.pushSubscriptions(token: token),
            success: { _, _ in })
    }

    func removeUserDeviceToken(_ token: Data) {
        ElloProvider.shared.elloRequest(ElloAPI.deleteSubscriptions(token: token),
            success: { _, _ in })
    }

    fileprivate func updateUserImage(_ image: ImageRegionData, key: String, properties: [String: AnyObject], success: @escaping ProfileUploadSuccessCompletion, failure: @escaping ElloFailureCompletion) {
        S3UploadingService().upload(imageRegionData: image, success: { url in
            guard let url = url else { return }

            let urlString = url.absoluteString
            let mergedProperties: [String: AnyObject] = properties + [
                key: urlString as AnyObject,
            ]
            self.updateUserProfile(mergedProperties, success: { user in
                success(url as URL, user)
            }, failure: failure)
        }, failure: failure)
    }

    func deleteAccount(success: @escaping AccountDeletionSuccessCompletion, failure: @escaping ElloFailureCompletion) {
        ElloProvider.shared.elloRequest(ElloAPI.profileDelete,
            success: { _, _ in success() },
            failure: failure)
    }
}
