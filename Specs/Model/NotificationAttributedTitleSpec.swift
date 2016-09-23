////
///  NotificationAttributedTitleSpec.swift
//

@testable
import Ello
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
                    (.RepostNotification, post, "@ello reposted your post."),
                    (.NewFollowedUserPost, post, "You started following @ello."),
                    (.NewFollowerPost, user, "@ello started following you."),
                    (.PostMentionNotification, post, "@ello mentioned you in a post."),
                    (.CommentNotification, comment, "@ello commented on your post."),
                    (.CommentMentionNotification, comment, "@ello mentioned you in a comment."),
                    (.CommentOnOriginalPostNotification, comment, "@ello commented on your post"),
                    (.CommentOnRepostNotification, comment, "@ello commented on your repost."),
                    (.InvitationAcceptedPost, user, "@ello accepted your invitation."),
                    (.LoveNotification, post, "@ello loved your post."),
                    (.LoveOnRepostNotification, post, "@ello loved your repost."),
                    (.LoveOnOriginalPostNotification, post, "@ello loved a repost of your post."),
                    (.WatchNotification, post, "@ello watched your post."),
                    (.WatchOnRepostNotification, post, "@ello watched your repost."),
                    (.WatchOnOriginalPostNotification, post, "@ello watched a repost of your post."),
                    (.WelcomeNotification, nil, "Welcome to Ello!"),
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
