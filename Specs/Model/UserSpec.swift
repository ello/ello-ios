////
///  UserSpec.swift
//

@testable import Ello
import Quick
import Nimble


class UserSpec: QuickSpec {
    override func spec() {
        let correctId = "correctId"
        let wrongId = "wrongId"

        var subject: User!
        var originalPng: Attachment!
        var originalGif: Attachment!
        var optimized: Attachment!
        var hdpi: Attachment!
        var large: Attachment!
        var asset: Asset!
        var assetGif: Asset!
        var emptyAsset: Asset!

        beforeEach {
            originalPng = Attachment.stub(["url": "http://original.png"])
            originalGif = Attachment.stub(["url": "http://original.gif"])
            optimized = Attachment.stub(["url": "http://optimized.png"])
            hdpi = Attachment.stub(["url": "http://hdpi.png"])
            large = Attachment.stub(["url": "http://large.png"])
            asset = Asset.stub(["original": originalPng, "hdpi": hdpi, "large": large, "optimized": optimized])
            assetGif = Asset.stub(["original": originalGif, "hdpi": hdpi, "large": large, "optimized": optimized])
            emptyAsset = Asset.stub([:])
        }

        describe("User") {

            describe("coverImageURL") {
                it("should return nil if there is no image") {
                    subject = User.stub(["coverImage": emptyAsset])
                    expect(subject.coverImageURL(viewsAdultContent: true, animated: true)).to(beNil())
                    expect(subject.coverImageURL(viewsAdultContent: false, animated: true)).to(beNil())
                }

                it("should return original if its not adult content, and is a gif") {
                    subject = User.stub(["coverImage": assetGif, "postsAdultContent": false])
                    expect(subject.coverImageURL(viewsAdultContent: true, animated: true)) == originalGif.url
                    expect(subject.coverImageURL(viewsAdultContent: false, animated: true)) == originalGif.url
                }

                it("should return hdpi if its not adult content, and is a gif, but animated is disabled") {
                    subject = User.stub(["coverImage": assetGif, "postsAdultContent": false])
                    expect(subject.coverImageURL(viewsAdultContent: true, animated: false)) == hdpi.url
                    expect(subject.coverImageURL(viewsAdultContent: false, animated: false)) == hdpi.url
                }

                it("should return hdpi if its not adult content, and is not a gif") {
                    subject = User.stub(["coverImage": asset, "postsAdultContent": false])
                    expect(subject.coverImageURL(viewsAdultContent: true, animated: true)) == hdpi.url
                    expect(subject.coverImageURL(viewsAdultContent: false, animated: true)) == hdpi.url
                }

                it("should return hdpi if it is adult content and a gif") {
                    subject = User.stub(["coverImage": assetGif, "postsAdultContent": true])
                    expect(subject.coverImageURL(viewsAdultContent: false, animated: true)) == hdpi.url
                }

                it("should return original if it is adult content, but current user views adult content") {
                    subject = User.stub(["coverImage": assetGif, "postsAdultContent": true])
                    expect(subject.coverImageURL(viewsAdultContent: true, animated: true)) == originalGif.url
                }
            }

            describe("avatarURL") {
                it("should return nil if there is no image") {
                    subject = User.stub(["avatar": emptyAsset])
                    expect(subject.avatarURL(viewsAdultContent: true, animated: true)).to(beNil())
                    expect(subject.avatarURL(viewsAdultContent: false, animated: true)).to(beNil())
                }

                it("should return original if its not adult content, and is a gif") {
                    subject = User.stub(["avatar": assetGif, "postsAdultContent": false])
                    expect(subject.avatarURL(viewsAdultContent: true, animated: true)) == originalGif.url
                    expect(subject.avatarURL(viewsAdultContent: false, animated: true)) == originalGif.url
                }

                it("should return large if its not adult content, and is a gif, but is not animated") {
                    subject = User.stub(["avatar": assetGif, "postsAdultContent": false])
                    expect(subject.avatarURL(viewsAdultContent: true, animated: false)) == large.url
                    expect(subject.avatarURL(viewsAdultContent: false, animated: false)) == large.url
                }

                it("should return large if its not adult content, and is not a gif") {
                    subject = User.stub(["avatar": asset, "postsAdultContent": false])
                    expect(subject.avatarURL(viewsAdultContent: true, animated: true)) == large.url
                    expect(subject.avatarURL(viewsAdultContent: false, animated: true)) == large.url
                }

                it("should return large if it is adult content and a gif") {
                    subject = User.stub(["avatar": assetGif, "postsAdultContent": true])
                    expect(subject.avatarURL(viewsAdultContent: false, animated: true)) == large.url
                }

                it("should return original if it is adult content, but current user views adult content") {
                    subject = User.stub(["avatar": assetGif, "postsAdultContent": true])
                    expect(subject.avatarURL(viewsAdultContent: true, animated: true)) == originalGif.url
                }
            }

            describe("isAuthorOfPost(_:)") {
                beforeEach {
                    subject = User.stub(["id": correctId])
                }

                it("should return true if post's author is the current user") {
                    let post: Post = stub(["authorId": correctId])
                    expect(subject.isAuthorOf(post: post)) == true
                }

                it("should return false if post's author is not the user") {
                    let post: Post = stub(["authorId": wrongId])
                    expect(subject.isAuthorOf(post: post)) == false
                }
            }

            describe("isAuthorOfComment(_:)") {
                beforeEach {
                    subject = User.stub(["id": correctId])
                }

                it("should return true if comment's author is the current user") {
                    let comment: ElloComment = stub(["authorId": correctId])
                    expect(subject.isAuthorOf(comment: comment)) == true
                }

                it("should return false if comment's author is not the user") {
                    let comment: ElloComment = stub(["authorId": wrongId])
                    expect(subject.isAuthorOf(comment: comment)) == false
                }
            }

            describe("formattedTotalCount()") {
                it("returns <1000 when totalViewsCount is less totalViewsCount 1000") {
                    subject = User.stub(["totalViewsCount": 950])
                    expect(subject.formattedTotalCount!) == "<1K"
                }

                it("returns nil if totalViewsCount is missing") {
                    subject = User.stub([:])
                    expect(subject.formattedTotalCount).to(beNil())
                }

                it("returns proper value if totalViewsCount is greater than 999") {
                    subject = User.stub(["totalViewsCount": 23_450_123])
                    expect(subject.formattedTotalCount!) == "23.5M"
                }
            }

            describe("isAuthorOfOriginalPost(comment:)") {
                beforeEach {
                    subject = User.stub(["id": correctId])
                }

                it("should return true if comment parentPost's author is the current user") {
                    let post: Post = stub(["authorId": correctId])
                    let comment: ElloComment = stub(["loadedFromPost": post])
                    expect(subject.isAuthorOfOriginalPost(comment: comment)) == true
                }

                it("should return true if comment parentPost's repostAuthor is the current user") {
                    let post: Post = stub(["repostAuthor": subject])
                    let comment: ElloComment = stub(["loadedFromPost": post])
                    expect(subject.isAuthorOfOriginalPost(comment: comment)) == true
                }

                it("should return false if comment parentPost's author is not the current user") {
                    let post: Post = stub(["authorId": wrongId])
                    let comment: ElloComment = stub(["loadedFromPost": post])
                    expect(subject.isAuthorOfOriginalPost(comment: comment)) == false
                }

                it("should return false if comment parentPost's author is the current user, on a repost") {
                    let post: Post = stub(["repostAuthorId": wrongId, "authorId": correctId])
                    let comment: ElloComment = stub(["loadedFromPost": post])
                    expect(subject.isAuthorOfOriginalPost(comment: comment)) == false
                }

                it("should return false if comment parentPost's author and repostAuthor are not the current user") {
                    let post: Post = stub(["repostAuthorId": wrongId, "authorId": wrongId])
                    let comment: ElloComment = stub(["loadedFromPost": post])
                    expect(subject.isAuthorOfOriginalPost(comment: comment)) == false
                }
            }

            describe("merge(Model)") {
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
                    let userB: User = stub([:])
                    let merged = userA.merge(userB) as! User
                    expect(merged.formattedShortBio) == "userA"
                }
            }

            describe("updateDefaultImages") {
                var uploadedURL: URL!
                var defaultAsset: Asset!
                var customAsset: Asset!
                beforeEach {
                    uploadedURL = URL(string: "https://assets0.ello.co/images/uploaded.png")
                    defaultAsset = Asset.stub(["url": "https://assets0.ello.co/images/ello-default-large.png"])
                    customAsset = Asset.stub(["url": "https://assets0.ello.co/images/custom.png"])
                }

                it("ignores nil URLs") {
                    subject = User.stub(["avatar": defaultAsset, "coverImage": defaultAsset])
                    subject.updateDefaultImages(avatarURL: nil, coverImageURL: nil)
                    expect(subject.avatarURL()?.absoluteString).to(contain("ello-default-large"))
                }
                it("ignores replaces nil assets") {
                    subject = User.stub([:])
                    subject.updateDefaultImages(avatarURL: uploadedURL, coverImageURL: uploadedURL)
                    expect(subject.avatarURL()?.absoluteString).to(contain("uploaded"))
                    expect(subject.coverImageURL()?.absoluteString).to(contain("uploaded"))
                }
                it("replaces default avatar") {
                    subject = User.stub(["avatar": defaultAsset])
                    subject.updateDefaultImages(avatarURL: uploadedURL, coverImageURL: nil)
                    expect(subject.avatarURL()?.absoluteString).to(contain("uploaded"))
                }
                it("replaces default cover image") {
                    subject = User.stub(["coverImage": defaultAsset])
                    subject.updateDefaultImages(avatarURL: uploadedURL, coverImageURL: nil)
                    expect(subject.coverImageURL()?.absoluteString).to(contain("uploaded"))
                }
                it("ignores custom avatar") {
                    subject = User.stub(["avatar": customAsset])
                    subject.updateDefaultImages(avatarURL: nil, coverImageURL: uploadedURL)
                    expect(subject.avatarURL()?.absoluteString).to(contain("custom"))
                }
                it("ignores custom cover image") {
                    subject = User.stub(["coverImage": customAsset])
                    subject.updateDefaultImages(avatarURL: nil, coverImageURL: uploadedURL)
                    expect(subject.coverImageURL()?.absoluteString).to(contain("custom"))
                }
            }
        }
    }
}
