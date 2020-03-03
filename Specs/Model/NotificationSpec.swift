////
///  NotificationSpec.swift
//

@testable import Ello
import Quick
import Nimble


class NotificationSpec: QuickSpec {
    override func spec() {
        describe("Notification") {
            it("converts post summary to Notification") {
                let user: User = stub(["username": "foo"])
                let post: Post = stub([
                    "author": user,
                    "summary": [TextRegion(content: "<p>This is a post summary!</p>")]
                ])
                let createdAtDate = Globals.now
                let activity: Activity = stub([
                    "subject": post, "createdAt": createdAtDate,
                    "subjectType": Activity.SubjectType.post.rawValue,
                    "kind": Activity.Kind.repostNotification.rawValue
                ])
                let notification = Notification(activity: activity)

                expect(notification.author?.id) == user.id
                expect(notification.createdAt) == createdAtDate
                expect(notification.activity.kind) == Activity.Kind.repostNotification
                expect(notification.activity.subjectType) == Activity.SubjectType.post
                expect((notification.subject as? Post)?.id) == post.id

                expect(NotificationAttributedTitle.from(notification: notification).string)
                    == "@foo reposted your post."
                expect(notification.textRegion?.content) == "<p>This is a post summary!</p>"
                expect(notification.imageRegion).to(beNil())
            }

            it("converts post summary with many regions to Notification") {
                let user: User = stub(["username": "foo"])
                let imageRegion1: ImageRegion = stub(["alt": "imageRegion1"])
                let imageRegion2: ImageRegion = stub(["alt": "imageRegion2"])
                let post: Post = stub([
                    "author": user,
                    "summary": [
                        TextRegion(content: "<p>summary1!</p>"),
                        imageRegion1,
                        TextRegion(content: "<p>summary2!</p>"),
                        imageRegion2,
                    ]
                ])
                let createdAtDate = Globals.now
                let activity: Activity = stub([
                    "subject": post, "createdAt": createdAtDate,
                    "subjectType": Activity.SubjectType.post.rawValue,
                    "kind": Activity.Kind.repostNotification.rawValue
                ])
                let notification = Notification(activity: activity)

                expect(notification.author?.id) == user.id
                expect(notification.createdAt) == createdAtDate
                expect(notification.activity.kind) == Activity.Kind.repostNotification
                expect(notification.activity.subjectType) == Activity.SubjectType.post
                expect((notification.subject as? Post)?.id) == post.id

                expect(NotificationAttributedTitle.from(notification: notification).string)
                    == "@foo reposted your post."
                expect(notification.textRegion?.content) == "<p>summary1!</p><br/><p>summary2!</p>"
            }

            it("converts comment summary and parent post to Notification") {
                let user: User = stub(["username": "foo"])
                let post: Post = stub([
                    "author": user,
                    "summary": [TextRegion(content: "<p>This is a post summary!</p>")]
                ])
                let comment: ElloComment = stub([
                    "parentPost": post,
                    "author": user,
                    "summary": [TextRegion(content: "<p>This is a comment summary!</p>")]
                ])
                let createdAtDate = Globals.now
                let activity: Activity = stub([
                    "subject": comment, "createdAt": createdAtDate,
                    "subjectType": Activity.SubjectType.comment.rawValue,
                    "kind": Activity.Kind.commentMentionNotification.rawValue
                ])
                let notification = Notification(activity: activity)

                expect(notification.author?.id) == user.id
                expect(notification.createdAt) == createdAtDate
                expect(notification.activity.kind) == Activity.Kind.commentMentionNotification
                expect(notification.activity.subjectType) == Activity.SubjectType.comment
                expect((notification.subject as? ElloComment)?.id) == comment.id

                expect(NotificationAttributedTitle.from(notification: notification).string)
                    == "@foo mentioned you in a comment."
                expect(notification.textRegion?.content)
                    == "<p>This is a post summary!</p><br/><p>This is a comment summary!</p>"
                expect(notification.imageRegion).to(beNil())
            }

            it("converts comment summary and parent post with many regions to Notification") {
                let user: User = stub(["username": "foo"])
                let imageRegion1: ImageRegion = stub(["alt": "imageRegion1"])
                let imageRegion2: ImageRegion = stub(["alt": "imageRegion2"])
                let commentRegion1: ImageRegion = stub(["alt": "commentRegion1"])
                let commentRegion2: ImageRegion = stub(["alt": "commentRegion2"])
                let post: Post = stub([
                    "author": user,
                    "summary": [
                        TextRegion(content: "<p>summary1!</p>"),
                        imageRegion1,
                        TextRegion(content: "<p>summary2!</p>"),
                        imageRegion2,
                    ]
                ])
                let comment: ElloComment = stub([
                    "parentPost": post,
                    "author": user,
                    "summary": [
                        TextRegion(content: "<p>comment summary1!</p>"),
                        commentRegion1,
                        TextRegion(content: "<p>comment summary2!</p>"),
                        commentRegion2,
                    ]
                ])
                let createdAtDate = Globals.now
                let activity: Activity = stub([
                    "subject": comment, "createdAt": createdAtDate,
                    "subjectType": Activity.SubjectType.comment.rawValue,
                    "kind": Activity.Kind.commentMentionNotification.rawValue
                ])
                let notification = Notification(activity: activity)

                expect(notification.author?.id) == user.id
                expect(notification.createdAt) == createdAtDate
                expect(notification.activity.kind) == Activity.Kind.commentMentionNotification
                expect(notification.activity.subjectType) == Activity.SubjectType.comment
                expect((notification.subject as? ElloComment)?.id) == comment.id

                expect(NotificationAttributedTitle.from(notification: notification).string)
                    == "@foo mentioned you in a comment."
                expect(notification.textRegion?.content)
                    == "<p>summary1!</p><br/><p>summary2!</p><br/><p>comment summary1!</p><br/><p>comment summary2!</p>"
            }
        }
    }
}
