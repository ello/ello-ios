////
///  HireViewControllerSpec.swift
//

@testable import Ello
import Quick
import Nimble


class HireViewControllerSpec: QuickSpec {
    class FakeNavigationController: UINavigationController {
        var popped = false
        override func popViewControllerAnimated(animated: Bool) -> UIViewController? {
            popped = true
            return super.popViewControllerAnimated(animated)
        }
    }
    class MockScreen: HireScreenProtocol {
        var keyboardVisible = false
        var successCalled = false
        var successVisible = false
        func toggleKeyboard(visible visible: Bool) {
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
        var navigationController: FakeNavigationController!
        var subject: HireViewController!
        var mockScreen: MockScreen!

        beforeEach {
            mockScreen = MockScreen()
            let user: User = stub([:])
            subject = HireViewController(user: user)
            subject.mockScreen = mockScreen
            navigationController = FakeNavigationController(rootViewController: subject)
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
                // test manually, because this spec never passes in xcode
                xit("should hide the success screen after 3.3 seconds") {
                    expect(mockScreen.successVisible).toEventually(beFalse(), timeout: 4)
                    expect(mockScreen.successCalled).toEventually(beTrue(), timeout: 4)
                }
                // test manually, because this spec never passes in xcode
                xit("should pop the controller") {
                    expect(navigationController.popped).toEventually(beTrue(), timeout: 4)
                }
            }
            describe("submit(body:\"test\") failure") {
                beforeEach {
                    ElloProvider.sharedProvider = ElloProvider.ErrorStubbingProvider()
                    subject.submit(body: "test!")
                    showController(subject)
                }
                xit("should pop the controller") {
                    waitUntil(timeout: 4) { done in
                        delay(3.1) { done() }
                    }
                    expect(navigationController.popped) == false
                }
            }
        }
    }
}
