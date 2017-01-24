////
///  AutoCompleteServiceSpec.swift
//

@testable import Ello
import Quick
import Moya
import Nimble


class AutoCompleteServiceSpec: QuickSpec {
    override func spec() {
        describe("AutoCompleteService") {
            let subject = AutoCompleteService()

            describe("loadResults(#terms:type:success:failure)") {

                context("username search") {

                    context("success") {

                        it("succeeds") {
                            var successCalled = false
                            var failedCalled = false
                            var loadedResults: [AutoCompleteResult]?
                            subject.loadUsernameResults("doesn't matter",
                                success: { (results, responseConfig) in
                                    successCalled = true
                                    loadedResults = results
                                }, failure: { (_, _) in
                                    failedCalled = true
                                }
                            )

                            expect(successCalled) == true
                            expect(failedCalled) == false
                            expect(loadedResults!.count) == 3
                            expect(loadedResults?[1].name) == "lanakane"
                            expect(loadedResults?[1].url!.absoluteString) == "https://abc123.cloudfront.net/uploads/user/avatar/55/ello-small-aaca0f5e.png"
                        }
                    }

                    context("failure") {

                        beforeEach {
                            ElloProvider.sharedProvider = ElloProvider.ErrorStubbingProvider()
                        }

                        it("fails") {
                            var successCalled = false
                            var failedCalled = false
                            subject.loadUsernameResults("doesn't matter",
                                success: { (results, responseConfig) in
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

                context("emoji search") {

                    context("success") {
                        let expectations: [(String, [String])] = [
                            ("met", ["metal", "metro"]),
                            (":met", ["metal", "metro"]),
                            ("meta", ["metal"]),
                            (":meta", ["metal"]),
                            ("etal", ["metal"]),
                            (":etal", ["metal"]),
                            ("metl", []),
                            (":metl", []),
                        ]
                        for (test, expected) in expectations {
                            it("should find \(expected.count) matches for \(test)") {
                                let results = subject.loadEmojiResults(test)
                                expect(results.count) == expected.count
                                for (index, expectation) in expected.enumerated() {
                                    if index >= results.count {
                                        break
                                    }

                                    expect(results[index].name) == expectation
                                }
                            }
                        }
                    }
                }

            }
        }
    }
}
