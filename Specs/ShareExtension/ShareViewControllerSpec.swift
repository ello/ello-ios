////
///  ShareViewControllerSpec.swift
//

@testable import Ello
import Quick
import Nimble

class ShareViewControllerSpec: QuickSpec {
    override func spec() {
        xdescribe("ShareViewController") {
            var subject: ShareViewController!

            beforeEach {
                subject = ShareViewController()
                showController(subject)
            }

            describe("presentationAnimationDidFinish()"){
                context("logged out") {
                    beforeEach {
                        AuthenticationManager.shared.logout()
                    }

                    it("shows the login alert") {
                        subject.presentationAnimationDidFinish()

                        expect(subject.presentedViewController).to(beAKindOf(AlertViewController.self))
                    }
                }

                context("logged in") {
                    beforeEach {
                        let data = ElloAPI.anonymousCredentials.sampleData
                        AuthenticationManager.shared.authenticated(isPasswordBased: true)
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
