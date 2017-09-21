////
///  Post.swift
//

import SwiftyJSON


// version 1: initial
// version 2: added "watching"
let PostVersion = 2

@objc(Post)
final class Post: JSONAble, Authorable, Groupable {

    // active record
    let id: String
    let createdAt: Date
    // required
    let authorId: String
    let href: String
    let token: String
    let isAdultContent: Bool
    let contentWarning: String
    let allowComments: Bool
    var isReposted: Bool
    var isLoved: Bool
    var isWatching: Bool
    let summary: [Regionable]
    // optional
    var content: [Regionable]?
    var body: [Regionable]?
    var repostContent: [Regionable]?
    var repostId: String?
    var repostPath: String?
    var repostViaId: String?
    var repostViaPath: String?
    var artistInviteId: String?
    var viewsCount: Int?
    var commentsCount: Int?
    var repostsCount: Int?
    var lovesCount: Int?
    // links
    var assets: [Asset] {
        return getLinkArray("assets") as? [Asset] ?? []
    }
    var firstImageURL: URL? {
        return assets.first?.largeOrBest?.url
    }
    var author: User? {
        return ElloLinkedStore.shared.getObject(self.authorId, type: .usersType) as? User
    }
    var categories: [Category] {
        guard let categories = getLinkArray("categories") as? [Category] else {
            return []
        }
        return categories
    }
    var category: Category? {
        return categories.first
    }
    var repostAuthor: User? {
        return getLinkObject("repost_author") as? User
    }
    var repostSource: Post? {
        return getLinkObject("reposted_source") as? Post
    }
    // nested resources
    var comments: [ElloComment]? {
        if let nestedComments = getLinkArray("comments") as? [ElloComment] {
            for comment in nestedComments {
                comment.loadedFromPostId = self.id
            }
            return nestedComments
        }
        return nil
    }
    // links post with comments
    var groupId: String { return "Post-\(id)" }
    // computed properties
    var shareLink: String? {
        return author.map { "\(ElloURI.baseURL)/\($0.username)/post/\(self.token)" }
    }
    var isCollapsed: Bool { return !contentWarning.isEmpty }
    var isRepost: Bool {
        return (repostContent?.count ?? 0) > 0
    }
    var notificationContent: [Regionable]? {
        if isRepost { return repostContent }
        return content
    }
    fileprivate var lovedChangedNotification: NotificationObserver?
    fileprivate var commentsCountChangedNotification: NotificationObserver?

// MARK: Initialization

    init(id: String,
        createdAt: Date,
        authorId: String,
        href: String,
        token: String,
        isAdultContent: Bool,
        contentWarning: String,
        allowComments: Bool,
        isReposted: Bool,
        isLoved: Bool,
        isWatching: Bool,
        summary: [Regionable]
        )
    {
        // active record
        self.id = id
        self.createdAt = createdAt
        // required
        self.authorId = authorId
        self.href = href
        self.token = token
        self.isAdultContent = isAdultContent
        self.contentWarning = contentWarning
        self.allowComments = allowComments
        self.isReposted = isReposted
        self.isLoved = isLoved
        self.isWatching = isWatching
        self.summary = summary
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
    }

    deinit {
        lovedChangedNotification?.removeObserver()
        commentsCountChangedNotification?.removeObserver()
    }

// MARK: NSCoding

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        // active record
        self.id = decoder.decodeKey("id")
        self.createdAt = decoder.decodeKey("createdAt")
        // required
        self.authorId = decoder.decodeKey("authorId")
        self.href = decoder.decodeKey("href")
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
        // optional
        self.content = decoder.decodeOptionalKey("content")
        self.body = decoder.decodeOptionalKey("body")
        self.repostContent = decoder.decodeOptionalKey("repostContent")
        self.repostId = decoder.decodeOptionalKey("repostId")
        self.repostPath = decoder.decodeOptionalKey("repostPath")
        self.repostViaId = decoder.decodeOptionalKey("repostViaId")
        self.repostViaPath = decoder.decodeOptionalKey("repostViaPath")
        self.artistInviteId = decoder.decodeOptionalKey("artistInviteId")
        self.viewsCount = decoder.decodeOptionalKey("viewsCount")
        self.commentsCount = decoder.decodeOptionalKey("commentsCount")
        self.repostsCount = decoder.decodeOptionalKey("repostsCount")
        self.lovesCount = decoder.decodeOptionalKey("lovesCount")
        super.init(coder: coder)

        commentsCountChangedNotification = NotificationObserver(notification: PostCommentsCountChangedNotification) { (post, delta) in
            if post.id == self.id {
                self.commentsCount = (self.commentsCount ?? 0) + delta
            }
        }
    }

    override func encode(with encoder: NSCoder) {
        let coder = Coder(encoder)
        // active record
        coder.encodeObject(id, forKey: "id")
        coder.encodeObject(createdAt, forKey: "createdAt")
        // required
        coder.encodeObject(authorId, forKey: "authorId")
        coder.encodeObject(href, forKey: "href")
        coder.encodeObject(token, forKey: "token")
        coder.encodeObject(isAdultContent, forKey: "isAdultContent")
        coder.encodeObject(contentWarning, forKey: "contentWarning")
        coder.encodeObject(allowComments, forKey: "allowComments")
        coder.encodeObject(summary, forKey: "summary")
        // optional
        coder.encodeObject(content, forKey: "content")
        coder.encodeObject(body, forKey: "body")
        coder.encodeObject(repostContent, forKey: "repostContent")
        coder.encodeObject(repostId, forKey: "repostId")
        coder.encodeObject(repostPath, forKey: "repostPath")
        coder.encodeObject(repostViaId, forKey: "repostViaId")
        coder.encodeObject(repostViaPath, forKey: "repostViaPath")
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

// MARK: JSONAble

    override class func fromJSON(_ data: [String: Any]) -> JSONAble {
        let json = JSON(data)
        let repostContent = RegionParser.regions("repost_content", json: json)
        var createdAt: Date
        if let date = json["created_at"].stringValue.toDate() {
            createdAt = date
        }
        else {
            createdAt = Globals.now
        }
        // create post
        let post = Post(
            id: json["id"].stringValue,
            createdAt: createdAt,
            authorId: json["author_id"].stringValue,
            href: json["href"].stringValue,
            token: json["token"].stringValue,
            isAdultContent: json["is_adult_content"].boolValue,
            contentWarning: json["content_warning"].stringValue,
            allowComments: json["allow_comments"].boolValue,
            isReposted: json["reposted"].bool ?? false,
            isLoved: json["loved"].bool ?? false,
            isWatching: json["watching"].bool ?? false,
            summary: RegionParser.regions("summary", json: json)
        )
        // optional
        post.content = RegionParser.regions("content", json: json, isRepostContent: repostContent.count > 0)
        post.body = RegionParser.regions("body", json: json, isRepostContent: repostContent.count > 0)
        post.repostContent = repostContent
        post.repostId = json["repost_id"].string
        post.repostPath = json["repost_path"].string
        post.repostViaId = json["repost_via_id"].string
        post.repostViaPath = json["repost_via_path"].string
        post.artistInviteId = json["artist_invite_id"].string
        post.viewsCount = json["views_count"].int
        post.commentsCount = json["comments_count"].int
        post.repostsCount = json["reposts_count"].int
        post.lovesCount = json["loves_count"].int
        // links
        post.links = data["links"] as? [String: Any]
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
