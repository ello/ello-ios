////
///  LoginViewControllerSpec.swift
//

@testable import Ello
import Quick
import Nimble


class LoginViewControllerSpec: QuickSpec {
    class MockScreen: LoginScreenProtocol {
        var username: String = ""
        var usernameValid: Bool? = nil
        var password: String = ""
        var passwordValid: Bool? = nil
        var onePasswordAvailable: Bool = false

        var inputsEnabled = true
        var error: String?
        var resignedFirstResponder = false

        func loadingHUD(visible: Bool) {
            inputsEnabled = !visible
        }

        func showError(_ text: String) {
            error = text
        }

        func hideError() {
            error = nil
        }

        func resignFirstResponder() -> Bool {
            resignedFirstResponder = true
            return true
        }
    }

    override func spec() {
        describe("LoginViewController") {
            var subject: LoginViewController!
            var mockScreen: MockScreen!
            beforeEach {
                subject = LoginViewController()
                mockScreen = MockScreen()
                subject.mockScreen = mockScreen
                showController(subject)
            }

            describe("submitting successful credentials") {
                let email = "email@email.com"
                let password = "password"
                beforeEach {
                    var token = AuthToken()
                    token.username = ""
                    token.password = ""
                    subject.submit(username: email, password: password)
                }
                it("stores the email and password") {
                    let token = AuthToken()
                    expect(token.username) == email
                    expect(token.password) == password
                }
            }

            describe("submitting") {

                context("input is valid email") {
                    let username = "name@example.com"
                    let password = "12345678"
                    beforeEach {
                        subject.submit(username: username, password: password)
                    }

                    it("resigns first responder") {
                        expect(mockScreen.resignedFirstResponder) == true
                    }

                    it("disables input") {
                        expect(mockScreen.inputsEnabled) == false
                    }
                }

                context("input is valid username") {
                    let username = "name"
                    let password = "12345678"
                    beforeEach {
                        subject.submit(username: username, password: password)
                    }

                    it("resigns first responder") {
                        expect(mockScreen.resignedFirstResponder) == true
                    }

                    it("disables input") {
                        expect(mockScreen.inputsEnabled) == false
                    }
                }

                context("input is invalid") {
                    let username = "invalid email"
                    let password = "abc"
                    beforeEach {
                        subject.submit(username: username, password: password)
                    }

                    it("resigns first responder") {
                        expect(mockScreen.resignedFirstResponder) == true
                    }

                    it("does not disable input") {
                        expect(mockScreen.inputsEnabled) == true
                    }
                }
            }
        }
    }
}

