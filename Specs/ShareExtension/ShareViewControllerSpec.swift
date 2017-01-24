////
///  ShareViewControllerSpec.swift
//

@testable import Ello
import Quick
import Nimble

class ShareViewControllerSpec: QuickSpec {
    override func spec() {
        describe("ShareViewController") {
            var subject = ShareViewController()

            beforeEach {
                subject = ShareViewController()
                showController(subject)
            }

            describe("initialization") {

                it("can be instantiated") {
                    expect(subject).notTo(beNil())
                }

                it("is a UIViewController") {
                    expect(subject).to(beAKindOf(UIViewController.self))
                }

                it("is a ShareViewController") {
                    expect(subject).to(beAKindOf(ShareViewController.self))
                }
            }

            describe("presentationAnimationDidFinish()"){
                context("logged out") {
                    beforeEach {
                        ElloProvider.shared.logout()
                    }

                    it("shows the login alert") {
                        subject.presentationAnimationDidFinish()

                        expect(subject.presentedViewController).to(beAKindOf(AlertViewController.self))
                    }
                }

                context("logged in") {
                    beforeEach {
                        let data = ElloAPI.anonymousCredentials.sampleData
                        ElloProvider.shared.authenticated(isPasswordBased: true)
                        AuthToken.storeToken(data, isPasswordBased: true, email: "hi@everyone.com", password: "123456")
                    }

                    it("does not show the login alert") {
                        subject.presentationAnimationDidFinish()
                        expect(subject.presentedViewController).to(beNil())
                    }

                }
            }
        }
    }
}
