////
///  UserSpec.swift
//

@testable
import Ello
import Quick
import Nimble


class UserSpec: QuickSpec {
    override func spec() {

        describe("User") {

            describe("coverImageURL") {

                let originalPng: Attachment = stub(["url": "http://original.png"])
                let originalGif: Attachment = stub(["url": "http://original.gif"])
                let optimized: Attachment = stub(["url": "http://optimized.png"])
                let hdpi: Attachment = stub(["url": "http://hdpi.png"])
                let asset: Asset = stub(["original": originalPng, "xhdpi": hdpi, "optimized": optimized])
                let assetGif: Asset = stub(["original": originalGif, "xhdpi": hdpi, "optimized": optimized])
                let emptyAsset: Asset = stub([:])

                it("should return nil if there is no image") {
                    let subject: User = stub(["coverImage": emptyAsset])
                    expect(subject.coverImageURL(viewsAdultContent: true, animated: true)).to(beNil())
                    expect(subject.coverImageURL(viewsAdultContent: false, animated: true)).to(beNil())
                }

                it("should return original if its not adult content, and is a gif") {
                    let subject: User = stub(["coverImage": assetGif, "postsAdultContent": false])
                    expect(subject.coverImageURL(viewsAdultContent: true, animated: true)) == originalGif.url
                    expect(subject.coverImageURL(viewsAdultContent: false, animated: true)) == originalGif.url
                }

                it("should return hdpi if its not adult content, and is a gif, but animated is disabled") {
                    let subject: User = stub(["coverImage": assetGif, "postsAdultContent": false])
                    expect(subject.coverImageURL(viewsAdultContent: true, animated: false)) == hdpi.url
                    expect(subject.coverImageURL(viewsAdultContent: false, animated: false)) == hdpi.url
                }

                it("should return hdpi if its not adult content, and is not a gif") {
                    let subject: User = stub(["coverImage": asset, "postsAdultContent": false])
                    expect(subject.coverImageURL(viewsAdultContent: true, animated: true)) == hdpi.url
                    expect(subject.coverImageURL(viewsAdultContent: false, animated: true)) == hdpi.url
                }

                it("should return hdpi if it is adult content and a gif") {
                    let subject: User = stub(["coverImage": assetGif, "postsAdultContent": true])
                    expect(subject.coverImageURL(viewsAdultContent: false, animated: true)) == hdpi.url
                }

                it("should return original if it is adult content, but current user views adult content") {
                    let subject: User = stub(["coverImage": assetGif, "postsAdultContent": true])
                    expect(subject.coverImageURL(viewsAdultContent: true, animated: true)) == originalGif.url
                }
            }
            describe("avatarURL") {

                let originalPng: Attachment = stub(["url": "http://original.png"])
                let originalGif: Attachment = stub(["url": "http://original.gif"])
                let large: Attachment = stub(["url": "http://large.png"])
                let hdpi: Attachment = stub(["url": "http://large.png"])
                let asset: Asset = stub(["original": originalPng, "large": large, "hdpi": hdpi])
                let assetGif: Asset = stub(["original": originalGif, "large": large, "hdpi": hdpi])
                let emptyAsset: Asset = stub([:])

                it("should return nil if there is no image") {
                    let subject: User = stub(["avatar": emptyAsset])
                    expect(subject.avatarURL(viewsAdultContent: true, animated: true)).to(beNil())
                    expect(subject.avatarURL(viewsAdultContent: false, animated: true)).to(beNil())
                }

                it("should return original if its not adult content, and is a gif") {
                    let subject: User = stub(["avatar": assetGif, "postsAdultContent": false])
                    expect(subject.avatarURL(viewsAdultContent: true, animated: true)) == originalGif.url
                    expect(subject.avatarURL(viewsAdultContent: false, animated: true)) == originalGif.url
                }

                it("should return large if its not adult content, and is a gif, but is not animated") {
                    let subject: User = stub(["avatar": assetGif, "postsAdultContent": false])
                    expect(subject.avatarURL(viewsAdultContent: true, animated: false)) == large.url
                    expect(subject.avatarURL(viewsAdultContent: false, animated: false)) == large.url
                }

                it("should return large if its not adult content, and is not a gif") {
                    let subject: User = stub(["avatar": asset, "postsAdultContent": false])
                    expect(subject.avatarURL(viewsAdultContent: true, animated: true)) == large.url
                    expect(subject.avatarURL(viewsAdultContent: false, animated: true)) == large.url
                }

                it("should return large if it is adult content and a gif") {
                    let subject: User = stub(["avatar": assetGif, "postsAdultContent": true])
                    expect(subject.avatarURL(viewsAdultContent: false, animated: true)) == large.url
                }

                it("should return original if it is adult content, but current user views adult content") {
                    let subject: User = stub(["avatar": assetGif, "postsAdultContent": true])
                    expect(subject.avatarURL(viewsAdultContent: true, animated: true)) == originalGif.url
                }
            }

            describe("isOwnPost(_:)") {

                let subject: User = stub(["id": "correctId"])

                it("should return true if post's author is the current user") {
                    let post: Post = stub(["authorId": "correctId"])
                    expect(subject.isOwnPost(post)) == true
                }

                it("should return false if post's author is not the user") {
                    let post: Post = stub(["authorId": "WRONG ID"])
                    expect(subject.isOwnPost(post)) == false
                }
            }

            describe("isOwnComment(_:)") {

                let subject: User = stub(["id": "correctId"])

                it("should return true if comment's author is the current user") {
                    let comment: ElloComment = stub(["authorId": "correctId"])
                    expect(subject.isOwnComment(comment)) == true
                }

                it("should return false if comment's author is not the user") {
                    let comment: ElloComment = stub(["authorId": "WRONG ID"])
                    expect(subject.isOwnComment(comment)) == false
                }
            }

            describe("formattedTotalCount()") {

                it("returns <1000 when totalViewsCount is less totalViewsCount 1000") {
                    let subject: User = stub(["totalViewsCount": 950])
                    expect(subject.formattedTotalCount()) == "<1000"
                }

                it("returns <1000 if totalViewsCount is not present") {
                    let subject: User = stub([:])
                    expect(subject.formattedTotalCount()) == "<1000"
                }

                it("returns proper value if totalViewsCount is greater than 999") {
                    let subject: User = stub(["totalViewsCount": 23_450_123])
                    expect(subject.formattedTotalCount()) == "23.45M"
                }
            }

            describe("isOwnParentPost(_:)") {

                let subject: User = stub(["id": "correctId"])

                it("should return true if comment parentPost's author is the current user") {
                    let post: Post = stub(["authorId": "correctId"])
                    let comment: ElloComment = stub(["loadedFromPost": post])
                    expect(subject.isOwnParentPost(comment)) == true
                }

                it("should return false if comment parentPost's author is not the user") {
                    let post: Post = stub(["authorId": "WRONG ID"])
                    let comment: ElloComment = stub(["loadedFromPost": post])
                    expect(subject.isOwnParentPost(comment)) == false
                }
            }

            describe("+fromJSON:") {

                it("parses correctly") {
                    let data = stubbedJSONData("users_user_details", "users")
                    let user = User.fromJSON(data) as! User
                    // active record
                    expect(user.id) == "420"
                    // required
                    expect(user.href) == "/api/v2/users/420"
                    expect(user.username) == "pam"
                    expect(user.name) == "Pamilanderson"
                    expect(user.experimentalFeatures) == true
                    expect(user.relationshipPriority) == RelationshipPriority.None
                    expect(user.hasLovesEnabled) == true
                    expect(user.hasRepostingEnabled) == false
                    expect(user.hasSharingEnabled) == true
                    expect(user.isCollaborateable) == true
                    expect(user.isHireable) == true
                    // optional
                    expect(user.avatar).to(beAKindOf(Asset.self))
                    expect(user.identifiableBy) == ""
                    expect(user.postsCount!) == 4
                    expect(user.followersCount!) == "0"
                    expect(user.followingCount!) == 0
                    expect(user.totalViewsCount!) == 9762
                    expect(user.location) == "Denver"
                    expect(user.formattedShortBio) == "<p>Have been spying for a while now.</p>"
    //                expect(user.externalLinks) == "http://isis.com http://ello.co"
                    expect(user.coverImage).to(beAKindOf(Asset.self))
                    expect(user.backgroundPosition) == ""
                    expect(user.isCurrentUser) == false

    //                expect(user.mostRecentPost).toNot(beNil())
    //                expect(user.mostRecentPost?.id) == "4721"
    //                expect(user.mostRecentPost?.author) == user
                }
            }

           context("NSCoding") {

                var filePath = ""
                if let url = NSURL(string: NSFileManager.ElloDocumentsDir()) {
                    filePath = url.URLByAppendingPathComponent("UserSpec")!.absoluteString!
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
                        let user: User = stub([:])

                        let wasSuccessfulArchived = NSKeyedArchiver.archiveRootObject(user, toFile: filePath)

                        expect(wasSuccessfulArchived).to(beTrue())
                    }
                }

                context("decoding") {

                    it("decodes successfully") {
                        let post: Post = stub(["id" : "sample-post-id"])
                        let stubbedMostRecentPost: Post = stub(["id" : "another-sample-post-id", "authorId" : "sample-userId"])
                        let attachment: Attachment = stub(["url": NSURL(string: "http://www.example.com")!, "height": 0, "width": 0, "type": "png", "size": 0 ])
                        let asset: Asset = stub(["regular" : attachment])
                        let coverAttachment: Attachment = stub(["url": NSURL(string: "http://www.example2.com")!, "height": 0, "width": 0, "type": "png", "size": 0 ])
                        let coverAsset: Asset = stub(["xhdpi" : coverAttachment])

                        let user: User = stub([
                            "avatar" : asset,
                            "coverImage" : coverAsset,
                            "experimentalFeatures" : true,
                            "followersCount" : "6",
                            "followingCount" : 8,
                            "href" : "sample-href",
                            "name" : "sample-name",
                            "posts" : [post],
                            "postsCount" : 9,
                            "mostRecentPost" : stubbedMostRecentPost,
                            "relationshipPriority" : "self",
                            "id" : "sample-userId",
                            "username" : "sample-username",
                            "profile": Profile.stub(["email": "sample@email.com"]) ,
                            "formattedShortBio" : "sample-short-bio",
                            "externalLinks": "sample-external-links"
                        ])

                        user.totalViewsCount = 5003
                        user.location = "Boulder"

                        NSKeyedArchiver.archiveRootObject(user, toFile: filePath)
                        let unArchivedUser = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as! User

                        expect(unArchivedUser).toNot(beNil())
                        expect(unArchivedUser.version) == UserVersion

                        expect(unArchivedUser.avatarURL()?.absoluteString) == "http://www.example.com"
                        expect(unArchivedUser.coverImageURL(viewsAdultContent: true)?.absoluteString) == "http://www.example2.com"
                        expect(unArchivedUser.experimentalFeatures).to(beTrue())
                        expect(unArchivedUser.followersCount) == "6"
                        expect(unArchivedUser.followingCount) == 8
                        expect(unArchivedUser.href) == "sample-href"
                        expect(unArchivedUser.name) == "sample-name"
                        expect(unArchivedUser.hasCommentingEnabled) == true
                        expect(unArchivedUser.hasLovesEnabled) == true
                        expect(unArchivedUser.hasSharingEnabled) == true
                        expect(unArchivedUser.hasRepostingEnabled) == true
                        expect(unArchivedUser.totalViewsCount) == 5003
                        expect(unArchivedUser.location) == "Boulder"

                        let firstPost = unArchivedUser.posts!.first!
                        expect(firstPost.id) == "sample-post-id"

                        expect(unArchivedUser.relationshipPriority.rawValue) == "self"
                        expect(unArchivedUser.id) == "sample-userId"
                        expect(unArchivedUser.username) == "sample-username"
                        expect(unArchivedUser.formattedShortBio) == "sample-short-bio"
    //                    expect(unArchivedUser.externalLinks) == "sample-external-links"
                        expect(unArchivedUser.isCurrentUser).to(beTrue())

                        expect(unArchivedUser.mostRecentPost).toNot(beNil())
                        expect(unArchivedUser.mostRecentPost?.id) == "another-sample-post-id"
                        expect(unArchivedUser.mostRecentPost?.author!.id) == unArchivedUser.id
                    }
                }
            }
        }

        describe("merge(JSONAble)") {
            it("returns non-User objects") {
                let post: Post = stub([:])
                let user: User = stub([:])
                expect(user.merge(post)) == post
            }
            it("returns User objects") {
                let userA: User = stub([:])
                let userB: User = stub([:])
                expect(userA.merge(userB)) == userB
            }
            it("merges the formattedShortBio") {
                let userA: User = stub(["formattedShortBio": "userA"])
                let userB: User = stub(["formattedShortBio": "userB"])
                let merged = userA.merge(userB) as! User
                expect(merged.formattedShortBio) == "userB"
            }
            it("preserves the formattedShortBio") {
                let userA: User = stub(["formattedShortBio": "userA"])
                let userB: User = stub(["formattedShortBio": ""])
                let merged = userA.merge(userB) as! User
                expect(merged.formattedShortBio) == "userA"
            }
        }
    }
}
