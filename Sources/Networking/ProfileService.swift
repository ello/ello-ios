////
///  ProfileService.swift
//

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

    func updateUserProfile(_ properties: [Profile.Property: Any]) -> Promise<User> {
        var content: [String: Any] = [:]
        for (key, value) in properties {
            content[key.rawValue] = value
        }
        return ElloProvider.shared.request(.profileUpdate(body: content))
            .then { response -> User in
                guard let user = response.0 as? User else {
                    throw NSError.uncastableJSONAble()
                }
                return user
            }
    }

    func updateUserImage(_ prop: Profile.Property, imageRegion: ImageRegionData) -> Promise<UploadSuccess> {
        guard prop == .coverImage || prop == .avatar else {
            return Promise<UploadSuccess>(error: NSError())
        }

        return updateUserImage(imageRegion, key: prop, properties: [:])
            .then { (url, user) -> UploadSuccess in
                if prop == .coverImage {
                    user.updateDefaultImages(avatarURL: nil, coverImageURL: url)
                }
                else if prop == .avatar {
                    user.updateDefaultImages(avatarURL: url, coverImageURL: nil)
                }

                if !imageRegion.isAnimatedGif {
                    TemporaryCache.save(prop, image: imageRegion.image)
                }
                return (url, user)
            }
    }

    func updateUserImages(
        avatarImage: ImageRegionData?,
        coverImage: ImageRegionData?,
        properties: [Profile.Property: Any] = [:])
        -> Promise<UploadBothSuccess>
    {
        var avatarURL: URL?
        var coverImageURL: URL?
        var error: Error?
        let (promise, resolve, reject) = Promise<UploadBothSuccess>.pending()

        let bothImages = after(2) {
            if let error = error {
                reject(error)
            }
            else {
                var mergedProperties: [Profile.Property: Any] = properties

                if let avatarImage = avatarImage, let avatarURL = avatarURL {
                    TemporaryCache.save(.avatar, image: avatarImage.image)
                    mergedProperties[.avatar] = avatarURL.absoluteString
                }

                if let coverImage = coverImage, let coverImageURL = coverImageURL {
                    TemporaryCache.save(.coverImage, image: coverImage.image)
                    mergedProperties[.coverImage] = coverImageURL.absoluteString
                }

                self.updateUserProfile(mergedProperties)
                    .then { user -> UploadBothSuccess in
                        user.updateDefaultImages(avatarURL: avatarURL, coverImageURL: coverImageURL)
                        return (avatarURL, coverImageURL, user)
                    }
                    .then(execute: resolve)
                    .catch(execute: reject)
            }
        }

        if let avatarImage = avatarImage {
            S3UploadingService().upload(imageRegionData: avatarImage)
                .then { url in
                    avatarURL = url
                }
                .catch { uploadError in
                    error = error ?? uploadError
                }
                .always {
                    bothImages()
                }
        }
        else {
            bothImages()
        }

        if let coverImage = coverImage {
            S3UploadingService().upload(imageRegionData: coverImage)
                .then { url in
                    coverImageURL = url
                }
                .catch { uploadError in
                    error = error ?? uploadError
                }
                .always {
                    bothImages()
                }
        }
        else {
            bothImages()
        }

        return promise
    }

    func updateUserDeviceToken(_ token: Data) -> Promise<Void> {
        log(comment: "push token", object: String((token as NSData).description.filter { !"<> ".contains($0) }))
        return ElloProvider.shared.request(.pushSubscriptions(token: token))
            .asVoid()
    }

    func removeUserDeviceToken(_ token: Data) -> Promise<Void> {
        return ElloProvider.shared.request(.deleteSubscriptions(token: token))
            .asVoid()
    }

    private func updateUserImage(
        _ image: ImageRegionData,
        key: Profile.Property,
        properties: [Profile.Property: Any])
        -> Promise<UploadSuccess>
    {
        return S3UploadingService().upload(imageRegionData: image)
            .then { url -> Promise<UploadSuccess> in
                guard let url = url else {
                    throw NSError.uncastableJSONAble()
                }

                let urlString = url.absoluteString
                let mergedProperties: [Profile.Property: Any] = properties + [
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
