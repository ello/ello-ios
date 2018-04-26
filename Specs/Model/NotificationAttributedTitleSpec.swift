////
///  NotificationAttributedTitleSpec.swift
//

@testable import Ello
import Quick
import Nimble


class NotificationAttributedTitleSpec: QuickSpec {
    override func spec() {
        describe("NotificationAttributedTitle") {
            describe("from(notification:)") {
                let user: User = stub(["username": "ello"])
                let post: Post = stub(["author": user])
                let love: Love = stub(["user": user])
                let comment: ElloComment = stub(["parentPost": post, "author": user])
                let expectations: [(Activity.Kind, Model, String)] = [
                    (.repostNotification, post, "@ello reposted your post."),
                    (.newFollowedUserPost, post, "You started following @ello."),
                    (.newFollowerPost, user, "@ello started following you."),
                    (.postMentionNotification, post, "@ello mentioned you in a post."),
                    (.commentNotification, comment, "@ello commented on your post."),
                    (.commentMentionNotification, comment, "@ello mentioned you in a comment."),
                    (.commentOnOriginalPostNotification, comment, "@ello commented on your post"),
                    (.commentOnRepostNotification, comment, "@ello commented on your repost."),
                    (.invitationAcceptedPost, user, "@ello accepted your invitation."),
                    (.loveNotification, post, "@ello loved your post."),
                    (.loveOnRepostNotification, love, "@ello loved your repost."),
                    (.loveOnOriginalPostNotification, post, "@ello loved a repost of your post."),
                    (.watchNotification, post, "@ello is watching your post."),
                    (.watchOnRepostNotification, post, "@ello is watching your repost."),
                    (.watchOnOriginalPostNotification, post, "@ello is watching a repost of your post."),
                ]
                for (activityKind, subject, string) in expectations {
                    it("supports \(activityKind)") {
                        let activity: Activity = stub([
                            "kind": activityKind,
                            "subject": subject,
                            ])
                        let notification = Notification(activity: activity)
                        notification.author = user
                        expect(NotificationAttributedTitle.from(notification: notification).string) == string
                    }
                }
            }
        }
    }
}
