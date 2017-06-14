////
///  ProfileService.swift
//

import Moya
import SwiftyJSON
import PromiseKit


struct ProfileService {
    typealias UploadSuccess = (URL, User)
    typealias UploadBothSuccess = (URL?, URL?, User)

    func loadCurrentUser() -> Promise<User> {
        return ElloProvider.shared.request(.currentUserProfile)
            .then { response -> User in
                guard let user = response.0 as? User else {
                    throw NSError.uncastableJSONAble()
                }
                return user
            }
    }

    func updateUserProfile(_ content: [String: Any]) -> Promise<User> {
        return ElloProvider.shared.request(.profileUpdate(body: content))
            .then { response -> User in
                guard let user = response.0 as? User else {
                    throw NSError.uncastableJSONAble()
                }
                return user
            }
    }

    func updateUserCoverImage(_ image: ImageRegionData, properties: [String: Any] = [:]) -> Promise<UploadSuccess> {
        return updateUserImage(image, key: "remote_cover_image_url", properties: properties)
            .then { (url, user) -> UploadSuccess in
                user.updateDefaultImages(avatarURL: nil, coverImageURL: url)
                TemporaryCache.save(.coverImage, image: image.image)
                return (url, user)
            }
    }

    func updateUserAvatarImage(_ image: ImageRegionData, properties: [String: Any] = [:]) -> Promise<UploadSuccess> {
        return updateUserImage(image, key: "remote_avatar_url", properties: properties)
            .then { (url, user) -> UploadSuccess in
                user.updateDefaultImages(avatarURL: url, coverImageURL: nil)
                TemporaryCache.save(.avatar, image: image.image)
                return (url, user)
            }
    }

    func updateUserImages(
        avatarImage: ImageRegionData?,
        coverImage: ImageRegionData?,
        properties: [String: Any] = [:])
        -> Promise<UploadBothSuccess>
    {
        var avatarURL: URL?
        var coverImageURL: URL?
        var error: Swift.Error?
        let (promise, fulfill, reject) = Promise<UploadBothSuccess>.pending()

        let bothImages = after(2) {
            if let error = error {
                reject(error)
            }
            else {
                var mergedProperties: [String: Any] = properties

                if let avatarImage = avatarImage, let avatarURL = avatarURL {
                    TemporaryCache.save(.avatar, image: avatarImage.image)
                    mergedProperties["remote_avatar_url"] = avatarURL.absoluteString
                }

                if let coverImage = coverImage, let coverImageURL = coverImageURL {
                    TemporaryCache.save(.coverImage, image: coverImage.image)
                    mergedProperties["remote_cover_image_url"] = coverImageURL.absoluteString
                }

                self.updateUserProfile(mergedProperties)
                    .then { user -> UploadBothSuccess in
                        user.updateDefaultImages(avatarURL: avatarURL, coverImageURL: coverImageURL)
                        return (avatarURL, coverImageURL, user)
                    }
                    .then(execute: fulfill)
                    .catch(execute: reject)
            }
        }

        if let avatarImage = avatarImage {
            S3UploadingService().upload(imageRegionData: avatarImage)
                .then { url in
                    avatarURL = url as URL?
                }
                .catch { uploadError in
                    error = error ?? uploadError
                }
                .always { _ in
                    bothImages()
                }
        }
        else {
            bothImages()
        }

        if let coverImage = coverImage {
            S3UploadingService().upload(imageRegionData: coverImage)
                .then { url in
                    coverImageURL = url as URL?
                }
                .catch { uploadError in
                    error = error ?? uploadError
                }
                .always { _ in
                    bothImages()
                }
        }
        else {
            bothImages()
        }
        
        return promise
    }

    func updateUserDeviceToken(_ token: Data) -> Promise<Void> {
        log(comment: "push token", object: String(token.description.characters.filter { !"<> ".characters.contains($0) }))
        return ElloProvider.shared.request(.pushSubscriptions(token: token))
            .asVoid()
    }

    func removeUserDeviceToken(_ token: Data) -> Promise<Void> {
        return ElloProvider.shared.request(.deleteSubscriptions(token: token))
            .asVoid()
    }

    fileprivate func updateUserImage(
        _ image: ImageRegionData,
        key: String,
        properties: [String: Any])
        -> Promise<UploadSuccess>
    {
        return S3UploadingService().upload(imageRegionData: image)
            .then { url -> Promise<UploadSuccess> in
                guard let url = url else {
                    throw NSError.uncastableJSONAble()
                }

                let urlString = url.absoluteString
                let mergedProperties: [String: Any] = properties + [
                    key: urlString,
                ]

                return self.updateUserProfile(mergedProperties)
                    .then { user -> UploadSuccess in
                        return (url, user)
                    }
            }
    }

    func deleteAccount() -> Promise<Void> {
        return ElloProvider.shared.request(.profileDelete)
            .asVoid()
    }
}
