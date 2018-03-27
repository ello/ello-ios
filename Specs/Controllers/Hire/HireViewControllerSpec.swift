////
///  HireViewControllerSpec.swift
//

@testable import Ello
import Quick
import Nimble


class HireViewControllerSpec: QuickSpec {
    class FakeNavigationController: UINavigationController {
        var popped = false
        override func popViewController(animated: Bool) -> UIViewController? {
            popped = true
            return super.popViewController(animated: animated)
        }
    }

    class MockScreen: HireScreenProtocol {
        var keyboardVisible = false
        var successCalled = false
        var successVisible = false
        func toggleKeyboard(visible: Bool) {
            keyboardVisible = visible
        }
        func showSuccess() {
            successVisible = true
            successCalled = true
        }
        func hideSuccess() {
            successVisible = false
            successCalled = true
        }
    }

    override func spec() {
        var subject: HireViewController!
        var mockScreen: MockScreen!

        beforeEach {
            mockScreen = MockScreen()
            let user: User = stub([:])
            subject = HireViewController(user: user, type: .hire)
            subject.screen = mockScreen
        }

        describe("HireViewController") {
            describe("submit(body:\"\")") {
                beforeEach {
                    subject.submit(body: "")
                }
                it("should show do nothing") {
                    expect(mockScreen.successCalled) == false
                }
            }
            describe("submit(body:\"test\") success") {
                beforeEach {
                    subject.submit(body: "test!")
                }
                it("should show the success screen") {
                    expect(mockScreen.successVisible) == true
                }
            }
        }
    }
}
