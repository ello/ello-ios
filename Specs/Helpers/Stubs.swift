////
///  Stubs.swift
//

import Ello


func stub<T: Stubbable>(values: [String : AnyObject]) -> T {
    return T.stub(values)
}

func urlFromValue(value: AnyObject?) -> NSURL? {
    guard let value = value else {
        return nil
    }

    if let url = value as? NSURL {
        return url
    } else if let str = value as? String {
        return NSURL(string: str)
    }
    return nil
}

let stubbedTextRegion: TextRegion = stub([:])

protocol Stubbable: NSObjectProtocol {
    static func stub(values: [String: AnyObject]) -> Self
}

extension User: Stubbable {
    class func stub(values: [String: AnyObject]) -> User {
        let relationshipPriority: RelationshipPriority
        if let priorityName = values["relationshipPriority"] as? String,
            priority = RelationshipPriority(rawValue: priorityName) {
            relationshipPriority = priority
        }
        else {
            relationshipPriority = RelationshipPriority.None
        }

        let user =  User(
            id: (values["id"] as? String) ?? NSUUID().UUIDString,
            href: (values["href"] as? String) ?? "href",
            username: (values["username"] as? String) ?? "username",
            name: (values["name"] as? String) ?? "name",
            experimentalFeatures: (values["experimentalFeatures"] as? Bool) ?? false,
            relationshipPriority: relationshipPriority,
            postsAdultContent: (values["postsAdultContent"] as? Bool) ?? false,
            viewsAdultContent: (values["viewsAdultContent"] as? Bool) ?? false,
            hasCommentingEnabled: (values["hasCommentingEnabled"] as? Bool) ?? true,
            hasSharingEnabled: (values["hasSharingEnabled"] as? Bool) ?? true,
            hasRepostingEnabled: (values["hasRepostingEnabled"] as? Bool) ?? true,
            hasLovesEnabled: (values["hasLovesEnabled"] as? Bool) ?? true,
            isCollaborateable: (values["isCollaborateable"] as? Bool) ?? false,
            isHireable: (values["isHireable"] as? Bool) ?? false
        )
        user.avatar = values["avatar"] as? Asset
        user.identifiableBy = (values["identifiableBy"] as? String) ?? "stub-user-identifiable-by"
        user.postsCount = (values["postsCount"] as? Int) ?? 0
        user.lovesCount = (values["lovesCount"] as? Int) ?? 0
        user.totalViewsCount = (values["totalViewsCount"] as? Int) ?? 0
        if let count = values["followersCount"] as? Int {
            user.followersCount = String(count)
        }
        else if let count = values["followersCount"] as? String {
            user.followersCount = count
        }
        else {
            user.followersCount = "stub-user-followers-count"
        }
        user.followingCount = (values["followingCount"] as? Int) ?? 0
        user.formattedShortBio = (values["formattedShortBio"] as? String) ?? "stub-user-formatted-short-bio"
        if let linkValues = (values["externalLinksList"] as? [[String:String]]) {
            user.externalLinksList = linkValues.flatMap { ExternalLink.fromDict($0) }
        }
        else if let externalLinks = (values["externalLinksList"] as? [ExternalLink]) {
            user.externalLinksList = externalLinks
        }
        else {
            user.externalLinksList = [ExternalLink(url: NSURL(string: "http://ello.co")!, text: "ello.co")]
        }
        user.coverImage = values["coverImage"] as? Asset
        user.backgroundPosition = (values["backgroundPosition"] as? String) ?? "stub-user-background-position"
        user.onboardingVersion = (values["onboardingVersion"] as? Int)
        // links / nested resources
        if let posts = values["posts"] as? [Post] {
            var postIds = [String]()
            for post in posts {
                postIds.append(post.id)
                ElloLinkedStore.sharedInstance.setObject(post, forKey: post.id, type: .PostsType)
            }
            user.addLinkArray("posts", array: postIds, type: .PostsType)
        }
        if let mostRecentPost = values["mostRecentPost"] as? Post {
            user.addLinkObject("most_recent_post", key: mostRecentPost.id, type: .PostsType)
            ElloLinkedStore.sharedInstance.setObject(mostRecentPost, forKey: mostRecentPost.id, type: .PostsType)
        }

        if let categories = values["categories"] as? [Ello.Category] {
            for category in categories {
                ElloLinkedStore.sharedInstance.setObject(category, forKey: category.id, type: .CategoriesType)
            }
            user.addLinkArray("categories", array: categories.map { $0.id }, type: .CategoriesType)
        }

        user.location = values["location"] as? String

        user.profile = values["profile"] as? Profile
        ElloLinkedStore.sharedInstance.setObject(user, forKey: user.id, type: .UsersType)
        return user
    }
}

extension Username: Stubbable {
    class func stub(values: [String: AnyObject]) -> Username {

        let username = Username(
            username: (values["username"] as? String) ?? "archer"
        )

        return username
    }
}

extension Love: Stubbable {
    class func stub(values: [String: AnyObject]) -> Love {

        // create necessary links

        let post: Post = (values["post"] as? Post) ?? Post.stub(["id": values["postId"] ?? NSUUID().UUIDString])
        ElloLinkedStore.sharedInstance.setObject(post, forKey: post.id, type: .PostsType)

        let user: User = (values["user"] as? User) ?? User.stub(["id": values["userId"] ?? NSUUID().UUIDString])
        ElloLinkedStore.sharedInstance.setObject(user, forKey: user.id, type: .UsersType)

        let love = Love(
            id: (values["id"] as? String) ?? NSUUID().UUIDString,
            createdAt: (values["createdAt"] as? NSDate) ?? NSDate(),
            updatedAt: (values["updatedAt"] as? NSDate) ?? NSDate(),
            deleted: (values["deleted"] as? Bool) ?? true,
            postId: post.id,
            userId: user.id
        )

        return love
    }
}

extension Watch: Stubbable {
    class func stub(values: [String: AnyObject]) -> Watch {

        // create necessary links

        let post: Post = (values["post"] as? Post) ?? Post.stub(["id": values["postId"] ?? NSUUID().UUIDString])
        ElloLinkedStore.sharedInstance.setObject(post, forKey: post.id, type: .PostsType)

        let user: User = (values["user"] as? User) ?? User.stub(["id": values["userId"] ?? NSUUID().UUIDString])
        ElloLinkedStore.sharedInstance.setObject(user, forKey: user.id, type: .UsersType)

        let watch = Watch(
            id: (values["id"] as? String) ?? NSUUID().UUIDString,
            createdAt: (values["createdAt"] as? NSDate) ?? NSDate(),
            updatedAt: (values["updatedAt"] as? NSDate) ?? NSDate(),
            postId: post.id,
            userId: user.id
        )

        return watch
    }
}

extension Profile: Stubbable {
    class func stub(values: [String: AnyObject]) -> Profile {
        let profile = Profile(
            id: (values["id"] as? String) ?? NSUUID().UUIDString,
            createdAt: (values["createdAt"] as? NSDate) ?? NSDate(),
            shortBio: (values["shortBio"] as? String) ?? "shortBio",
            email: (values["email"] as? String) ?? "email@example.com",
            confirmedAt: (values["confirmedAt"] as? NSDate) ?? NSDate(),
            isPublic: (values["isPublic"] as? Bool) ?? true,
            mutedCount: (values["mutedCount"] as? Int) ?? 0,
            blockedCount: (values["blockedCount"] as? Int) ?? 0,
            hasSharingEnabled: (values["hasSharingEnabled"] as? Bool) ?? true,
            hasAdNotificationsEnabled: (values["hasAdNotificationsEnabled"] as? Bool) ?? true,
            hasAutoWatchEnabled: (values["hasAutoWatchEnabled"] as? Bool) ?? true,
            allowsAnalytics: (values["allowsAnalytics"] as? Bool) ?? true,
            notifyOfCommentsViaEmail: (values["notifyOfCommentsViaEmail"] as? Bool) ?? true,
            notifyOfLovesViaEmail: (values["notifyOfLovesViaEmail"] as? Bool) ?? true,
            notifyOfInvitationAcceptancesViaEmail: (values["notifyOfInvitationAcceptancesViaEmail"] as? Bool) ?? true,
            notifyOfMentionsViaEmail: (values["notifyOfMentionsViaEmail"] as? Bool) ?? true,
            notifyOfNewFollowersViaEmail: (values["notifyOfNewFollowersViaEmail"] as? Bool) ?? true,
            notifyOfRepostsViaEmail: (values["notifyOfRepostsViaEmail"] as? Bool) ?? true,
            subscribeToUsersEmailList: (values["subscribeToUsersEmailList"] as? Bool) ?? true,
            subscribeToDailyEllo: (values["subscribeToDailyEllo"] as? Bool) ?? true,
            subscribeToWeeklyEllo: (values["subscribeToWeeklyEllo"] as? Bool) ?? true,
            subscribeToOnboardingDrip: (values["subscribeToOnboardingDrip"] as? Bool) ?? true,
            notifyOfCommentsViaPush: (values["notifyOfCommentsViaPush"] as? Bool) ?? true,
            notifyOfLovesViaPush : (values["notifyOfLovesViaPush"] as? Bool) ?? true,
            notifyOfMentionsViaPush: (values["notifyOfMentionsViaPush"] as? Bool) ?? true,
            notifyOfRepostsViaPush: (values["notifyOfRepostsViaPush"] as? Bool) ?? true,
            notifyOfNewFollowersViaPush: (values["notifyOfNewFollowersViaPush"] as? Bool) ?? true,
            notifyOfInvitationAcceptancesViaPush: (values["notifyOfInvitationAcceptancesViaPush"] as? Bool) ?? true,
            notifyOfWatchesViaPush: (values["notifyOfWatchesViaPush"] as? Bool) ?? true,
            notifyOfWatchesViaEmail: (values["notifyOfWatchesViaEmail"] as? Bool) ?? true,
            notifyOfCommentsOnPostWatchViaPush: (values["notifyOfCommentsOnPostWatchViaPush"] as? Bool) ?? true,
            notifyOfCommentsOnPostWatchViaEmail: (values["notifyOfCommentsOnPostWatchViaEmail"] as? Bool) ?? true,
            discoverable: (values["discoverable"] as? Bool) ?? true
        )
        return profile
    }
}

extension Post: Stubbable {
    class func stub(values: [String: AnyObject]) -> Post {

        // create necessary links

        let author: User = (values["author"] as? User) ?? User.stub(["id": values["authorId"] ?? NSUUID().UUIDString])
        ElloLinkedStore.sharedInstance.setObject(author, forKey: author.id, type: .UsersType)

        let post = Post(
            id: (values["id"] as? String) ?? NSUUID().UUIDString,
            createdAt: (values["createdAt"] as? NSDate) ?? NSDate(),
            authorId: author.id,
            href: (values["href"] as? String) ?? "sample-href",
            token: (values["token"] as? String) ?? "sample-token",
            isAdultContent: (values["isAdultContent"] as? Bool) ?? false,
            contentWarning: (values["contentWarning"] as? String) ?? "",
            allowComments: (values["allowComments"] as? Bool) ?? false,
            reposted: (values["reposted"] as? Bool) ?? false,
            loved: (values["loved"] as? Bool) ?? false,
            watching: (values["watching"] as? Bool) ?? false,
            summary: (values["summary"] as? [Regionable]) ?? [stubbedTextRegion]
        )

        if let repostAuthor = values["repostAuthor"] as? User {
            ElloLinkedStore.sharedInstance.setObject(repostAuthor, forKey: repostAuthor.id, type: .UsersType)
            post.addLinkObject("repost_author", key: repostAuthor.id, type: .UsersType)
        }

        if let categories = values["categories"] as? [Ello.Category] {
            for category in categories {
                ElloLinkedStore.sharedInstance.setObject(category, forKey: category.id, type: .CategoriesType)
            }
            post.addLinkArray("categories", array: categories.map { $0.id }, type: .CategoriesType)
        }

        // optional
        post.body = (values["body"] as? [Regionable]) ?? [stubbedTextRegion]
        post.content = (values["content"] as? [Regionable]) ?? [stubbedTextRegion]
        post.repostContent = (values["repostContent"] as? [Regionable])
        post.repostId = (values["repostId"] as? String)
        post.repostPath = (values["repostPath"] as? String)
        post.repostViaId = (values["repostViaId"] as? String)
        post.repostViaPath = (values["repostViaPath"] as? String)
        post.viewsCount = values["viewsCount"] as? Int
        post.commentsCount = values["commentsCount"] as? Int
        post.repostsCount = values["repostsCount"] as? Int
        post.lovesCount = values["lovesCount"] as? Int
        // links / nested resources
        if let assets = values["assets"] as? [Asset] {
            var assetIds = [String]()
            for asset in assets {
                assetIds.append(asset.id)
                ElloLinkedStore.sharedInstance.setObject(asset, forKey: asset.id, type: .AssetsType)
            }
            post.addLinkArray("assets", array: assetIds, type: .AssetsType)
        }
        if let comments = values["comments"] as? [ElloComment] {
            var commentIds = [String]()
            for comment in comments {
                commentIds.append(comment.id)
                ElloLinkedStore.sharedInstance.setObject(comment, forKey: comment.id, type: .CommentsType)
            }
            post.addLinkArray("comments", array: commentIds, type: .CommentsType)
        }
        ElloLinkedStore.sharedInstance.setObject(post, forKey: post.id, type: .PostsType)
        return post
    }

    class func stubWithRegions(values: [String: AnyObject], summary: [Regionable] = [], content: [Regionable] = []) -> Post {
        var mutatedValues = values
        mutatedValues.updateValue(summary, forKey: "summary")
        let post: Post = stub(mutatedValues)
        post.content = content
        return post
    }

}

extension ElloComment: Stubbable {
    class func stub(values: [String: AnyObject]) -> ElloComment {

        // create necessary links
        let author: User = (values["author"] as? User) ?? User.stub(["id": values["authorId"] ?? NSUUID().UUIDString])
        ElloLinkedStore.sharedInstance.setObject(author, forKey: author.id, type: .UsersType)
        let parentPost: Post = (values["parentPost"] as? Post) ?? Post.stub(["id": values["parentPostId"] ?? NSUUID().UUIDString])
        ElloLinkedStore.sharedInstance.setObject(parentPost, forKey: parentPost.id, type: .PostsType)
        let loadedFromPost: Post = (values["loadedFromPost"] as? Post) ?? parentPost
        ElloLinkedStore.sharedInstance.setObject(loadedFromPost, forKey: loadedFromPost.id, type: .PostsType)

        let comment = ElloComment(
            id: (values["id"] as? String) ?? NSUUID().UUIDString,
            createdAt: (values["createdAt"] as? NSDate) ?? NSDate(),
            authorId: author.id,
            postId: parentPost.id,
            content: (values["content"] as? [Regionable]) ?? [stubbedTextRegion]
        )

        comment.loadedFromPostId = loadedFromPost.id
        comment.summary = values["summary"] as? [Regionable] ?? comment.content

        // links
        if let assets = values["assets"] as? [Asset] {
            var assetIds = [String]()
            for asset in assets {
                assetIds.append(asset.id)
                ElloLinkedStore.sharedInstance.setObject(asset, forKey: asset.id, type: .AssetsType)
            }
            comment.addLinkArray("assets", array: assetIds, type: .AssetsType)
        }
        ElloLinkedStore.sharedInstance.setObject(comment, forKey: comment.id, type: .CommentsType)
        return comment
    }
}

extension TextRegion: Stubbable {
    class func stub(values: [String: AnyObject]) -> TextRegion {
        return TextRegion(
            content: (values["content"] as? String) ?? "Lorem Ipsum"
        )
    }
}

extension ImageRegion: Stubbable {
    class func stub(values: [String: AnyObject]) -> ImageRegion {
        let imageRegion = ImageRegion(alt: (values["alt"] as? String) ?? "imageRegion")
        imageRegion.url = urlFromValue(values["url"])
        imageRegion.buyButtonURL = urlFromValue(values["buyButtonURL"])
        if let asset = values["asset"] as? Asset {
            imageRegion.addLinkObject("assets", key: asset.id, type: .AssetsType)
            ElloLinkedStore.sharedInstance.setObject(asset, forKey: asset.id, type: .AssetsType)
        }
        return imageRegion
    }
}

extension EmbedRegion: Stubbable {
    class func stub(values: [String: AnyObject]) -> EmbedRegion {
        let serviceString = (values["service"] as? String) ?? EmbedType.Youtube.rawValue
        let embedRegion = EmbedRegion(
            id: (values["id"] as? String) ?? NSUUID().UUIDString,
            service: EmbedType(rawValue: serviceString)!,
            url: urlFromValue(values["url"]) ?? NSURL(string: "http://www.google.com")!,
            thumbnailSmallUrl: urlFromValue(values["thumbnailSmallUrl"]) ?? NSURL(string: "http://www.google.com")!,
            thumbnailLargeUrl: urlFromValue(values["thumbnailLargeUrl"]) ?? NSURL(string: "http://www.google.com")!
        )
        embedRegion.isRepost = (values["isRepost"] as? Bool) ?? false
        return embedRegion
    }
}

extension UnknownRegion: Stubbable {
    class func stub(values: [String: AnyObject]) -> UnknownRegion {
        return UnknownRegion(name: "no-op")
    }
}

extension AutoCompleteResult: Stubbable {
    class func stub(values: [String: AnyObject]) -> AutoCompleteResult {
        let name = (values["name"] as? String) ?? "666"
        let result = AutoCompleteResult(name: name)
        result.url = urlFromValue(values["url"]) ?? NSURL(string: "http://www.google.com")!
        return result
    }
}

extension Activity: Stubbable {
    class func stub(values: [String: AnyObject]) -> Activity {

        let activityKindString = (values["kind"] as? String) ?? Activity.Kind.FriendPost.rawValue
        let subjectTypeString = (values["subjectType"] as? String) ?? SubjectType.Post.rawValue

        let activity = Activity(
            id: (values["id"] as? String) ?? NSUUID().UUIDString,
            createdAt: (values["createdAt"] as? NSDate) ?? NSDate(),
            kind: Activity.Kind(rawValue: activityKindString) ?? Activity.Kind.FriendPost,
            subjectType: SubjectType(rawValue: subjectTypeString) ?? SubjectType.Post
        )

        if let user = values["subject"] as? User {
            activity.addLinkObject("subject", key: user.id, type: .UsersType)
            ElloLinkedStore.sharedInstance.setObject(user, forKey: user.id, type: .UsersType)
        }
        else if let post = values["subject"] as? Post {
            activity.addLinkObject("subject", key: post.id, type: .PostsType)
            ElloLinkedStore.sharedInstance.setObject(post, forKey: post.id, type: .PostsType)
        }
        else if let comment = values["subject"] as? ElloComment {
            activity.addLinkObject("subject", key: comment.id, type: .CommentsType)
            ElloLinkedStore.sharedInstance.setObject(comment, forKey: comment.id, type: .CommentsType)
        }
        ElloLinkedStore.sharedInstance.setObject(activity, forKey: activity.id, type: .ActivitiesType)
        return activity
    }
}

extension Asset: Stubbable {
    class func stub(values: [String: AnyObject]) -> Asset {
        let asset = Asset(id: (values["id"] as? String) ?? NSUUID().UUIDString)
        let defaultAttachment = values["attachment"] as? Attachment
        asset.optimized = (values["optimized"] as? Attachment) ?? defaultAttachment
        asset.smallScreen = (values["smallScreen"] as? Attachment) ?? defaultAttachment
        asset.ldpi = (values["ldpi"] as? Attachment) ?? defaultAttachment
        asset.mdpi = (values["mdpi"] as? Attachment) ?? defaultAttachment
        asset.hdpi = (values["hdpi"] as? Attachment) ?? defaultAttachment
        asset.xhdpi = (values["xhdpi"] as? Attachment) ?? defaultAttachment
        asset.original = (values["original"] as? Attachment) ?? defaultAttachment
        asset.large = (values["large"] as? Attachment) ?? defaultAttachment
        asset.regular = (values["regular"] as? Attachment) ?? defaultAttachment
        asset.small = (values["small"] as? Attachment) ?? defaultAttachment
        ElloLinkedStore.sharedInstance.setObject(asset, forKey: asset.id, type: .AssetsType)
        return asset
    }
}

extension Attachment: Stubbable {
    class func stub(values: [String: AnyObject]) -> Attachment {
        let attachment = Attachment(url: urlFromValue(values["url"]) ?? NSURL(string: "http://www.google.com")!)
        attachment.height = values["height"] as? Int
        attachment.width = values["width"] as? Int
        attachment.type = values["type"] as? String
        attachment.size = values["size"] as? Int
        attachment.image = values["image"] as? UIImage
        return attachment
    }
}

extension Notification: Stubbable {
    class func stub(values: [String: AnyObject]) -> Notification {
        return Notification(activity: (values["activity"] as? Activity) ?? Activity.stub([:]))
    }
}

extension Relationship: Stubbable {
    class func stub(values: [String: AnyObject]) -> Relationship {
        // create necessary links
        let owner: User = (values["owner"] as? User) ?? User.stub(["relationshipPriority": "self", "id": values["ownerId"] ?? NSUUID().UUIDString])
        ElloLinkedStore.sharedInstance.setObject(owner, forKey: owner.id, type: .UsersType)
        let subject: User = (values["subject"] as? User) ?? User.stub(["relationshipPriority": "friend", "id": values["subjectId"] ?? NSUUID().UUIDString])
        ElloLinkedStore.sharedInstance.setObject(owner, forKey: owner.id, type: .UsersType)

        return Relationship(
            id: (values["id"] as? String) ?? NSUUID().UUIDString,
            createdAt: (values["createdAt"] as? NSDate) ?? NSDate(),
            ownerId: owner.id,
            subjectId: subject.id
        )
    }
}

extension LocalPerson: Stubbable {
    class func stub(values: [String: AnyObject]) -> LocalPerson {
        return LocalPerson(
            name: (values["name"] as? String) ?? "Sterling Archer",
            emails: (values["emails"] as? [String]) ?? ["sterling_archer@gmail.com"],
            id: (values["id"] as? Int32) ?? 987654
        )
    }
}

extension StreamCellItem: Stubbable {
    class func stub(values: [String: AnyObject]) -> StreamCellItem {
        return StreamCellItem(
            jsonable: (values["jsonable"] as? JSONAble) ?? Post.stub([:]),
            type: (values["type"] as? StreamCellType) ?? StreamCellType.Header
        )
    }
}

extension Promotional: Stubbable {
    class func stub(values: [String: AnyObject]) -> Promotional {

        let promotional = Promotional(
            id: (values["id"] as? String) ?? "123",
            userId: (values["userId"] as? String) ?? "456",
            categoryId: (values["categoryId"] as? String) ?? "1"
        )

        if let image = values["image"] as? Asset {
            promotional.addLinkObject("image", key: image.id, type: .AssetsType)
            ElloLinkedStore.sharedInstance.setObject(image, forKey: image.id, type: .AssetsType)
        }

        if let user = values["user"] as? User {
            promotional.addLinkObject("user", key: user.id, type: .UsersType)
            ElloLinkedStore.sharedInstance.setObject(user, forKey: user.id, type: .UsersType)
        }

        return promotional
    }
}


extension PagePromotional: Stubbable {
    class func stub(values: [String: AnyObject]) -> PagePromotional {

        let pagePromotional = PagePromotional(
            id: (values["id"] as? String) ?? "999",
            header: (values["header"] as? String) ?? "Default Header",
            subheader: (values["subheader"] as? String) ?? "Default Subheader",
            ctaCaption: (values["ctaCaption"] as? String) ?? "Default CTA Caption",
            ctaURL: urlFromValue(values["ctaURL"]),
            image: values["image"] as? Asset
        )


        if let image = pagePromotional.image {
            pagePromotional.addLinkObject("image", key: image.id, type: .AssetsType)
            ElloLinkedStore.sharedInstance.setObject(image, forKey: image.id, type: .AssetsType)
        }

        if let user = values["user"] as? User {
            pagePromotional.addLinkObject("user", key: user.id, type: .UsersType)
            ElloLinkedStore.sharedInstance.setObject(user, forKey: user.id, type: .UsersType)
        }


        return pagePromotional
    }
}

extension Ello.Category: Stubbable {
    class func stub(values: [String: AnyObject]) -> Ello.Category {
        let level: CategoryLevel
        if let levelAsString = values["level"] as? String,
            rawLevel = CategoryLevel(rawValue: levelAsString)
        {
            level = rawLevel
        }
        else {
            level = .Primary
        }

        let tileImage: Attachment?
        if let attachment = values["tileImage"] as? [String: AnyObject] {
            tileImage = Attachment.stub(attachment)
        }
        else {
            tileImage = nil
        }

        let category = Category(
            id: (values["id"] as? String) ?? "666",
            name: (values["name"] as? String) ?? "Art",
            slug: (values["slug"] as? String) ?? "art",
            order: (values["order"] as? Int) ?? 0,
            allowInOnboarding: (values["allowInOnboarding"] as? Bool) ?? true,
            usesPagePromo: (values["usesPagePromo"] as? Bool) ?? false,
            level: level,
            tileImage: tileImage
        )

        if let promotionals = values["promotionals"] as? [Promotional] {
            var promotionalIds = [String]()
            for promotional in promotionals {
                promotionalIds.append(promotional.id)
                ElloLinkedStore.sharedInstance.setObject(promotional, forKey: promotional.id, type: .PromotionalsType)
            }
            category.addLinkArray("promotionals", array: promotionalIds, type: .PromotionalsType)
        }

        category.body = values["body"] as? String
        category.header = values["header"] as? String
        category.isSponsored = values["isSponsored"] as? Bool
        category.ctaCaption = values["ctaCaption"] as? String
        category.ctaURL = urlFromValue(values["ctaURL"])

        return category
    }
}
