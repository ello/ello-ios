////
///  Activity.swift
//

import SwiftyJSON


let ActivityVersion = 1

@objc(Activity)
final class Activity: Model {

    enum Kind: String {
        // Notifications
        case newFollowerPost = "new_follower_post"  // someone started following you
        case newFollowedUserPost = "new_followed_user_post"  // you started following someone
        case invitationAcceptedPost = "invitation_accepted_post"  // someone accepted your invitation

        case postMentionNotification = "post_mention_notification"  // you were mentioned in a post
        case commentMentionNotification = "comment_mention_notification"  // you were mentioned in a comment
        case commentNotification = "comment_notification"  // someone commented on your post
        case commentOnOriginalPostNotification = "comment_on_original_post_notification"  // someone commented on your repost
        case commentOnRepostNotification = "comment_on_repost_notification"  // someone commented on other's repost of your post

        case welcomeNotification = "welcome_notification"  // welcome to Ello
        case repostNotification = "repost_notification"  // someone reposted your post

        case watchNotification = "watch_notification"  // someone watched your post on ello
        case watchCommentNotification = "watch_comment_notification"  // someone commented on a post you're watching
        case watchOnRepostNotification = "watch_on_repost_notification"  // someone watched your repost
        case watchOnOriginalPostNotification = "watch_on_original_post_notification"  // someone watched other's repost of your post

        case loveNotification = "love_notification"  // someone loved your post
        case loveOnRepostNotification = "love_on_repost_notification"  // someone loved your repost
        case loveOnOriginalPostNotification = "love_on_original_post_notification"  // someone loved other's repost of your post

        case approvedArtistInviteSubmission = "approved_artist_invite_submission"  // your submission has been accepted
        case approvedArtistInviteSubmissionNotificationForFollowers =
            "approved_artist_invite_submission_notification_for_followers"  // a person you follow had their submission accepted

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
    let kind: Kind
    let subjectType: SubjectType

    var subject: Model? { return getLinkObject("subject") }

    init(
        id: String,
        createdAt: Date,
        kind: Kind,
        subjectType: SubjectType
    ) {
        self.id = id
        self.createdAt = createdAt
        self.kind = kind
        self.subjectType = subjectType
        super.init(version: ActivityVersion)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        self.id = decoder.decodeKey("id")
        self.createdAt = decoder.decodeKey("createdAt")
        let rawKind: String = decoder.decodeKey("rawKind")
        self.kind = Kind(rawValue: rawKind) ?? Kind.unknown
        let rawSubjectType: String = decoder.decodeKey("rawSubjectType")
        self.subjectType = SubjectType(rawValue: rawSubjectType) ?? SubjectType.unknown
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

    class func fromJSON(_ data: [String: Any]) -> Activity {
        let json = JSON(data)

        let activity = Activity(
            id: json["created_at"].idValue,
            createdAt: json["created_at"].dateValue,
            kind: Kind(rawValue: json["kind"].stringValue) ?? Kind.unknown,
            subjectType: SubjectType(rawValue: json["subject_type"].stringValue)
                ?? SubjectType.unknown
        )
        activity.mergeLinks(data["links"] as? [String: Any])

        return activity
    }
}

extension Activity: JSONSaveable {
    var uniqueId: String? { return "Activity-\(id)" }
    var tableId: String? { return id }
}
