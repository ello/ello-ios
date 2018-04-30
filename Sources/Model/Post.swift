////
///  Post.swift
//

import SwiftyJSON


// version 1: initial
// version 2: added "watching"
let PostVersion = 2

@objc(Post)
final class Post: Model, Authorable, Groupable {

    let id: String
    let createdAt: Date
    let authorId: String
    let token: String
    let isAdultContent: Bool
    let contentWarning: String
    let allowComments: Bool
    var isReposted: Bool
    var isLoved: Bool
    var isWatching: Bool
    let summary: [Regionable]
    var content: [Regionable]
    let body: [Regionable]
    let repostContent: [Regionable]

    var artistInviteId: String?
    var viewsCount: Int?
    var commentsCount: Int?
    var repostsCount: Int?
    var lovesCount: Int?

    var assets: [Asset] { return getLinkArray("assets") }
    var firstImageURL: URL? { return assets.first?.largeOrBest?.url }
    var author: User? { return getLinkObject("author") }
    var categoryPosts: [CategoryPost] { return getLinkArray("category_posts") }
    var category: Category? { return categoryPosts.first?.category ?? getLinkObject("category") }
    var repostAuthor: User? { return repostSource?.author ?? getLinkObject("repost_author") }
    var repostSource: Post? { return getLinkObject("reposted_source") }
    var featuredBy: User? { return categoryPosts.first?.featuredBy }

    var comments: [ElloComment]? {
        let nestedComments: [ElloComment] = getLinkArray("comments")
        for comment in nestedComments {
            comment.loadedFromPostId = self.id
        }
        return nestedComments
    }
    var groupId: String { return "Post-\(id)" }
    var shareLink: String? {
        return author.map { "\(ElloURI.baseURL)/\($0.username)/post/\(self.token)" }
    }
    var isCollapsed: Bool { return !contentWarning.isEmpty }
    var isRepost: Bool {
        return repostContent.count > 0
    }
    var notificationContent: [Regionable]? {
        if isRepost { return repostContent }
        return content
    }
    private var lovedChangedNotification: NotificationObserver?
    private var commentsCountChangedNotification: NotificationObserver?

    init(id: String,
        createdAt: Date,
        authorId: String,
        token: String,
        isAdultContent: Bool,
        contentWarning: String,
        allowComments: Bool,
        isReposted: Bool,
        isLoved: Bool,
        isWatching: Bool,
        summary: [Regionable],
        content: [Regionable],
        body: [Regionable],
        repostContent: [Regionable]
        )
    {
        self.id = id
        self.createdAt = createdAt
        self.authorId = authorId
        self.token = token
        self.isAdultContent = isAdultContent
        self.contentWarning = contentWarning
        self.allowComments = allowComments
        self.isReposted = isReposted
        self.isLoved = isLoved
        self.isWatching = isWatching
        self.summary = summary
        self.content = content
        self.body = body
        self.repostContent = repostContent
        super.init(version: PostVersion)

        lovedChangedNotification = NotificationObserver(notification: PostChangedNotification) { [unowned self] (post, change) in
            if post.id == self.id && change == .loved {
                self.isLoved = post.isLoved
            }
        }

        commentsCountChangedNotification = NotificationObserver(notification: PostCommentsCountChangedNotification) { [unowned self] (post, delta) in
            if post.id == self.id {
                self.commentsCount = (self.commentsCount ?? 0) + delta
            }
        }

        addLinkObject("author", key: authorId, type: .usersType)
    }

    deinit {
        lovedChangedNotification?.removeObserver()
        commentsCountChangedNotification?.removeObserver()
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        self.id = decoder.decodeKey("id")
        self.createdAt = decoder.decodeKey("createdAt")
        self.authorId = decoder.decodeKey("authorId")
        self.token = decoder.decodeKey("token")
        self.isAdultContent = decoder.decodeKey("isAdultContent")
        self.contentWarning = decoder.decodeKey("contentWarning")
        self.allowComments = decoder.decodeKey("allowComments")
        self.summary = decoder.decodeKey("summary")
        self.isReposted = decoder.decodeKey("reposted")
        self.isLoved = decoder.decodeKey("loved")
        let version: Int = decoder.decodeKey("version")
        if version > 1 {
            self.isWatching = decoder.decodeKey("watching")
        }
        else {
            self.isWatching = false
        }
        self.content = decoder.decodeOptionalKey("content") ?? []
        self.body = decoder.decodeOptionalKey("body") ?? []
        self.repostContent = decoder.decodeOptionalKey("repostContent") ?? []
        self.artistInviteId = decoder.decodeOptionalKey("artistInviteId")
        self.viewsCount = decoder.decodeOptionalKey("viewsCount")
        self.commentsCount = decoder.decodeOptionalKey("commentsCount")
        self.repostsCount = decoder.decodeOptionalKey("repostsCount")
        self.lovesCount = decoder.decodeOptionalKey("lovesCount")
        super.init(coder: coder)

        lovedChangedNotification = NotificationObserver(notification: PostChangedNotification) { [unowned self] (post, change) in
            if post.id == self.id && change == .loved {
                self.isLoved = post.isLoved
            }
        }

        commentsCountChangedNotification = NotificationObserver(notification: PostCommentsCountChangedNotification) { (post, delta) in
            if post.id == self.id {
                self.commentsCount = (self.commentsCount ?? 0) + delta
            }
        }
    }

    override func encode(with encoder: NSCoder) {
        let coder = Coder(encoder)
        coder.encodeObject(id, forKey: "id")
        coder.encodeObject(createdAt, forKey: "createdAt")
        coder.encodeObject(authorId, forKey: "authorId")
        coder.encodeObject(token, forKey: "token")
        coder.encodeObject(isAdultContent, forKey: "isAdultContent")
        coder.encodeObject(contentWarning, forKey: "contentWarning")
        coder.encodeObject(allowComments, forKey: "allowComments")
        coder.encodeObject(summary, forKey: "summary")
        coder.encodeObject(content, forKey: "content")
        coder.encodeObject(body, forKey: "body")
        coder.encodeObject(repostContent, forKey: "repostContent")
        coder.encodeObject(artistInviteId, forKey: "artistInviteId")
        coder.encodeObject(isReposted, forKey: "reposted")
        coder.encodeObject(isLoved, forKey: "loved")
        coder.encodeObject(isWatching, forKey: "watching")
        coder.encodeObject(viewsCount, forKey: "viewsCount")
        coder.encodeObject(commentsCount, forKey: "commentsCount")
        coder.encodeObject(repostsCount, forKey: "repostsCount")
        coder.encodeObject(lovesCount, forKey: "lovesCount")
        super.encode(with: coder.coder)
    }

    class func fromJSON(_ data: [String: Any]) -> Post {
        let json = JSON(data)
        let repostContent = RegionParser.jsonRegions(json: json["repost_content"])
        let createdAt: Date
        if let date = json["created_at"].stringValue.toDate() {
            createdAt = date
        }
        else {
            createdAt = Globals.now
        }

        let post = Post(
            id: json["id"].stringValue,
            createdAt: createdAt,
            authorId: json["author_id"].stringValue,
            token: json["token"].stringValue,
            isAdultContent: json["is_adult_content"].boolValue,
            contentWarning: json["content_warning"].stringValue,
            allowComments: json["allow_comments"].boolValue,
            isReposted: json["reposted"].bool ?? false,
            isLoved: json["loved"].bool ?? false,
            isWatching: json["watching"].bool ?? false,
            summary: RegionParser.jsonRegions(json: json["summary"]),
            content: RegionParser.jsonRegions(json: json["content"], isRepostContent: repostContent.count > 0),
            body: RegionParser.jsonRegions(json: json["body"], isRepostContent: repostContent.count > 0),
            repostContent: repostContent
        )

        post.artistInviteId = json["artist_invite_id"].id
        post.viewsCount = json["views_count"].int
        post.commentsCount = json["comments_count"].int
        post.repostsCount = json["reposts_count"].int
        post.lovesCount = json["loves_count"].int

        post.mergeLinks(data["links"] as? [String: Any])
        post.addLinkObject("author", key: post.authorId, type: .usersType)
        if post.categoryPosts.isEmpty, let category = (post.getLinkArray("categories") as [Category]).first {
            post.addLinkObject("category", key: category.id, type: .categoriesType)
        }

        return post
    }

    func contentFor(gridView: Bool) -> [Regionable]? {
        return gridView ? summary : content
    }
}

extension Post: JSONSaveable {
    var uniqueId: String? { return "Post-\(id)" }
    var tableId: String? { return id }

}
