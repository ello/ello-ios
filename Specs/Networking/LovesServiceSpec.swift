////
///  LovesServiceSpec.swift
//

@testable import Ello
import Quick
import Moya
import Nimble


class LovesServiceSpec: QuickSpec {
    override func spec() {

        describe("LovesService") {

            let subject = LovesService()

            describe("lovePost(#postId:success:failure)") {

                context("success") {

                    it("succeeds") {
                        var successCalled = false
                        var failedCalled = false
                        subject.lovePost(postId: "fake-post-id",
                            success: { (love, responseConfig) in
                                successCalled = true
                            }, failure: { (_, _) in
                                failedCalled = true
                            }
                        )

                        expect(successCalled) == true
                        expect(failedCalled) == false
                    }
                }

                context("failure") {

                    beforeEach {
                        ElloProvider.sharedProvider = ElloProvider.ErrorStubbingProvider()
                    }

                    it("fails") {
                        var successCalled = false
                        var failedCalled = false
                        subject.lovePost(postId: "fake-post-id",
                            success: { (love, responseConfig) in
                                successCalled = true
                            }, failure: { (_, _) in
                                failedCalled = true
                            }
                        )

                        expect(successCalled) == false
                        expect(failedCalled) == true
                    }
                }
            }

            describe("unlovePost(#postId:success:failure)") {

                context("success") {

                    it("succeeds") {
                        var successCalled = false
                        var failedCalled = false
                        subject.unlovePost(postId: "fake-post-id",
                            success: {
                                successCalled = true
                            }, failure: { (_, _) in
                                failedCalled = true
                            }
                        )

                        expect(successCalled) == true
                        expect(failedCalled) == false
                    }
                }

                context("failure") {

                    beforeEach {
                        ElloProvider.sharedProvider = ElloProvider.ErrorStubbingProvider()
                    }

                    it("fails") {
                        var successCalled = false
                        var failedCalled = false
                        subject.unlovePost(postId: "fake-post-id",
                            success: {
                                successCalled = true
                            }, failure: { (_, _) in
                                failedCalled = true
                            }
                        )

                        expect(successCalled) == false
                        expect(failedCalled) == true
                    }
                }
            }
        }
    }
}
