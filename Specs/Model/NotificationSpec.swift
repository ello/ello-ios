////
///  NotificationSpec.swift
//

import Ello
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
                let createdAtDate = NSDate()
                let activity: Activity = stub(["subject": post, "createdAt": createdAtDate, "subjectType": Activity.SubjectType.Post.rawValue, "kind": Activity.Kind.RepostNotification.rawValue])
                let notification = Notification(activity: activity)

                expect(notification.author?.id) == user.id
                expect(notification.createdAt) == createdAtDate
                expect(notification.groupId) == "Notification-\(activity.id)"
                expect(notification.activity.kind) == Activity.Kind.RepostNotification
                expect(notification.activity.subjectType) == Activity.SubjectType.Post
                expect((notification.subject as? Post)?.id) == post.id

                expect(notification.attributedTitle.string) == "@foo reposted your post."
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
                let createdAtDate = NSDate()
                let activity: Activity = stub(["subject": post, "createdAt": createdAtDate, "subjectType": Activity.SubjectType.Post.rawValue, "kind": Activity.Kind.RepostNotification.rawValue])
                let notification = Notification(activity: activity)

                expect(notification.author?.id) == user.id
                expect(notification.createdAt) == createdAtDate
                expect(notification.groupId) == "Notification-\(activity.id)"
                expect(notification.activity.kind) == Activity.Kind.RepostNotification
                expect(notification.activity.subjectType) == Activity.SubjectType.Post
                expect((notification.subject as? Post)?.id) == post.id

                expect(notification.attributedTitle.string) == "@foo reposted your post."
                expect(notification.textRegion?.content) == "<p>summary1!</p><br/><p>summary2!</p>"
                expect(notification.imageRegion?.alt) == imageRegion1.alt
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
                let createdAtDate = NSDate()
                let activity: Activity = stub(["subject": comment, "createdAt": createdAtDate, "subjectType": Activity.SubjectType.Comment.rawValue, "kind": Activity.Kind.CommentMentionNotification.rawValue])
                let notification = Notification(activity: activity)

                expect(notification.author?.id) == user.id
                expect(notification.createdAt) == createdAtDate
                expect(notification.groupId) == "Notification-\(activity.id)"
                expect(notification.activity.kind) == Activity.Kind.CommentMentionNotification
                expect(notification.activity.subjectType) == Activity.SubjectType.Comment
                expect((notification.subject as? ElloComment)?.id) == comment.id

                expect(notification.attributedTitle.string) == "@foo mentioned you in a comment."
                expect(notification.textRegion?.content) == "<p>This is a post summary!</p><br/><p>This is a comment summary!</p>"
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
                let createdAtDate = NSDate()
                let activity: Activity = stub(["subject": comment, "createdAt": createdAtDate, "subjectType": Activity.SubjectType.Comment.rawValue, "kind": Activity.Kind.CommentMentionNotification.rawValue])
                let notification = Notification(activity: activity)

                expect(notification.author?.id) == user.id
                expect(notification.createdAt) == createdAtDate
                expect(notification.groupId) == "Notification-\(activity.id)"
                expect(notification.activity.kind) == Activity.Kind.CommentMentionNotification
                expect(notification.activity.subjectType) == Activity.SubjectType.Comment
                expect((notification.subject as? ElloComment)?.id) == comment.id

                expect(notification.attributedTitle.string) == "@foo mentioned you in a comment."
                expect(notification.textRegion?.content) == "<p>summary1!</p><br/><p>summary2!</p><br/><p>comment summary1!</p><br/><p>comment summary2!</p>"
                expect(notification.imageRegion?.alt) == commentRegion1.alt
            }

            context("NSCoding") {

                var filePath = ""
                if let url = NSURL(string: NSFileManager.ElloDocumentsDir()) {
                    filePath = url.URLByAppendingPathComponent("NotificationSpec")!.absoluteString!
                }

                afterEach {
                    do {
                        try NSFileManager.defaultManager().removeItemAtPath(filePath)
                    }
                    catch {

                    }
                }

                context("encoding") {

                    it("encodes successfully") {
                        let notification: Notification = stub([:])

                        let wasSuccessfulArchived = NSKeyedArchiver.archiveRootObject(notification, toFile: filePath)

                        expect(wasSuccessfulArchived).to(beTrue())
                    }
                }

                context("decoding") {

                    it("decodes successfully") {
                        let expectedCreatedAt = NSDate()

                        let author: User = stub(["id" : "author-id"])

                        let activity: Activity = stub([
                            "subject" : author,
                            "createdAt" : expectedCreatedAt,
                            "id" : "test-notication-id",
                            "kind" : "noise_post",
                            "subjectType" : "Post"
                            ])
                        let notification: Notification = stub(["activity": activity])

                        NSKeyedArchiver.archiveRootObject(notification, toFile: filePath)
                        let unArchivedNotification = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? Notification

                        expect(unArchivedNotification).toNot(beNil())
                        expect(unArchivedNotification?.version) == 1
                        expect(unArchivedNotification?.author?.id) == "author-id"
                        expect(unArchivedNotification?.createdAt) == expectedCreatedAt
                        expect(unArchivedNotification?.activity.id) == "test-notication-id"
                        expect(unArchivedNotification?.activity.kind.rawValue) == Activity.Kind.NoisePost.rawValue
                        expect(unArchivedNotification?.activity.subjectType.rawValue) == Activity.SubjectType.Post.rawValue
                    }
                }
            }
        }
    }
}

