////
///  LoveSpec.swift
//

import Ello
import Quick
import Nimble


class LoveSpec: QuickSpec {
    override func spec() {

        describe("+fromJSON:") {

            it("parses correctly") {
                let data = stubbedJSONData("loves_creating_a_love", "loves")
                let love = Love.fromJSON(data) as! Love

                let createdAtString = "2015-10-22T17:04:06.789Z"
                let createdAt: NSDate = createdAtString.toNSDate()!

                let updatedAtString = "2015-10-22T17:04:06.789Z"
                let updatedAt: NSDate = updatedAtString.toNSDate()!

                // active record
                expect(love.id) == "23"
                expect(love.createdAt) == createdAt
                expect(love.updatedAt) == updatedAt
                // required
                expect(love.deleted) == false
                expect(love.postId) == "222"
                expect(love.userId) == "42"
                expect(love.post).to(beAKindOf(Post.self))
            }
        }

        context("NSCoding") {

            var filePath = ""
            if let url = NSURL(string: NSFileManager.ElloDocumentsDir()) {
                filePath = url.URLByAppendingPathComponent("LoveSpec")!.absoluteString!
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
                    let love: Love = stub([:])

                    let wasSuccessfulArchived = NSKeyedArchiver.archiveRootObject(love, toFile: filePath)

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

                    let love: Love = stub([
                        "user" : user,
                        "post" : post,
                        "id" : "999",
                        "deleted" : true,
                        "createdAt" : expectedCreatedAt,
                        "updatedAt" : expectedUpdatedAt,
                        "postId" : "888",
                        "userId" : "444"
                    ])

                    NSKeyedArchiver.archiveRootObject(love, toFile: filePath)
                    let unArchivedLove = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as! Love

                    expect(unArchivedLove).toNot(beNil())
                    expect(unArchivedLove.version) == 1

                    // active record
                    expect(unArchivedLove.id) == "999"
                    expect(unArchivedLove.createdAt) == expectedCreatedAt
                    expect(unArchivedLove.updatedAt) == expectedUpdatedAt
                    // required
                    expect(unArchivedLove.deleted) == true
                    expect(unArchivedLove.postId) == "888"
                    expect(unArchivedLove.userId) == "444"
                }
            }
        }
    }
}
