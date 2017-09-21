////
///  PostSpec.swift
//

@testable import Ello
import Quick
import Nimble


class PostSpec: QuickSpec {
    override func spec() {

        beforeEach {
            let testingKeys = APIKeys(
                key: "", secret: "", segmentKey: "",
                domain: "https://ello.co"
                )
            APIKeys.shared = testingKeys
        }
        afterEach {
            APIKeys.shared = APIKeys.default
        }

        describe("+fromJSON:") {

            it("parses correctly") {
                let parsedPost = stubbedJSONData("posts_post_details", "posts")

                let createdAtString = "2014-06-01T00:00:00.000Z"
                let post = Post.fromJSON(parsedPost) as! Post
                var createdAt = createdAtString.toDate()!
                // active record
                expect(post.createdAt) == createdAt
                // required
                expect(post.token) == "l9XEKBzB_hB3xkbNb6LdfQ"
                expect(post.contentWarning) == ""
                expect(post.summary.count) == 2
                expect(post.summary[0].kind) == RegionKind.text
                expect(post.summary[1].kind) == RegionKind.image
                expect(post.isReposted) == false
                expect(post.isLoved) == false
                // optional
                expect(post.content!.count) == 2
                expect(post.content![0].kind) == RegionKind.text
                expect(post.content![1].kind) == RegionKind.image
                expect(post.body!.count) == 2
                expect(post.body![0].kind) == RegionKind.text
                expect(post.body![1].kind) == RegionKind.image
                expect(post.viewsCount) == 1
                expect(post.commentsCount) == 0
                expect(post.repostsCount) == 0
                // TODO: create a JSON that has all of these optionals in it
                // links
                expect(post.author).to(beAKindOf(User.self))
                expect(post.comments!.count) == 2
                expect(post.comments![0]).to(beAKindOf(ElloComment.self))
                expect(post.comments![1]).to(beAKindOf(ElloComment.self))
                expect(post.assets.count) == 1
                expect(post.assets[0]).to(beAKindOf(Asset.self))
                // computed
                expect(post.groupId) == "Post-\(post.id)"
                expect(post.shareLink) == "https://ello.co/cfiggis/post/\(post.token)"
                expect(post.isCollapsed).to(beFalse())
            }

            it("parses created reposts correctly") {
                let parsedPost = stubbedJSONData("posts_creating_a_repost", "posts")

                let createdAtString = "2015-12-14T17:01:48.122Z"
                let post = Post.fromJSON(parsedPost) as! Post
                let author: User = stub(["id": post.authorId, "username": "archer"])
                ElloLinkedStore.shared.setObject(author, forKey: post.authorId, type: .usersType)
                var createdAt = createdAtString.toDate()!
                // active record
                expect(post.createdAt) == createdAt
                // required
                expect(post.token) == "0U58x7Bb4ZZpmTDQhPsYBg"
                expect(post.contentWarning) == ""
                expect(post.summary.count) == 2
                expect(post.summary[0].kind) == RegionKind.text
                expect(post.summary[1].kind) == RegionKind.image
                // optional
                expect(post.content!.count) == 1
                expect(post.repostContent![0].kind) == RegionKind.text
                expect(post.viewsCount) == 0
                expect(post.commentsCount) == 0
                expect(post.repostsCount) == 2
                expect(post.repostContent!.count) == 2
                expect(post.repostContent![0].kind) == RegionKind.text
                expect(post.repostContent![1].kind) == RegionKind.image
                // TODO: create a JSON that has all of these optionals in it
                // links
                expect(post.repostAuthor!).to(beAKindOf(User.self))
                expect(post.comments!.count) == 0
                expect(post.assets.count) == 1
                expect(post.assets[0]).to(beAKindOf(Asset.self))
                // computed
                expect(post.groupId) == "Post-\(post.id)"
                expect(post.shareLink) == "https://ello.co/archer/post/\(post.token)"
                expect(post.isCollapsed).to(beFalse())
            }

        }

        describe("contentFor(gridView: Bool)") {
            var post: Post!

            beforeEach {
                post = Post.stub([
                    "content": [TextRegion.stub([:]), TextRegion.stub([:])],
                    "summary": [TextRegion.stub([:])]
                ])
            }


            it("is correct for list mode") {
                expect(post.contentFor(gridView: false)?.count) == 2
            }

            it("is correct for grid mode") {
                expect(post.contentFor(gridView: true)?.count) == 1
            }
        }

        context("NSCoding") {

            var filePath = ""
            if let url = URL(string: FileManager.ElloDocumentsDir()) {
                filePath = url.appendingPathComponent("PostSpec").absoluteString
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
                    let post: Post = stub([:])
                    let wasSuccessfulArchived = NSKeyedArchiver.archiveRootObject(post, toFile: filePath)
                    expect(wasSuccessfulArchived).to(beTrue())
                }
            }

            context("decoding") {

                func testRegionContent(_ content: [Regionable]) {
                    expect(content.count) == 2
                    let textRegion = content[0] as! TextRegion
                    let imageRegion = content[1] as! ImageRegion
                    let imageAsset = imageRegion.asset!
                    expect(textRegion.content) == "I am your content for sure"
                    expect(imageRegion.alt) == "some-altness"
                    expect(imageRegion.url?.absoluteString) == "http://www.example5.com"

                    let assetXhdpi = imageAsset.xhdpi!
                    expect(assetXhdpi.url.absoluteString) == "http://www.example2.com"
                    expect(assetXhdpi.width) == 10
                    expect(assetXhdpi.height) == 99
                    expect(assetXhdpi.size) == 986896
                    expect(assetXhdpi.type) == "png"

                    let assetHDPI = imageAsset.hdpi!
                    expect(assetHDPI.url.absoluteString) == "http://www.example.com"
                    expect(assetHDPI.width) == 45
                    expect(assetHDPI.height) == 35
                    expect(assetHDPI.size) == 445566
                    expect(assetHDPI.type) == "jpeg"
                }

                it("decodes successfully") {
                    let expectedCreatedAt = Globals.now
                    let author: User = stub([
                        "username": "thenim"
                    ])

                    let hdpi: Attachment = stub([
                        "url": URL(string: "http://www.example.com")!,
                        "height": 35,
                        "width": 45,
                        "type": "jpeg",
                        "size": 445566
                    ])

                    let xhdpi: Attachment = stub([
                        "url": URL(string: "http://www.example2.com")!,
                        "height": 99,
                        "width": 10,
                        "type": "png",
                        "size": 986896
                    ])

                    let asset: Asset = stub([
                        "hdpi": hdpi,
                        "xhdpi": xhdpi
                    ])

                    let textRegion: TextRegion = stub([
                        "content": "I am your content for sure"
                    ])

                    let imageRegion: ImageRegion = stub([
                        "asset": asset,
                        "alt": "some-altness",
                        "url": URL(string: "http://www.example5.com")!
                    ])

                    let comment: ElloComment = stub([
                        "author": author
                    ])

                    let summary = [textRegion, imageRegion]
                    let content = [textRegion, imageRegion]
                    let repostContent = [textRegion, imageRegion]

                    let post: Post = stub([
                        "createdAt": expectedCreatedAt,
                        "href": "0987",
                        "token": "toke-en",
                        "contentWarning": "NSFW.",
                        "allowComments": true,
                        "summary": summary,
                        "content": content,
                        "repostContent": repostContent,
                        "repostId": "910",
                        "repostPath": "http://ello.co/910",
                        "repostViaId": "112",
                        "repostViaPath": "http://ello.co/112",
                        "viewsCount": 78,
                        "commentsCount": 6,
                        "repostsCount": 99,
                        "lovesCount": 100,
                        "reposted": true,
                        "loved": true,
                        "assets": [asset],
                        "author": author,
                        "comments": [comment]
                    ])

                    NSKeyedArchiver.archiveRootObject(post, toFile: filePath)
                    let unArchivedPost = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as! Post

                    expect(unArchivedPost).toNot(beNil())
                    expect(unArchivedPost.version) == 2
                    // active record
                    expect(unArchivedPost.id) == post.id
                    expect(unArchivedPost.createdAt) == expectedCreatedAt as Date
                    // required
                    expect(unArchivedPost.href) == "0987"
                    expect(unArchivedPost.token) == "toke-en"
                    expect(unArchivedPost.contentWarning) == "NSFW."
                    expect(unArchivedPost.isCollapsed) == true
                    expect(unArchivedPost.allowComments) == true
                    testRegionContent(unArchivedPost.summary)
                    // optional
                    testRegionContent(unArchivedPost.content!)
                    testRegionContent(unArchivedPost.repostContent!)
                    expect(unArchivedPost.repostId) == "910"
                    expect(unArchivedPost.repostPath) == "http://ello.co/910"
                    expect(unArchivedPost.repostViaId) == "112"
                    expect(unArchivedPost.repostViaPath) == "http://ello.co/112"
                    expect(unArchivedPost.viewsCount) == 78
                    expect(unArchivedPost.commentsCount) == 6
                    expect(unArchivedPost.repostsCount) == 99
                    expect(unArchivedPost.lovesCount) == 100
                    expect(unArchivedPost.isReposted) == true
                    expect(unArchivedPost.isLoved) == true
                    // links
                    expect(unArchivedPost.author?.id) == author.id
                    expect(unArchivedPost.assets.count) == 1
                    expect(unArchivedPost.comments!.count) == 1
                    expect(unArchivedPost.comments![0]).to(beAKindOf(ElloComment.self))
                    // computed
                    expect(post.isCollapsed) == true
                    expect(post.shareLink) == "https://ello.co/thenim/post/toke-en"
                }
            }
        }
    }
}
