////
///  ActivitySpec.swift
//

@testable import Ello
import Quick
import Nimble


class ActivitySpec: QuickSpec {
    override func spec() {
        describe("+fromJSON:") {

            context("notifications stream") {
                it("parses repost_notification") {
                    let parsedActivities = stubbedJSONDataArray("activity_streams_notifications", "activities")
                    let activity = Activity.fromJSON(parsedActivities[0]) as! Activity
                    let createdAtStr = "2014-06-15T00:00:00.000Z"
                    let createdAt = createdAtStr.toDate()!
                    // active record
                    expect(activity.id) == createdAtStr
                    expect(activity.createdAt) == createdAt
                    // required
                    expect(activity.kind) == Activity.Kind.repostNotification
                    expect(activity.subjectType) == Activity.SubjectType.post
                    // links
                    expect(activity.subject).to(beAKindOf(Post.self))
                }

                it("parses new_follower_post") {
                    let parsedActivities = stubbedJSONDataArray("activity_streams_notifications", "activities")
                    let activity = Activity.fromJSON(parsedActivities[1]) as! Activity
                    let createdAtStr = "2014-06-14T00:00:00.000Z"
                    let createdAt = createdAtStr.toDate()!
                    // active record
                    expect(activity.id) == createdAtStr
                    expect(activity.createdAt) == createdAt
                    // required
                    expect(activity.kind) == Activity.Kind.newFollowerPost
                    expect(activity.subjectType) == Activity.SubjectType.user
                    // links
                    expect(activity.subject).to(beAKindOf(User.self))
                }

                it("parses love_on_original_post_notification") {
                    let parsedActivities = stubbedJSONDataArray("activity_streams_notifications", "activities")
                    let activity = Activity.fromJSON(parsedActivities[2]) as! Activity
                    let createdAtStr = "2014-06-13T00:00:00.000Z"
                    let createdAt = createdAtStr.toDate()!
                    // active record
                    expect(activity.id) == createdAtStr
                    expect(activity.createdAt) == createdAt
                    // required
                    expect(activity.kind) == Activity.Kind.loveOnOriginalPostNotification
                    expect(activity.subjectType) == Activity.SubjectType.unknown
                    // links
                    expect(activity.subject).to(beAKindOf(Love.self))
                }
            }
        }

        context("NSCoding") {

            var filePath = ""
            if let url = URL(string: FileManager.ElloDocumentsDir()) {
                filePath = url.appendingPathComponent("ActivitySpec").absoluteString
            }

            afterEach {
                do {
                    try FileManager.default.removeItem(atPath: filePath)
                }
                catch {

                }
            }

            context("encoding") {

                it("encodes successfully") {
                    let activity: Activity = stub([:])
                    let wasSuccessfulArchived = NSKeyedArchiver.archiveRootObject(activity, toFile: filePath)
                    expect(wasSuccessfulArchived).to(beTrue())
                }
            }

            context("decoding") {

                it("decodes new_follower_post successfully") {
                    let expectedCreatedAt = Globals.now
                    let post: Post = stub(["id": "768"])
                    let activity: Activity = stub([
                        "subject": post,
                        "id": "456",
                        "kind": "new_follower_post",
                        "subjectType": "Post",
                        "createdAt": expectedCreatedAt
                    ])

                    NSKeyedArchiver.archiveRootObject(activity, toFile: filePath)
                    let unArchivedActivity = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as! Activity

                    expect(unArchivedActivity).toNot(beNil())
                    expect(unArchivedActivity.version) == 1
                    // active record
                    expect(unArchivedActivity.id) == "456"
                    expect(unArchivedActivity.createdAt) == expectedCreatedAt
                    // required
                    expect(unArchivedActivity.kind) == Activity.Kind.newFollowerPost
                    expect(unArchivedActivity.subjectType) == Activity.SubjectType.post
                    // links
                    let unArchivedPost = unArchivedActivity.subject as! Post
                    expect(unArchivedPost).to(beAKindOf(Post.self))
                    expect(unArchivedPost.id) == "768"
                }

                it("decodes post mention successfully") {
                    let expectedCreatedAt = Globals.now
                    let post: Post = stub(["id": "768"])
                    let activity: Activity = stub([
                        "subject": post,
                        "id": "456",
                        "kind": "post_mention_notification",
                        "subjectType": "Post",
                        "createdAt": expectedCreatedAt
                        ])

                    NSKeyedArchiver.archiveRootObject(activity, toFile: filePath)
                    let unArchivedActivity = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as! Activity

                    expect(unArchivedActivity).toNot(beNil())
                    expect(unArchivedActivity.version) == 1
                    // active record
                    expect(unArchivedActivity.id) == "456"
                    expect(unArchivedActivity.createdAt) == expectedCreatedAt
                    // required
                    expect(unArchivedActivity.kind) == Activity.Kind.postMentionNotification
                    expect(unArchivedActivity.subjectType) == Activity.SubjectType.post
                    // links
                    let unArchivedPost = unArchivedActivity.subject as! Post
                    expect(unArchivedPost).to(beAKindOf(Post.self))
                    expect(unArchivedPost.id) == "768"
                }
            }
        }
    }
}
