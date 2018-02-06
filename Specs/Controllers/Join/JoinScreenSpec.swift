////
///  JoinScreenSpec.swift
//

@testable import Ello
import Quick
import Nimble


class JoinScreenSpec: QuickSpec {
    override func spec() {
        class MockDelegate: JoinScreenDelegate {
            var didValidate = false

            func backAction() {}
            func validate(email: String, username: String, password: String) {
                didValidate = true
            }
            func onePasswordAction(_ sender: UIView) {}
            func submit(email: String, username: String, password: String) {}
            func termsAction() {}
        }

        describe("JoinScreen") {
            var subject: JoinScreen!
            var delegate: MockDelegate!
            beforeEach {
                delegate = MockDelegate()
                subject = JoinScreen()
                subject.delegate = delegate
            }

            describe("snapshots") {
                validateAllSnapshots { return subject }
            }

            describe("snapshot, one password shown") {
                beforeEach {
                    subject.isOnePasswordAvailable = true
                }
                it("should have a valid snapshot") {
                    expectValidSnapshot(subject, device: .phone6_Portrait)
                }
            }

            describe("snapshot, keyboard shown") {
                beforeEach {
                    Keyboard.shared.isActive = true
                    Keyboard.shared.bottomInset = 216
                    subject.keyboardWillChange(Keyboard.shared, animated: false)
                }
                afterEach {
                    Keyboard.shared.isActive = false
                    Keyboard.shared.bottomInset = 0
                }
                it("should have a valid snapshot") {
                    expectValidSnapshot(subject, device: .phone6_Portrait)
                }
            }

            describe("snapshot, email error shown") {
                beforeEach {
                    subject.showEmailError("error")
                }
                it("should have a valid snapshot") {
                    expectValidSnapshot(subject, device: .phone6_Portrait)
                }
            }

            describe("snapshot, username error shown") {
                beforeEach {
                    subject.showUsernameError("error")
                }
                it("should have a valid snapshot") {
                    expectValidSnapshot(subject, device: .phone6_Portrait)
                }
            }

            describe("snapshot, username error and message shown") {
                beforeEach {
                    subject.showUsernameError("error")
                    subject.showMessage("message")
                }
                it("should have a valid snapshot") {
                    expectValidSnapshot(subject, device: .phone6_Portrait)
                }
            }

            describe("snapshot, password error shown") {
                beforeEach {
                    subject.showPasswordError("error")
                }
                it("should have a valid snapshot") {
                    expectValidSnapshot(subject, device: .phone6_Portrait)
                }
            }

            describe("snapshot, message shown") {
                beforeEach {
                    subject.showMessage("message")
                }
                it("should have a valid snapshot") {
                    expectValidSnapshot(subject, device: .phone6_Portrait)
                }
            }

            describe("snapshot, email valid") {
                beforeEach {
                    subject.isEmailValid = true
                }
                it("should have a valid snapshot") {
                    expectValidSnapshot(subject, device: .phone6_Portrait)
                }
            }
            describe("snapshot, email invalid") {
                beforeEach {
                    subject.isEmailValid = false
                }
                it("should have a valid snapshot") {
                    expectValidSnapshot(subject, device: .phone6_Portrait)
                }
            }

            describe("snapshot, username valid") {
                beforeEach {
                    subject.isUsernameValid = true
                }
                it("should have a valid snapshot") {
                    expectValidSnapshot(subject, device: .phone6_Portrait)
                }
            }
            describe("snapshot, username invalid") {
                beforeEach {
                    subject.isUsernameValid = false
                }
                it("should have a valid snapshot") {
                    expectValidSnapshot(subject, device: .phone6_Portrait)
                }
            }

            describe("snapshot, password valid") {
                beforeEach {
                    subject.isPasswordValid = true
                }
                it("should have a valid snapshot") {
                    expectValidSnapshot(subject, device: .phone6_Portrait)
                }
            }
            describe("snapshot, password invalid") {
                beforeEach {
                    subject.isPasswordValid = false
                }
                it("should have a valid snapshot") {
                    expectValidSnapshot(subject, device: .phone6_Portrait)
                }
            }

            describe("snapshot, all valid") {
                beforeEach {
                    subject.isEmailValid = true
                    subject.isUsernameValid = true
                    subject.isPasswordValid = true
                }
                it("should have a valid snapshot") {
                    expectValidSnapshot(subject, device: .phone6_Portrait)
                }
            }
            describe("snapshot, all invalid") {
                beforeEach {
                    subject.isEmailValid = false
                    subject.isUsernameValid = false
                    subject.isPasswordValid = false
                }
                it("should have a valid snapshot") {
                    expectValidSnapshot(subject, device: .phone6_Portrait)
                }
            }

            describe("snapshot, username suggestions") {
                beforeEach {
                    subject.showUsernameSuggestions(["aaa", "bbb", "ccc"])
                }
                it("should have a valid snapshot") {
                    expectValidSnapshot(subject, device: .phone6_Portrait)
                }
            }

            describe("changing text") {
                beforeEach {
                    _ = subject.textField(UITextField(), shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "")
                }
                it("should call 'validate' on the delegate") {
                    expect(delegate.didValidate) == true
                }
            }

        }
    }
}
