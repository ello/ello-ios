////
///  WatchSpec.swift
//

import Ello
import Quick
import Nimble


class WatchSpec: QuickSpec {
    override func spec() {

        describe("+fromJSON:") {

            it("parses correctly") {
                let data = stubbedJSONData("watches_creating_a_watch", "watches")
                let watch = Watch.fromJSON(data) as! Watch

                let createdAtString = "2015-10-22T17:04:06.789Z"
                let createdAt: NSDate = createdAtString.toNSDate()!

                let updatedAtString = "2015-10-22T17:04:06.789Z"
                let updatedAt: NSDate = updatedAtString.toNSDate()!

                // active record
                expect(watch.id) == "23"
                expect(watch.createdAt) == createdAt
                expect(watch.updatedAt) == updatedAt
                // required
                expect(watch.deleted) == false
                expect(watch.postId) == "222"
                expect(watch.userId) == "42"
                expect(watch.post).to(beAKindOf(Post.self))
            }
        }

        context("NSCoding") {

            var filePath = ""
            if let url = NSURL(string: NSFileManager.ElloDocumentsDir()) {
                filePath = url.URLByAppendingPathComponent("WatchSpec")!.absoluteString!
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
                    let watch: Watch = stub([:])

                    let wasSuccessfulArchived = NSKeyedArchiver.archiveRootObject(watch, toFile: filePath)

                    expect(wasSuccessfulArchived).to(beTrue())
                }
            }

            context("decoding") {

                it("decodes successfully") {
                    let expectedCreatedAt = NSDate()
                    let expectedUpdatedAt = NSDate()

                    let user: User = stub([
                        "id" : "444"
                    ])

                    let post: Post = stub([
                        "id" : "888"
                    ])

                    let watch: Watch = stub([
                        "user" : user,
                        "post" : post,
                        "id" : "999",
                        "deleted" : true,
                        "createdAt" : expectedCreatedAt,
                        "updatedAt" : expectedUpdatedAt,
                        "postId" : "888",
                        "userId" : "444"
                    ])

                    NSKeyedArchiver.archiveRootObject(watch, toFile: filePath)
                    let unArchivedWatch = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as! Watch

                    expect(unArchivedWatch).toNot(beNil())
                    expect(unArchivedWatch.version) == 1

                    // active record
                    expect(unArchivedWatch.id) == "999"
                    expect(unArchivedWatch.createdAt) == expectedCreatedAt
                    expect(unArchivedWatch.updatedAt) == expectedUpdatedAt
                    // required
                    expect(unArchivedWatch.deleted) == true
                    expect(unArchivedWatch.postId) == "888"
                    expect(unArchivedWatch.userId) == "444"
                }
            }
        }
    }
}
