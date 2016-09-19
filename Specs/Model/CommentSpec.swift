////
///  CommentSpec.swift
//

import Ello
import Quick
import Nimble

class CommentSpec: QuickSpec {
    override func spec() {
        describe("+fromJSON:") {

            it("parses correctly") {
                // add stubs for references in json
                ElloLinkedStore.sharedInstance.setObject(Post.stub(["id": "79"]), forKey: "79", inCollection: MappingType.PostsType.rawValue)
                ElloLinkedStore.sharedInstance.setObject(User.stub(["userId": "420"]), forKey: "420", inCollection: MappingType.UsersType.rawValue)

                let parsedComment = stubbedJSONData("comments_comment_details", "comments")

                let createdAtString = "2014-06-02T00:00:00.000Z"
                let comment = ElloComment.fromJSON(parsedComment) as! ElloComment
                var createdAt: NSDate = createdAtString.toNSDate()!
                // active record
                expect(comment.createdAt) == createdAt
                // required
                expect(comment.postId) == "79"
                expect(comment.content.count) == 2
                expect(comment.content[0].kind) == "text"
                expect(comment.content[1].kind) == "image"
                // links
                expect(comment.author).to(beAKindOf(User.self))
                expect(comment.parentPost).to(beAKindOf(Post.self))
                expect(comment.loadedFromPost).to(beAKindOf(Post.self))
                expect(comment.assets!.count) == 1
                expect(comment.assets![0]).to(beAKindOf(Asset.self))
                // computed
                expect(comment.groupId) == "Post-\(comment.postId)"
            }
        }

        context("parentPost vs loadedFromPost") {
            it("defaults to parentPost") {
                let post = Post.stub([:])
                let comment = ElloComment.stub([
                    "parentPost": post,
                    ])
                expect(comment.postId) == post.id
                expect(comment.loadedFromPostId) == post.id
                expect(comment.parentPost).toNot(beNil())
                expect(comment.loadedFromPost).toNot(beNil())
            }
            it("can have both") {
                let post1 = Post.stub([:])
                let post2 = Post.stub([:])
                let comment = ElloComment.stub([
                    "parentPost": post1,
                    "loadedFromPost": post2
                    ])
                expect(comment.postId) == post1.id
                expect(comment.loadedFromPostId) == post2.id
                expect(comment.parentPost).toNot(beNil())
                expect(comment.loadedFromPost).toNot(beNil())
            }
        }

        context("NSCoding") {

            var filePath = ""
            if let url = NSURL(string: NSFileManager.ElloDocumentsDir()) {
                filePath = url.URLByAppendingPathComponent("CommentSpec")!.absoluteString!
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
                    let comment: ElloComment = stub([:])
                    let wasSuccessfulArchived = NSKeyedArchiver.archiveRootObject(comment, toFile: filePath)
                    expect(wasSuccessfulArchived).to(beTrue())
                }
            }

            context("decoding") {

                func testRegionContent(content: [Regionable]) {
                    expect(content.count) == 2
                    let textRegion = content[0] as! TextRegion
                    let imageRegion = content[1] as! ImageRegion
                    let imageAsset = imageRegion.asset!
                    expect(textRegion.content) == "I am your comment's content"
                    expect(imageRegion.alt) == "sample-alt"
                    expect(imageRegion.url?.absoluteString) == "http://www.example5.com"
                    expect(imageAsset.id) == "qwerty"

                    let assetXhdpi = imageAsset.xhdpi!
                    expect(assetXhdpi.url.absoluteString) == "http://www.example2.com"
                    expect(assetXhdpi.width) == 112
                    expect(assetXhdpi.height) == 98
                    expect(assetXhdpi.size) == 5673
                    expect(assetXhdpi.type) == "png"

                    let assetHDPI = imageAsset.hdpi!
                    expect(assetHDPI.url.absoluteString) == "http://www.example.com"
                    expect(assetHDPI.width) == 887
                    expect(assetHDPI.height) == 122
                    expect(assetHDPI.size) == 666987
                    expect(assetHDPI.type) == "jpeg"
                }

                it("decodes successfully") {
                    let expectedCreatedAt = NSDate()

                    let parentPost: Post = stub([
                        "id" : "sample-parent-post-id"
                    ])

                    let author: User = stub([
                        "id" : "sample-author-id"
                    ])

                    let hdpi: Attachment = stub([
                        "url" : NSURL(string: "http://www.example.com")!,
                        "height" : 122,
                        "width" : 887,
                        "type" : "jpeg",
                        "size" : 666987
                    ])

                    let xhdpi: Attachment = stub([
                        "url" : NSURL(string: "http://www.example2.com")!,
                        "height" : 98,
                        "width" : 112,
                        "type" : "png",
                        "size" : 5673
                    ])

                    let asset: Asset = stub([
                        "id" : "qwerty",
                        "hdpi" : hdpi,
                        "xhdpi" : xhdpi
                    ])

                    let textRegion: TextRegion = stub([
                        "content" : "I am your comment's content"
                    ])

                    let imageRegion: ImageRegion = stub([
                        "asset" : asset,
                        "alt" : "sample-alt",
                        "url" : NSURL(string: "http://www.example5.com")!
                    ])

                    let content = [textRegion, imageRegion]

                    let comment: ElloComment = stub([
                        "author" : author,
                        "id" : "362",
                        "createdAt" : expectedCreatedAt,
                        "parentPost" : parentPost,
                        "content" : content
                    ])

                    NSKeyedArchiver.archiveRootObject(comment, toFile: filePath)
                    let unArchivedComment = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as! ElloComment

                    expect(unArchivedComment).toNot(beNil())
                    expect(unArchivedComment.version) == 1
                    // active record
                    expect(unArchivedComment.id) == "362"
                    expect(unArchivedComment.createdAt) == expectedCreatedAt
                    // required
                    expect(unArchivedComment.postId) == "sample-parent-post-id"
                    testRegionContent(unArchivedComment.content)
                }
            }
        }
    }
}
