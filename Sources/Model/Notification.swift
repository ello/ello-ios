////
///  Notification.swift
//

enum NotificationFilterType: String {
    case all = "NotificationFilterTypeAll"
    case comments = "NotificationFilterTypeComments"
    case mention = "NotificationFilterTypeMention"
    case heart = "NotificationFilterTypeHeart"
    case repost = "NotificationFilterTypeRepost"
    case relationship = "NotificationFilterTypeRelationship"

    var category: String? {
        switch self {
        case .all:
            return nil
        case .comments:  // …
            return "comments"
        case .mention:  // @
            return "mentions"
        case .heart:
            return "loves"
        case .repost:
            return "reposts"
        case .relationship:
            return "relationships"
        }
    }

    static func fromCategory(_ categoryString: String?) -> NotificationFilterType {
        let category = categoryString ?? ""
        switch category {
        case "comments": return .comments
        case "mentions": return .mention
        case "loves": return .heart
        case "reposts": return .repost
        case "relationships": return .relationship
        default: return .all
        }
    }
}

let NotificationVersion = 1

@objc(Notification)
final class Notification: JSONAble, Authorable, Groupable {

    let activity: Activity
    var author: User?
    // if postId is present, this notification is opened using "PostDetailViewController"
    var postId: String?
    // computed
    var createdAt: Date { return activity.createdAt as Date }
    var groupId: String { return "Notification-\(activity.id)" }
    var subject: JSONAble? { willSet { attributedTitleStore = nil } }

    // notification specific
    var textRegion: TextRegion?
    var imageRegion: ImageRegion?
    private var attributedTitleStore: NSAttributedString?

    var hasImage: Bool {
        return self.imageRegion != nil
    }
    var canReplyToComment: Bool {
        switch activity.kind {
        case .postMentionNotification,
            .commentNotification,
            .commentMentionNotification,
            .commentOnOriginalPostNotification,
            .commentOnRepostNotification:
            return true
        default:
            return false
        }
    }
    var canBackFollow: Bool {
        return false // activity.kind == .newFollowerPost
    }

    var isValidKind: Bool {
        return activity.kind != .unknown
    }

// MARK: Initialization

    init(activity: Activity) {
        self.activity = activity

        if let post = activity.subject as? Post {
            self.author = post.author
            self.postId = post.id
        }
        else if let comment = activity.subject as? ElloComment {
            self.author = comment.author
            self.postId = comment.postId
        }
        else if let user = activity.subject as? User {
            self.author = user
        }
        else if let actionable = activity.subject as? PostActionable,
            let user = actionable.user
        {
            self.postId = actionable.postId
            self.author = user
        }

        super.init(version: NotificationVersion)

        if let post = activity.subject as? Post {
            assignRegionsFromContent(post.summary)
        }
        else if let comment = activity.subject as? ElloComment {
            let parentSummary = comment.parentPost?.summary
            if let summary = comment.summary {
                assignRegionsFromContent(summary, parentSummary: parentSummary)
            }
            else {
                assignRegionsFromContent(comment.content, parentSummary: parentSummary)
            }
        }
        else if let post = (activity.subject as? Love)?.post {
            assignRegionsFromContent(post.summary)
        }

        subject = activity.subject
    }

// MARK: NSCoding

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        self.activity = decoder.decodeKey("activity")
        self.author = decoder.decodeOptionalKey("author")
        super.init(coder: coder)
    }

    override func encode(with encoder: NSCoder) {
        let coder = Coder(encoder)
        coder.encodeObject(activity, forKey: "activity")
        coder.encodeObject(author, forKey: "author")
        super.encode(with: coder.coder)
    }

// MARK: Private

    private func assignRegionsFromContent(_ content: [Regionable], parentSummary: [Regionable]? = nil) {
        // assign textRegion and imageRegion from the post content - finds
        // the first of both kinds of regions
        var textContent: [String] = []
        var parentImage: ImageRegion?
        var contentImage: ImageRegion?

        if let parentSummary = parentSummary {
            for region in parentSummary {
                if let newTextRegion = region as? TextRegion {
                    textContent.append(newTextRegion.content)
                }
                else if let newImageRegion = region as? ImageRegion, parentImage == nil
                {
                    parentImage = newImageRegion
                }
            }
        }

        for region in content {
            if let newTextRegion = region as? TextRegion {
                textContent.append(newTextRegion.content)
            }
            else if let newImageRegion = region as? ImageRegion, contentImage == nil
            {
                contentImage = newImageRegion
            }
        }

        imageRegion = contentImage ?? parentImage
        textRegion = TextRegion(content: textContent.joined(separator: "<br/>"))
    }
}

extension Notification: JSONSaveable {
    var uniqueId: String? { return "Notification-\(activity.id)" }
    var tableId: String? { return activity.id }

}
