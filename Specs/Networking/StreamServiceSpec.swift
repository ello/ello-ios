////
///  StreamServiceSpec.swift
//

@testable import Ello
import Quick
import Moya
import Nimble


class StreamServiceSpec: QuickSpec {
    override func spec() {
        describe("StreamServiceSpec") {

            let streamService = StreamService()

            context("success") {

                describe("-loadStream") {
                    xit("Calls success with an array of Activity objects and responseConfig") {
                        var loadedPosts:[Post]?
                        var config: ResponseConfig?

                        streamService.loadStream(endpoint: ElloAPI.following)
                            .onSuccess { response in
                                if case let .jsonables(jsonables, responseConfig) = response {
                                    loadedPosts = (StreamKind.following.filter(jsonables, viewsAdultContent: true) as! [Post])
                                    config = responseConfig
                                }
                            }.ignoreFailures()

                        expect(config?.prevQueryItems?.count) == 2
                        expect(config?.nextQueryItems?.count) == 2

                        expect(loadedPosts!.count) == 3

                        let post0:Post = loadedPosts![0] as Post

                        expect(post0.id) == "4718"
                        expect(post0.href) == "/api/v2/posts/4718"
                        expect(post0.token) == "_axtKV8Q-MSWbUCWjGqykg"
                        expect(post0.collapsed) == false
                        expect(post0.viewsCount) == 6
                        expect(post0.commentsCount) == 50
                        expect(post0.repostsCount) == 3

                        let textRegion:TextRegion = post0.content![0] as! TextRegion

                        expect(textRegion.content) == "etest post to determine what happens when someone sees this for the first time as a repost from someone they follow. dcdoran will repost this."

                        let post0Author:User = post0.author!
                        expect(post0Author.id) == "27"
                        expect(post0Author.href) == "/api/v2/users/27"
                        expect(post0Author.username) == "dcdoran"
                        expect(post0Author.name) == "Sterling"
                        expect(post0Author.experimentalFeatures) == true
                        expect(post0Author.relationshipPriority) == RelationshipPriority.following
                        expect(post0Author.avatarURL()?.absoluteString) == "https://d1qqdyhbrvi5gr.cloudfront.net/uploads/user/avatar/27/large_ello-09fd7088-2e4f-4781-87db-433d5dbc88a5.png"
                    }

                    xit("handles assets") {
                        var loadedPosts:[Post]?

                        streamService.loadStream(endpoint: ElloAPI.following)
                            .onSuccess { response in
                                if case let .jsonables(jsonables, responseConfig) = response {
                                    loadedPosts = (StreamKind.following.filter(jsonables, viewsAdultContent: true) as! [Post])
                                }
                            }
                            .ignoreFailures()

                        let post2:Post = loadedPosts![2] as Post

                        expect(post2.id) == "4707"

                        let imageRegion:ImageRegion = post2.content![0] as! ImageRegion

                        expect(imageRegion.asset?.hdpi).notTo(beNil())
                        expect(imageRegion.asset?.hdpi!.width) == 750
                        expect(imageRegion.asset?.hdpi!.height) == 321
                        expect(imageRegion.asset?.hdpi!.size) == 77464
                        expect(imageRegion.asset?.hdpi!.type) == "image/jpeg"
                    }
                }

                describe("-loadMoreCommentsForPost") {

                    it("calls success with an array of Comment objects") {
                        var loadedComments:[ElloComment]?

                        streamService.loadMoreCommentsForPost("111",
                            streamKind: nil,
                            success: { (comments, responseConfig) in
                            loadedComments = comments as? [ElloComment]
                        }, .ignoreFailures(),
                            noContent: { _ in })

                        expect(loadedComments!.count) == 1

                        let expectedCreatedAt = "2014-06-02T00:00:00.000Z".toDate()!
                        let comment:ElloComment = loadedComments![0] as ElloComment

                        expect(comment.createdAt) == expectedCreatedAt

                        let contentRegion0:TextRegion = comment.content[0] as! TextRegion
                        expect(contentRegion0.content) == "<p>Hello, I am a comment with awesome content!</p>"

                        let commentAuthor:User = comment.author!

                        expect(commentAuthor).to(beAnInstanceOf(User.self))
                        expect(commentAuthor.name) == "Pamilanderson"
                        expect(commentAuthor.id) == "420"
                        expect(commentAuthor.username) == "pam"
                        expect(commentAuthor.href) == "/api/v2/users/420"
                        expect(commentAuthor.experimentalFeatures) == true
                        expect(commentAuthor.avatarURL()?.absoluteString) == "https://abc123.cloudfront.net/uploads/user/avatar/420/ello-large-91c0f710.png"
                    }
                }
            }

            context("failure") {

                // smoke test a few failure status codes, the whole lot is tested in ElloProviderSpec

                beforeEach {
                    ElloProvider.sharedProvider = ElloProvider.ErrorStubbingProvider()
                }

                context("404") {

                    beforeEach {
                        ElloProvider_Specs.errorStatusCode = .status404
                    }

                    it("Calls failure with an error and statusCode") {

                        var loadedJsonables:[JSONAble]?
                        var loadedStatusCode:Int?
                        var loadedError:NSError?

                        streamService.loadStream(endpoint: ElloAPI.following)
                        .onSuccess { response in
                            if case let .jsonables(jsonables, responseConfig) = response {
                                loadedJsonables = jsonables
                            }
                        }
                        .onFail { error in
                            loadedError = error
                        })

                        expect(loadedJsonables).to(beNil())
                        expect(loadedError!).notTo(beNil())

                        let elloNetworkError = loadedError!.userInfo[NSLocalizedFailureReasonErrorKey] as! ElloNetworkError

                        expect(elloNetworkError).to(beAnInstanceOf(ElloNetworkError.self))
                        expect(elloNetworkError.code) == ElloNetworkError.CodeType.notFound
                        expect(elloNetworkError.title) == "The requested resource could not be found."
                        expect(elloNetworkError.status) == "404"
                    }
                }
            }
        }
    }
}
