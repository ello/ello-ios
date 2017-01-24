////
///  Activity.swift
//

import SwiftyJSON


let ActivityVersion = 1

@objc(Activity)
final class Activity: JSONAble {

    // active record
    let id: String
    let createdAt: Date
    // required
    let kind: Kind
    let subjectType: SubjectType
    // links
    var subject: JSONAble? { return getLinkObject("subject") }

    enum Kind: String {
        // Posts
        case friendPost = "friend_post" // main feed
        case ownPost = "own_post" // main feed
        case welcomePost = "welcome_post" // main feed
        case noisePost = "noise_post" // main feed

        // Comments

        case friendComment = "friend_comment"

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

        // Deprecated posts
        case commentMention = "comment_mention"

        // Fallback for not defined types
        case unknown = "Unknown"
    }

    enum SubjectType: String {
        case user = "User"
        case post = "Post"
        case comment = "Comment"
        case unknown = "Unknown"
    }

// MARK: Initialization

    init(id: String,
        createdAt: Date,
        kind: Kind,
        subjectType: SubjectType)
    {
        self.id = id
        self.createdAt = createdAt
        self.kind = kind
        self.subjectType = subjectType
        super.init(version: ActivityVersion)
    }

// MARK: NSCoding

    required init(coder aDecoder: NSCoder) {
        let decoder = Coder(aDecoder)
        // active record
        self.id = decoder.decodeKey("id")
        self.createdAt = decoder.decodeKey("createdAt")
        // required
        let rawKind: String = decoder.decodeKey("rawKind")
        self.kind = Kind(rawValue: rawKind) ?? Kind.unknown
        let rawSubjectType: String = decoder.decodeKey("rawSubjectType")
        self.subjectType = SubjectType(rawValue: rawSubjectType) ?? SubjectType.unknown
        super.init(coder: decoder.coder)
    }

    override func encode(with encoder: NSCoder) {
        let coder = Coder(encoder)
        // active record
        coder.encodeObject(id, forKey: "id")
        coder.encodeObject(createdAt, forKey: "createdAt")
        // required
        coder.encodeObject(kind.rawValue, forKey: "rawKind")
        coder.encodeObject(subjectType.rawValue, forKey: "rawSubjectType")
        super.encode(with: coder.coder)
    }

// MARK: JSONAble

    override class func fromJSON(_ data: [String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        // active record
        let id = json["created_at"].stringValue
        var createdAt: Date
        if let date = id.toDate() {
            // good to go
            createdAt = date
        }
        else {
            createdAt = Date()
        }

        // create activity
        let activity = Activity(
            id: id,
            createdAt: createdAt,
            kind: Kind(rawValue: json["kind"].stringValue) ?? Kind.unknown,
            subjectType: SubjectType(rawValue: json["subject_type"].stringValue) ?? SubjectType.unknown
        )
        // links
        activity.links = data["links"] as? [String: AnyObject]

        return activity
    }
}

extension Activity: JSONSaveable {
    var uniqueId: String? { if let id = tableId { return "Activity-\(id)" } ; return nil }
    var tableId: String? { return id }

}
