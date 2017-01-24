////
///  NotificationAttributedTitleSpec.swift
//

@testable import Ello
import Quick
import Nimble


class NotificationAttributedTitleSpec: QuickSpec {
    override func spec() {
        describe("NotificationAttributedTitle") {
            describe("attributedTitle(_: Activity.Kind, author: User?, subject: JSONAble?)") {
                let user: User = stub(["username": "ello"])
                let post: Post = stub([:])
                let comment: ElloComment = stub(["parentPost": post])
                let expectations: [(Activity.Kind, JSONAble?, String)] = [
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
                    (.loveOnRepostNotification, post, "@ello loved your repost."),
                    (.loveOnOriginalPostNotification, post, "@ello loved a repost of your post."),
                    (.watchNotification, post, "@ello is watching your post."),
                    (.watchOnRepostNotification, post, "@ello is watching your repost."),
                    (.watchOnOriginalPostNotification, post, "@ello is watching a repost of your post."),
                    (.welcomeNotification, nil, "Welcome to Ello!"),
                ]
                for (activityKind, subject, string) in expectations {
                    it("supports \(activityKind)") {
                        expect(NotificationAttributedTitle.attributedTitle(activityKind, author: user, subject: subject).string) == string
                    }
                }
            }
        }
    }
}
