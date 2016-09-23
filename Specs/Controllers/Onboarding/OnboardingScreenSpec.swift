////
///  OnboardingScreenSpec.swift
//

@testable import Ello
import Quick
import Nimble


class OnboardingScreenSpec: QuickSpec {
    class MockDelegate: OnboardingDelegate {
        var didGoNext = false
        var didAbort = false

        func nextAction() { didGoNext = true }
        func abortAction() { didAbort = true }
    }

    override func spec() {
        describe("OnboardingScreen") {
            var subject: OnboardingScreen!
            var delegate: MockDelegate!
            beforeEach {
                subject = OnboardingScreen()
                delegate = MockDelegate()
                subject.delegate = delegate
                showView(subject)
            }
            context("snapshots") {
                validateAllSnapshots(named: "OnboardingScreen") { return subject }
            }
            context("styleFor(OnboardingStep)") {
                it("should set text for step .Categories") {
                    subject.styleFor(step: .Categories)
                    expectValidSnapshot(subject, device: .Phone6_Portrait)
                }
                it("should set text for step .CreateProfile") {
                    subject.styleFor(step: .CreateProfile)
                    expectValidSnapshot(subject, device: .Phone6_Portrait)
                }
                it("should set text for step .InviteFriends") {
                    subject.styleFor(step: .InviteFriends)
                    expectValidSnapshot(subject, device: .Phone6_Portrait)
                }
            }
            context("controllerContainer") {
                it("should allow content inside controllerContainer") {
                    let content = UIImageView()
                    content.image = specImage(named: "specs-avatar")
                    content.contentMode = .ScaleAspectFill
                    content.frame = subject.controllerContainer.bounds
                    subject.controllerContainer.addSubview(content)
                    expectValidSnapshot(subject, device: .Phone6_Portrait)
                }
            }
            context("buttons") {
                // the image names are important here, because two of these
                // images should be the same (any case where canGoNext=false)
                beforeEach {
                    subject.styleFor(step: .Categories)
                }
                it("styles correct for hasAbortButton=false, canGoNext=false") {
                    subject.hasAbortButton = false
                    subject.canGoNext = false
                    expectValidSnapshot(subject, named: "cannotGoNext", device: .Phone6_Portrait)
                }
                it("styles correct for hasAbortButton=false, canGoNext=true") {
                    subject.hasAbortButton = false
                    subject.canGoNext = true
                    expectValidSnapshot(subject, named: "canGoNext", device: .Phone6_Portrait)
                }
                it("styles correct for hasAbortButton=true, canGoNext=false") {
                    subject.hasAbortButton = true
                    subject.canGoNext = false
                    expectValidSnapshot(subject, named: "cannotGoNext", device: .Phone6_Portrait)
                }
                it("styles correct for hasAbortButton=true, canGoNext=true") {
                    subject.hasAbortButton = true
                    subject.canGoNext = true
                    expectValidSnapshot(subject, named: "canGoNextAndAbort", device: .Phone6_Portrait)
                }
            }
            context("prompt") {
                it("supports setting the prompt") {
                    subject.prompt = "Testing 123"
                    subject.canGoNext = false
                    expectValidSnapshot(subject, device: .Phone6_Portrait)
                }
            }
            context("actions") {
                it("forwards nextAction") {
                    subject.nextAction()
                    expect(delegate.didGoNext) == true
                }
                it("forwards abortAction") {
                    subject.abortAction()
                    expect(delegate.didAbort) == true
                }
            }
        }
    }
}
