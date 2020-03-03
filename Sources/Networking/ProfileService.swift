////
///  ProfileService.swift
//

import SwiftyJSON
import PromiseKit


struct ProfileService {
    typealias UploadSuccess = (URL, User)
    typealias UploadBothSuccess = (URL?, URL?, User)

    enum Error: Swift.Error {
        case wrongProperty
    }

    func loadCurrentUser() -> Promise<User> {
        return ElloProvider.shared.request(.currentUserProfile)
            .map { (jsonable, _) -> User in
                guard let user = jsonable as? User else {
                    throw NSError.uncastableModel()
                }
                return user
            }
    }

    func reloadProfile(currentUser: User) -> Promise<Profile> {
        return ElloProvider.shared.request(.currentUserProfile)
            .map { (jsonable, _) -> Profile in
                guard let user = jsonable as? User, let profile = user.profile else {
                    throw NSError.uncastableModel()
                }
                currentUser.profile = profile
                return profile
            }
    }

    func update(categories: [Category], onboarding: Bool) -> Promise<()> {
        return update(categoryIds: Set(categories.map { $0.id }), onboarding: onboarding)
    }

    func update(categoryIds: Set<String>, onboarding: Bool) -> Promise<()> {
        return ElloProvider.shared.request(
            .userCategories(categoryIds: categoryIds, onboarding: onboarding)
        )
            .asVoid()
    }

    func updateUserProfile(_ properties: [Profile.Property: Any]) -> Promise<User> {
        var content: [String: Any] = [:]
        for (key, value) in properties {
            content[key.rawValue] = value
        }
        return ElloProvider.shared.request(.profileUpdate(body: content))
            .map { (jsonable, _) -> User in
                guard let user = jsonable as? User else {
                    throw NSError.uncastableModel()
                }
                return user
            }
    }

    func updateUserImage(_ prop: Profile.ImageProperty, imageRegion: ImageRegionData) -> Promise<
        UploadSuccess
    > {
        guard prop == .coverImage || prop == .avatar else {
            return Promise<UploadSuccess>(error: Error.wrongProperty)
        }

        return updateUserImage(imageRegion, key: prop, properties: [:])
            .map { (url, user) -> UploadSuccess in
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
        properties: [Profile.Property: Any] = [:]
    )
        -> Promise<UploadBothSuccess>
    {
        var avatarURL: URL?
        var coverImageURL: URL?
        var error: Swift.Error?
        let (promise, seal) = Promise<UploadBothSuccess>.pending()

        let bothImages = after(2) {
            if let error = error {
                seal.reject(error)
            }
            else {
                var mergedProperties: [Profile.Property: Any] = properties

                if let avatarImage = avatarImage, let avatarURL = avatarURL {
                    TemporaryCache.save(.avatar, image: avatarImage.image)
                    mergedProperties[.avatarURL] = avatarURL.absoluteString
                }

                if let coverImage = coverImage, let coverImageURL = coverImageURL {
                    TemporaryCache.save(.coverImage, image: coverImage.image)
                    mergedProperties[.coverImageURL] = coverImageURL.absoluteString
                }

                self.updateUserProfile(mergedProperties)
                    .map { user -> UploadBothSuccess in
                        user.updateDefaultImages(avatarURL: avatarURL, coverImageURL: coverImageURL)
                        return (avatarURL, coverImageURL, user)
                    }
                    .done { uploadSuccess in seal.fulfill(uploadSuccess) }
                    .catch(seal.reject)
            }
        }

        if let avatarImage = avatarImage {
            S3UploadingService().upload(imageRegionData: avatarImage)
                .done { url in
                    avatarURL = url
                }
                .catch { uploadError in
                    error = error ?? uploadError
                }
                .finally {
                    bothImages()
                }
        }
        else {
            bothImages()
        }

        if let coverImage = coverImage {
            S3UploadingService().upload(imageRegionData: coverImage)
                .done { url in
                    coverImageURL = url
                }
                .catch { uploadError in
                    error = error ?? uploadError
                }
                .finally {
                    bothImages()
                }
        }
        else {
            bothImages()
        }

        return promise
    }

    func updateUserDeviceToken(_ token: Data) -> Promise<Void> {
        log(
            comment: "push token",
            object: String((token as NSData).description.filter { !"<> ".contains($0) })
        )
        return ElloProvider.shared.request(.pushSubscriptions(token: token))
            .asVoid()
    }

    func removeUserDeviceToken(_ token: Data) -> Promise<Void> {
        return ElloProvider.shared.request(.deleteSubscriptions(token: token))
            .asVoid()
    }

    private func updateUserImage(
        _ image: ImageRegionData,
        key: Profile.ImageProperty,
        properties: [Profile.Property: Any]
    )
        -> Promise<UploadSuccess>
    {
        return S3UploadingService().upload(imageRegionData: image)
            .then { url -> Promise<UploadSuccess> in
                guard let url = url else {
                    throw NSError.uncastableModel()
                }

                let urlString = url.absoluteString
                let mergedProperties: [Profile.Property: Any] = properties + [
                    key.toProperty: urlString,
                ]

                return self.updateUserProfile(mergedProperties)
                    .map { user -> UploadSuccess in
                        return (url, user)
                    }
            }
    }

    func deleteAccount() -> Promise<Void> {
        return ElloProvider.shared.request(.profileDelete)
            .asVoid()
    }
}
