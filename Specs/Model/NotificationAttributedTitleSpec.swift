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
                var user: User!
                var post: Post!
                var love: Love!
                var comment: ElloComment!
                beforeEach {
                    user = User.stub(["username": "ello"])
                    post = Post.stub(["author": user])
                    love = Love.stub(["user": user])
                    comment = ElloComment.stub(["parentPost": post, "author": user])
                }
                let expectations: [(Notification.Kind, () -> Model, String)] = [
                    (.repostNotification, { return post }, "@ello reposted your post."),
                    (.newFollowedUserPost, { return post }, "You started following @ello."),
                    (.newFollowerPost, { return user }, "@ello started following you."),
                    (.postMentionNotification, { return post }, "@ello mentioned you in a post."),
                    (.commentNotification, { return comment }, "@ello commented on your post."),
                    (.commentMentionNotification, { return comment }, "@ello mentioned you in a comment."),
                    (.commentOnOriginalPostNotification, { return comment }, "@ello commented on your post"),
                    (.commentOnRepostNotification, { return comment }, "@ello commented on your repost."),
                    (.invitationAcceptedPost, { return user }, "@ello accepted your invitation."),
                    (.loveNotification, { return post }, "@ello loved your post."),
                    (.loveOnRepostNotification, { return love }, "@ello loved your repost."),
                    (.loveOnOriginalPostNotification, { return post }, "@ello loved a repost of your post."),
                    (.watchNotification, { return post }, "@ello is watching your post."),
                    (.watchOnRepostNotification, { return post }, "@ello is watching your repost."),
                    (.watchOnOriginalPostNotification, { return post }, "@ello is watching a repost of your post."),
                ]
                for (notificationKind, subject, string) in expectations {
                    it("supports \(notificationKind)") {
                        let notification: Notification = stub([
                            "kind": notificationKind,
                            "subject": subject(),
                            ])
                        expect(NotificationAttributedTitle.from(notification: notification).string) == string
                    }
                }
            }
        }
    }
}
