////
///  Activity.swift
//

import Crashlytics
import SwiftyJSON

let ActivityVersion = 1

@objc(Activity)
public final class Activity: JSONAble {

    // active record
    public let id: String
    public let createdAt: NSDate
    // required
    public let kind: Kind
    public let subjectType: SubjectType
    // links
    public var subject: JSONAble? { return getLinkObject("subject") }

    public enum Kind: String {
        // Posts
        case FriendPost = "friend_post" // main feed
        case OwnPost = "own_post" // main feed
        case WelcomePost = "welcome_post" // main feed
        case NoisePost = "noise_post" // main feed

        // Comments

        case FriendComment = "friend_comment"

        // Notifications
        case NewFollowerPost = "new_follower_post" // someone started following you
        case NewFollowedUserPost = "new_followed_user_post" // you started following someone
        case InvitationAcceptedPost = "invitation_accepted_post" // someone accepted your invitation

        case PostMentionNotification = "post_mention_notification" // you were mentioned in a post
        case CommentMentionNotification = "comment_mention_notification" // you were mentioned in a comment
        case CommentNotification = "comment_notification" // someone commented on your post
        case CommentOnOriginalPostNotification = "comment_on_original_post_notification" // someone commented on your repost
        case CommentOnRepostNotification = "comment_on_repost_notification" // someone commented on other's repost of your post

        case WelcomeNotification = "welcome_notification" // welcome to Ello
        case RepostNotification = "repost_notification" // someone reposted your post

        case WatchNotification = "watch_notification" // someone watched your post on ello
        case WatchOnRepostNotification = "watch_on_repost_notification" // someone watched your repost
        case WatchOnOriginalPostNotification = "watch_on_original_post_notification" // someone watched other's repost of your post
        case WatchCommentNotification = "watch_comment_notification"

        case LoveNotification = "love_notification" // someone loved your post
        case LoveOnRepostNotification = "love_on_repost_notification" // someone loved your repost
        case LoveOnOriginalPostNotification = "love_on_original_post_notification" // someone loved other's repost of your post

        // Deprecated posts
        case CommentMention = "comment_mention"

        // Fallback for not defined types
        case Unknown = "Unknown"
    }

    public enum SubjectType: String {
        case User = "User"
        case Post = "Post"
        case Comment = "Comment"
        case Unknown = "Unknown"
    }

// MARK: Initialization

    public init(id: String,
        createdAt: NSDate,
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

    public required init(coder aDecoder: NSCoder) {
        let decoder = Coder(aDecoder)
        // active record
        self.id = decoder.decodeKey("id")
        self.createdAt = decoder.decodeKey("createdAt")
        // required
        let rawKind: String = decoder.decodeKey("rawKind")
        self.kind = Kind(rawValue: rawKind) ?? Kind.Unknown
        let rawSubjectType: String = decoder.decodeKey("rawSubjectType")
        self.subjectType = SubjectType(rawValue: rawSubjectType) ?? SubjectType.Unknown
        super.init(coder: decoder.coder)
    }

    public override func encodeWithCoder(encoder: NSCoder) {
        let coder = Coder(encoder)
        // active record
        coder.encodeObject(id, forKey: "id")
        coder.encodeObject(createdAt, forKey: "createdAt")
        // required
        coder.encodeObject(kind.rawValue, forKey: "rawKind")
        coder.encodeObject(subjectType.rawValue, forKey: "rawSubjectType")
        super.encodeWithCoder(coder.coder)
    }

// MARK: JSONAble

    override public class func fromJSON(data: [String: AnyObject], fromLinked: Bool = false) -> JSONAble {
        let json = JSON(data)
        Crashlytics.sharedInstance().setObjectValue(json.rawString(), forKey: CrashlyticsKey.ActivityFromJSON.rawValue)
        // active record
        let id = json["created_at"].stringValue
        var createdAt: NSDate
        if let date = id.toNSDate() {
            // good to go
            createdAt = date
        }
        else {
            createdAt = NSDate()
            // send data to segment to try to get more data about this
            Tracker.sharedTracker.createdAtCrash("Activity", json: json.rawString())
        }
        // create activity
        let activity = Activity(
            id: id,
            createdAt: createdAt,
            kind: Kind(rawValue: json["kind"].stringValue) ?? Kind.Unknown,
            subjectType: SubjectType(rawValue: json["subject_type"].stringValue) ?? SubjectType.Unknown
        )
        // links
        activity.links = data["links"] as? [String: AnyObject]
        // store self in collection
        if !fromLinked {
            ElloLinkedStore.sharedInstance.setObject(activity, forKey: activity.id, inCollection: MappingType.ActivitiesType.rawValue)
        }
        return activity
    }
}
