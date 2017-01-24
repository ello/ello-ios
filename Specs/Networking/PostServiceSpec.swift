////
///  PostServiceSpec.swift
//

@testable import Ello
import Quick
import Moya
import Nimble


class PostServiceSpec: QuickSpec {
    override func spec() {
        describe("PostService") {

            let subject = PostService()

            describe("loadPost(_:success:failure)") {

                context("success") {

                    it("succeeds") {
                        var successPost: Post?
                        var failedCalled = false
                        subject.loadPost("fake-post-param", needsComments: true)
                            .onSuccess { post in
                                successPost = post
                            }
                            .onFail { _ in
                                failedCalled = true
                            }

                        expect(successPost).notTo(beNil())
                        expect(failedCalled).to(beFalse())
                    }
                }

                context("failure") {

                    beforeEach {
                        ElloProvider.sharedProvider = ElloProvider.ErrorStubbingProvider()
                    }

                    it("fails") {
                        var successPost: Post?
                        var failedCalled = false
                        subject.loadPost("fake-post-param", needsComments: true)
                            .onSuccess { post in
                                successPost = post
                            }
                            .onFail { _ in
                                failedCalled = true
                            }

                        expect(successPost).to(beNil())
                        expect(failedCalled).to(beTrue())
                    }
                }
            }

            describe("deletePost(_:success:failure)") {

                context("success") {

                    it("succeeds") {
                        var successCalled = false
                        var failedCalled = false
                        subject.deletePost("fake-post-id",
                            success: {
                                successCalled = true
                            }, failure: {
                                (_, _) in
                                failedCalled = true
                            }
                        )

                        expect(successCalled).to(beTrue())
                        expect(failedCalled).to(beFalse())
                    }
                }

                context("failure") {

                    beforeEach {
                        ElloProvider.sharedProvider = ElloProvider.ErrorStubbingProvider()
                    }

                    it("fails") {
                        var successCalled = false
                        var failedCalled = false
                        subject.deletePost("fake-post-id",
                            success: {
                                successCalled = true
                            }, failure: {
                                (_, _) in
                                failedCalled = true
                            }
                        )

                        expect(successCalled).to(beFalse())
                        expect(failedCalled).to(beTrue())
                    }
                }
            }

            describe("deleteComment(_:commentId:success:failure)") {

                context("success") {

                    it("succeeds") {
                        var successCalled = false
                        var failedCalled = false
                        subject.deleteComment("fake-post-id",
                            commentId: "fake-comment-id",
                            success: {
                                successCalled = true
                            }, failure: { (_, _) in
                                failedCalled = true
                            }
                        )

                        expect(successCalled).to(beTrue())
                        expect(failedCalled).to(beFalse())
                    }
                }

                context("failure") {

                    beforeEach {
                        ElloProvider.sharedProvider = ElloProvider.ErrorStubbingProvider()
                    }

                    it("fails") {
                        var successCalled = false
                        var failedCalled = false
                        subject.deleteComment("fake-post-id",
                            commentId: "fake-comment-id",
                            success: {
                                successCalled = true
                            }, failure: { (_, _) in
                                failedCalled = true
                            }
                        )

                        expect(successCalled).to(beFalse())
                        expect(failedCalled).to(beTrue())
                    }
                }
            }

        }
    }
}
