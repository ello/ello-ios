////
///  Notification.swift
//

let NotificationVersion = 1

@objc(Notification)
final class Notification: Model, Authorable {

    let activity: Activity
    var author: User?
    // if postId is present, this notification is opened using "PostDetailViewController"
    var postId: String?
    var createdAt: Date { return activity.createdAt }
    var subject: Model? { willSet { attributedTitleStore = nil } }

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
        else if let submission = activity.subject as? CategoryPost,
            let featuredBy = submission.featuredBy
        {
            self.author = featuredBy
        }
        else if let actionable = activity.subject as? PostActionable,
            let user = actionable.user
        {
            self.postId = actionable.postId
            self.author = user
        }

        super.init(version: NotificationVersion)

        var postSummary: [Regionable]?
        var postParentSummary: [Regionable]?

        if let post = activity.subject as? Post {
            postSummary = post.summary
        }
        else if let submission = activity.subject as? CategoryPost,
            let post = submission.post
        {
            postSummary = post.summary
        }
        else if let comment = activity.subject as? ElloComment {
            let content = !comment.summary.isEmpty ? comment.summary : comment.content
            let parentSummary = comment.parentPost?.summary
            postSummary = content
            postParentSummary = parentSummary
        }
        else if let post = (activity.subject as? PostActionable)?.post {
            postSummary = post.summary
        }

        if let postSummary = postSummary {
            assignRegionsFromContent(postSummary, parentSummary: postParentSummary)
        }

        subject = activity.subject
    }

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
                else if let newImageRegion = region as? ImageRegion, parentImage == nil {
                    parentImage = newImageRegion
                }
            }
        }

        for region in content {
            if let newTextRegion = region as? TextRegion {
                textContent.append(newTextRegion.content)
            }
            else if let newImageRegion = region as? ImageRegion, contentImage == nil {
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
