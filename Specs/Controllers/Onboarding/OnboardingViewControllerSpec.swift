////
///  OnboardingViewControllerSpec.swift
//

@testable import Ello
import Quick
import Nimble


class OnboardingViewControllerSpec: QuickSpec {
    override func spec() {
        describe("OnboardingViewController") {
            var subject: OnboardingViewController!
            beforeEach {
                subject = OnboardingViewController()
                showController(subject)
            }
            it("sets onboardingData from currentUser") {
                let user: User = stub([
                    "name": "any name",
                    ])
                user.profile = Profile.stub(["shortBio": "<p>bio</p>"])
                user.externalLinksList = [ExternalLink(url: URL(string: "http://ello.co")!, text: "ELLO")]
                subject.currentUser = user
                expect(subject.onboardingData.name) == user.name
                expect(subject.onboardingData.bio) == "<p>bio</p>"
                expect(subject.onboardingData.links).to(contain("ello.co"))
            }
            it("sets currentUser on each child view controller") {
                let user: User = stub([:])
                subject.currentUser = user
                expect(subject.childViewControllers.count) > 0
                for controller in subject.childViewControllers {
                    if let controller = controller as? ControllerThatMightHaveTheCurrentUser {
                        expect(controller.currentUser) == user
                    }
                    else {
                        fail("controller \(controller) does not have currentUser property")
                    }
                }
            }
            it("assigns an initial onboarding controller") {
                expect(subject.visibleViewController).toNot(beNil())
            }
            it("assigns onboardingData to initial onboarding controller") {
                expect((subject.visibleViewController as? OnboardingStepController)?.onboardingData) == subject.onboardingData
            }
        }
    }
}
