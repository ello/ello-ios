////
///  Notification.swift
//

import SwiftyJSON

@objc(Notification)
final class Notification: Model, Authorable {
    static let Version = 1
    enum Kind: String {
        // Notifications
        case newFollowerPost = "new_follower_post" // someone started following you
        case newFollowedUserPost = "new_followed_user_post" // you started following someone
        case invitationAcceptedPost = "invitation_accepted_post" // someone accepted your invitation

        case postMentionNotification = "post_mention_notification" // you were mentioned in a post
        case commentMentionNotification = "comment_mention_notification" // you were mentioned in a comment
        case commentNotification = "comment_notification" // someone commented on your post
        case commentOnOriginalPostNotification = "comment_on_original_post_notification" // someone commented on your repost
        case commentOnRepostNotification = "comment_on_repost_notification" // someone commented on other's repost of your post

        case welcomeNotification = "welcome_notification" // welcome to Ello
        case repostNotification = "repost_notification" // someone reposted your post

        case watchNotification = "watch_notification" // someone watched your post on ello
        case watchCommentNotification = "watch_comment_notification" // someone commented on a post you're watching
        case watchOnRepostNotification = "watch_on_repost_notification" // someone watched your repost
        case watchOnOriginalPostNotification = "watch_on_original_post_notification" // someone watched other's repost of your post

        case loveNotification = "love_notification" // someone loved your post
        case loveOnRepostNotification = "love_on_repost_notification" // someone loved your repost
        case loveOnOriginalPostNotification = "love_on_original_post_notification" // someone loved other's repost of your post

        case approvedArtistInviteSubmission = "approved_artist_invite_submission" // your submission has been accepted
        case approvedArtistInviteSubmissionNotificationForFollowers = "approved_artist_invite_submission_notification_for_followers" // a person you follow had their submission accepted

        case categoryPostFeatured = "category_post_featured"
        case categoryRepostFeatured = "category_repost_featured"
        case categoryPostViaRepostFeatured = "category_post_via_repost_featured"

        case userAddedAsFeatured = "user_added_as_featured_notification"
        case userAddedAsCurator = "user_added_as_curator_notification"
        case userAddedAsModerator = "user_added_as_moderator_notification"

        // Fallback for not defined types
        case unknown = "Unknown"
    }

    enum SubjectType: String {
        case user = "User"
        case post = "Post"
        case comment = "Comment"
        case categoryPost = "CategoryPost"
        case unknown = "Unknown"
    }

    let id: String
    let createdAt: Date
    let kind: Notification.Kind
    let subjectType: Notification.SubjectType

    var subject: Model? { return getLinkObject("subject") }

    var author: User? { return subjectAuthor() }
    var postId: String? { return subjectPostId() }

    private var regions: (TextRegion?, ImageRegion?)?
    var textRegion: TextRegion? {
        guard let regions = regions else {
            return assignRegionsFromContent().0
        }
        return regions.0
    }
    var imageRegion: ImageRegion? {
        guard let regions = regions else {
            return assignRegionsFromContent().1
        }
        return regions.1
    }

    var hasImage: Bool {
        return self.imageRegion != nil
    }
    var canReplyToComment: Bool {
        switch kind {
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
        return false // kind == .newFollowerPost
    }

    var isValidKind: Bool {
        return kind != .unknown
    }

    init(id: String,
        createdAt: Date,
        kind: Notification.Kind,
        subjectType: Notification.SubjectType)
    {
        self.id = id
        self.createdAt = createdAt
        self.kind = kind
        self.subjectType = subjectType

        super.init(version: Notification.Version)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        self.id = decoder.decodeKey("id")
        self.createdAt = decoder.decodeKey("createdAt")
        let rawKind: String = decoder.decodeKey("rawKind")
        self.kind = Notification.Kind(rawValue: rawKind) ?? .unknown
        let rawSubjectType: String = decoder.decodeKey("rawSubjectType")
        self.subjectType = Notification.SubjectType(rawValue: rawSubjectType) ?? .unknown
        super.init(coder: coder)
    }

    override func encode(with encoder: NSCoder) {
        let coder = Coder(encoder)
        coder.encodeObject(id, forKey: "id")
        coder.encodeObject(createdAt, forKey: "createdAt")
        coder.encodeObject(kind.rawValue, forKey: "rawKind")
        coder.encodeObject(subjectType.rawValue, forKey: "rawSubjectType")
        super.encode(with: coder.coder)
    }

    class func fromJSON(_ data: [String: Any]) -> Notification {
        let json = JSON(data)

        let notification = Notification(
            id: json["created_at"].stringValue,
            createdAt: json["created_at"].dateValue,
            kind: Kind(rawValue: json["kind"].stringValue) ?? .unknown,
            subjectType: SubjectType(rawValue: json["subject_type"].stringValue) ?? .unknown
        )
        notification.mergeLinks(data["links"] as? [String: Any])

        return notification
    }

    func subjectAuthor() -> User? {
        if let post = subject as? Post {
            return post.author
        }
        else if let comment = subject as? ElloComment {
            return comment.author
        }
        else if let user = subject as? User {
            return user
        }
        else if let submission = subject as? CategoryPost,
            let featuredBy = submission.featuredBy
        {
            return featuredBy
        }
        else if let submission = subject as? CategoryUser {
            switch submission.role {
            case .featured:
                return submission.featuredBy
            case .curator:
                return submission.curatorBy
            case .moderator:
                return submission.moderatorBy
            case .unspecified:
                break
            }
        }
        else if let actionable = subject as? PostActionable {
            return actionable.user
        }
        return nil
    }

    func subjectPostId() -> String? {
        if let post = subject as? Post {
            return post.id
        }
        else if let comment = subject as? ElloComment {
            return comment.postId
        }
        else if let actionable = subject as? PostActionable {
            return actionable.postId
        }
        return nil
    }

    private func assignRegionsFromContent() -> (TextRegion?, ImageRegion?) {
        var postSummary: [Regionable]?
        var parentSummary: [Regionable]?

        if let post = subject as? Post {
            postSummary = post.summary
        }
        else if let submission = subject as? CategoryPost,
            let post = submission.post
        {
            postSummary = post.summary
        }
        else if let comment = subject as? ElloComment {
            let content = !comment.summary.isEmpty ? comment.summary : comment.content
            postSummary = content
            parentSummary = comment.parentPost?.summary
        }
        else if let post = (subject as? PostActionable)?.post {
            postSummary = post.summary
        }

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

        if let content = postSummary {
            for region in content {
                if let newTextRegion = region as? TextRegion {
                    textContent.append(newTextRegion.content)
                }
                else if let newImageRegion = region as? ImageRegion, contentImage == nil {
                    contentImage = newImageRegion
                }
            }
        }

        let imageRegion = contentImage ?? parentImage
        let textRegion: TextRegion? = TextRegion(content: textContent.joined(separator: "<br/>"))
        let regions = (textRegion, imageRegion)
        self.regions = regions
        return regions
    }
}

extension Notification: JSONSaveable {
    var uniqueId: String? { return "Notification-\(id)" }
    var tableId: String? { return id }
}
