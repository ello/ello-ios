////
///  JoinViewControllerSpec.swift
//

@testable import Ello
import Quick
import Nimble


class JoinViewControllerSpec: QuickSpec {
    class MockScreen: JoinScreenProtocol {
        var blackBarIsVisible: Bool = false
        var prompt: String? = ""
        var email: String = ""
        var username: String = ""
        var password: String = ""
        var isOnePasswordAvailable: Bool = false

        var loadingHUDVisible = false
        var emailError: String?
        var usernameError: String?
        var passwordError: String?
        var termsError: String?
        var error: String?
        var usernames: [String]?
        var isEmailValid: Bool?
        var isUsernameValid: Bool?
        var isPasswordValid: Bool?
        var isTermsChecked: Bool?
        var resignedFirstResponder = false

        func loadingHUD(visible: Bool) {
            loadingHUDVisible = visible
        }

        func hideUsernameSuggestions() {
            self.usernames = nil
        }

        func showUsernameSuggestions(_ usernames: [String]) {
            self.usernames = usernames
        }
        func showUsernameError(_ text: String) {
            usernameError = text
        }
        func hideUsernameError() {
            usernameError = ""
        }

        func showEmailError(_ text: String) {
            emailError = text
        }
        func hideEmailError() {
            emailError = ""
        }

        func showPasswordError(_ text: String) {
            passwordError = text
        }
        func hidePasswordError() {
            passwordError = ""
        }

        func showTermsError(_ text: String) {
            termsError = text
        }
        func hideTermsError() {
            termsError = ""
        }

        func showError(_ text: String) {
            error = text
        }

        func resignFirstResponder() -> Bool {
            resignedFirstResponder = true
            return true
        }

        func applyValidation(emailValid: Bool, usernameValid: Bool, passwordValid: Bool) {
            self.isEmailValid = emailValid
            self.isUsernameValid = usernameValid
            self.isPasswordValid = passwordValid
        }
    }

    override func spec() {
        describe("JoinViewController") {
            var subject: JoinViewController!
            var mockScreen: MockScreen!

            beforeEach {
                subject = JoinViewController()
                mockScreen = MockScreen()
                subject.screen = mockScreen
                showController(subject)
            }

            describe("validating inputs") {
                context("missing inputs") {
                    beforeEach {
                        subject.validate(email: "", username: "", password: "")
                    }
                    it("should report error to screen") {
                        expect(mockScreen.isEmailValid).to(beNil())
                        expect(mockScreen.isUsernameValid).to(beNil())
                        expect(mockScreen.isPasswordValid).to(beNil())
                    }
                }
                context("invalid inputs") {
                    beforeEach {
                        subject.validate(email: "invalid", username: "a", password: "short")
                    }
                    it("should report error to screen") {
                        expect(mockScreen.isEmailValid).to(beNil())
                        expect(mockScreen.isUsernameValid).to(beNil())
                        expect(mockScreen.isPasswordValid).to(beNil())
                    }
                }

                context("missing email") {
                    beforeEach {
                        subject.validate(email: "", username: "valid", password: "password")
                    }
                    it("should report error to screen") {
                        expect(mockScreen.isEmailValid).to(beNil())
                        expect(mockScreen.isUsernameValid) == true
                        expect(mockScreen.isPasswordValid) == true
                    }
                }
                context("invalid email") {
                    beforeEach {
                        subject.validate(email: "invalid", username: "valid", password: "password")
                    }
                    it("should report error to screen") {
                        expect(mockScreen.isEmailValid).to(beNil())
                        expect(mockScreen.isUsernameValid) == true
                        expect(mockScreen.isPasswordValid) == true
                    }
                }

                context("missing username") {
                    beforeEach {
                        subject.validate(
                            email: "valid@email.com",
                            username: "",
                            password: "password"
                        )
                    }
                    it("should report error to screen") {
                        expect(mockScreen.isEmailValid) == true
                        expect(mockScreen.isUsernameValid).to(beNil())
                        expect(mockScreen.isPasswordValid) == true
                    }
                }
                context("invalid username") {
                    beforeEach {
                        subject.validate(
                            email: "valid@email.com",
                            username: "a",
                            password: "password"
                        )
                    }
                    it("should report error to screen") {
                        expect(mockScreen.isEmailValid) == true
                        expect(mockScreen.isUsernameValid).to(beNil())
                        expect(mockScreen.isPasswordValid) == true
                    }
                }

                context("missing password") {
                    beforeEach {
                        subject.validate(email: "valid@email.com", username: "valid", password: "")
                    }
                    it("should report error to screen") {
                        expect(mockScreen.isEmailValid) == true
                        expect(mockScreen.isUsernameValid) == true
                        expect(mockScreen.isPasswordValid).to(beNil())
                    }
                }
                context("invalid password") {
                    beforeEach {
                        subject.validate(
                            email: "valid@email.com",
                            username: "valid",
                            password: "short"
                        )
                    }
                    it("should report error to screen") {
                        expect(mockScreen.isEmailValid) == true
                        expect(mockScreen.isUsernameValid) == true
                        expect(mockScreen.isPasswordValid).to(beNil())
                    }
                }
            }

            describe("submitting successful credentials") {
                let email = "email@email.com"
                let username = "username"
                let password = "password"
                beforeEach {
                    var token = AuthToken()
                    token.username = ""
                    token.password = ""
                    mockScreen.email = email
                    mockScreen.username = username
                    mockScreen.password = password
                    subject.submit(email: email, username: username, password: password)
                }

                it("stores the email and password") {
                    let token = AuthToken()
                    expect(token.username) == email
                    expect(token.password) == password
                }
            }

            describe("submitting") {
                context("input is valid") {
                    let email = "email@email.com"
                    let username = "username"
                    let password = "password"
                    beforeEach {
                        mockScreen.email = email
                        mockScreen.username = username
                        mockScreen.password = password
                        subject.submit(email: email, username: username, password: password)
                    }
                    it("should show loadingHUD") {
                        expect(mockScreen.loadingHUDVisible) == true
                    }
                    it("should hide errors") {
                        expect(mockScreen.message) == ""
                        expect(mockScreen.emailError) == ""
                        expect(mockScreen.usernameError) == ""
                        expect(mockScreen.passwordError) == ""
                    }
                }

                context("input is invalid") {
                    let email = "not-email"
                    let username = "a"
                    let password = "short"
                    beforeEach {
                        mockScreen.email = email
                        mockScreen.username = username
                        mockScreen.password = password
                        subject.submit(email: email, username: username, password: password)
                    }
                    it("should hide loadingHUD") {
                        expect(mockScreen.loadingHUDVisible) == false
                    }
                    it("should show errors") {
                        expect(mockScreen.emailError).notTo(beNil())
                        expect(mockScreen.usernameError).notTo(beNil())
                        expect(mockScreen.passwordError).notTo(beNil())
                    }
                }
            }
        }
    }
}
