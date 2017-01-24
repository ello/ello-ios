////
///  Preloader.swift
//

import PINRemoteImage

struct Preloader {

    // exposed so that we can swap out a fake in specs
    var manager = PINRemoteImageManager.shared()

    init(){}

    func preloadImages(_ jsonables: [JSONAble]) {
        for jsonable in jsonables {

            // activities avatar
            if let activity = jsonable as? Activity,
                let authorable = activity.subject as? Authorable,
                let author = authorable.author,
                let avatarURL = author.avatarURL()
            {
                preloadUrl(avatarURL as URL)
            }

            // post / comment avatars
            else if let authorable = jsonable as? Authorable,
                let author = authorable.author,
                let avatarURL = author.avatarURL()
            {
                preloadUrl(avatarURL as URL)
            }

            // user's posts avatars
            else if let user = jsonable as? User,
                let posts = user.posts
            {
                if let userAvatarURL = user.avatarURL() {
                    preloadUrl(userAvatarURL as URL)
                }

                for post in posts {
                    if let author = post.author,
                        let avatarURL = author.avatarURL()
                    {
                        preloadUrl(avatarURL as URL)
                    }
                }
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

            // user's posts image regions
            else if let user = jsonable as? User,
                let posts = user.posts
            {
                for post in posts {
                    preloadImagesinPost(post)
                }
            }

            // categories
            else if let category = jsonable as? Category,
                let url = category.tileURL
            {
                preloadUrl(url as URL)
            }

            // promotionals
            else if let promotional = jsonable as? PagePromotional,
                let url = promotional.tileURL
            {
                preloadUrl(url as URL)
            }

            // TODO: account for discovery when the api includes assets in the discovery
            // responses
        }
    }

    fileprivate func preloadUserAvatar(_ post: Post, streamKind: StreamKind) {
        if let content = post.content {
            for region in content {
                if let imageRegion = region as? ImageRegion,
                    let asset = imageRegion.asset,
                    let attachment = asset.oneColumnAttachment
                {
                    preloadUrl(attachment.url as URL)
                }
            }
        }
    }

    fileprivate func preloadImagesinPost(_ post: Post) {
        if let content = post.content {
            preloadImagesInRegions(content)
        }
    }

    fileprivate func preloadImagesInRegions(_ regions: [Regionable]) {
        for region in regions {
            if let imageRegion = region as? ImageRegion,
                let asset = imageRegion.asset,
                let attachment = asset.oneColumnAttachment
            {
                preloadUrl(attachment.url as URL)
            }
        }
    }

    fileprivate func preloadUrl(_ url: URL) {
        if !url.hasGifExtension {
            manager?.prefetchImage(with: url, options: PINRemoteImageManagerDownloadOptions())
        }
    }
}
