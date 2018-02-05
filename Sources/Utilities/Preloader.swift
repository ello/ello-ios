////
///  Preloader.swift
//

import PINRemoteImage

struct Preloader {

    // exposed so that we can swap out a fake in specs
    var manager = PINRemoteImageManager.shared()

    func preloadImages(_ jsonables: [JSONAble]) {
        for jsonable in jsonables {

            // activities avatar
            if let activity = jsonable as? Activity,
                let authorable = activity.subject as? Authorable,
                let author = authorable.author,
                let avatarURL = author.avatarURL()
            {
                preloadUrl(avatarURL)
            }
            // post / comment avatars
            else if let authorable = jsonable as? Authorable,
                let author = authorable.author,
                let avatarURL = author.avatarURL()
            {
                preloadUrl(avatarURL)
            }
            // user's posts avatars
            else if let user = jsonable as? User,
                let userAvatarURL = user.avatarURL()
            {
                preloadUrl(userAvatarURL)
            }

            // activity image regions
            if let activity = jsonable as? Activity,
                let post = activity.subject as? Post
            {
                preloadImagesinPost(post)
            }
            // post image regions
            else if let post = jsonable as? Post {
                preloadImagesinPost(post)
            }
            // comment image regions
            else if let comment = jsonable as? ElloComment {
                preloadImagesInRegions(comment.content)
            }
            // categories
            else if let category = jsonable as? Category,
                let url = category.tileURL
            {
                preloadUrl(url)
            }
            // promotionals
            else if let promotional = jsonable as? PagePromotional,
                let url = promotional.tileURL
            {
                preloadUrl(url)
            }

            // TODO: account for discovery when the api includes assets in the discovery
            // responses
        }
    }

    private func preloadUserAvatar(_ post: Post, streamKind: StreamKind) {
        if let content = post.content {
            for region in content {
                if let imageRegion = region as? ImageRegion,
                    let asset = imageRegion.asset,
                    let attachment = asset.oneColumnAttachment
                {
                    preloadUrl(attachment.url)
                }
            }
        }
    }

    private func preloadImagesinPost(_ post: Post) {
        if let content = post.content {
            preloadImagesInRegions(content)
        }
    }

    private func preloadImagesInRegions(_ regions: [Regionable]) {
        for region in regions {
            if let imageRegion = region as? ImageRegion,
                let asset = imageRegion.asset,
                let attachment = asset.oneColumnAttachment
            {
                preloadUrl(attachment.url)
            }
        }
    }

    private func preloadUrl(_ url: URL) {
        if !url.hasGifExtension && !url.hasMP4Extension && DeviceScreen.isRetina {
            manager.prefetchImage(with: url, options: PINRemoteImageManagerDownloadOptions())
        }
    }
}
