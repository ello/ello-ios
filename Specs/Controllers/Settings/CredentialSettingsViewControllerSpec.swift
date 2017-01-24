////
///  CredentialSettingsViewControllerSpec.swift
//

@testable import Ello
import Quick
import Nimble


class CredentialSettingsViewControllerSpec: QuickSpec {
    override func spec() {
        describe("CredentialSettingsViewController") {
            var subject: CredentialSettingsViewController!

            beforeEach {
                subject = CredentialSettingsViewController.instantiateFromStoryboard()
            }

            describe("initialization") {
                describe("storyboard") {
                    it("IBOutlets are not nil") {
                        showController(subject)
                        expect(subject.usernameView).notTo(beNil())
                        expect(subject.emailView).notTo(beNil())
                        expect(subject.passwordView).notTo(beNil())
                        expect(subject.currentPasswordField).notTo(beNil())
                        expect(subject.errorLabel).notTo(beNil())
                        expect(subject.saveButton).notTo(beNil())
                    }
                }
            }

            describe("viewDidLoad") {
                beforeEach {
                    let user: User = stub(["username": "TestName", "profile": Profile.stub(["email": "some@guy.com"])])
                    subject.currentUser = user
                    showController(subject)
                }
                it("sets the text fields from the current user") {
                    expect(subject.usernameView.textField.text) == "TestName"
                    expect(subject.emailView.textField.text) == "some@guy.com"
                    expect(subject.passwordView.textField.text) == ""
                }
            }

            describe("isUpdatable") {
                beforeEach {
                    let user: User = stub(["username": "TestName", "profile": Profile.stub(["email": "some@guy.com"])])
                    subject.currentUser = user
                    showController(subject)
                }

                context("username") {
                    context("is changed") {
                        it("isUpdatable is true") {
                            expect(subject.isUpdatable).to(beFalse())
                            subject.usernameView.textField.text = "something"
                            expect(subject.isUpdatable).to(beTrue())
                        }
                    }

                    context("is reset") {
                        it("isUpdatable is false") {
                            subject.usernameView.textField.text = "something"
                            expect(subject.isUpdatable).to(beTrue())
                            subject.usernameView.textField.text = "TestName"
                            expect(subject.isUpdatable).to(beFalse())
                        }
                    }
                }

                context("email") {
                    context("is changed") {
                        it("isUpdatable is true") {
                            expect(subject.isUpdatable).to(beFalse())
                            subject.emailView.textField.text = "no-one@email.com"
                            expect(subject.isUpdatable).to(beTrue())
                        }
                    }

                    context("is reset") {
                        it("isUpdatable is false") {
                            subject.emailView.textField.text = "no-one@email.com"
                            expect(subject.isUpdatable).to(beTrue())
                            subject.emailView.textField.text = "some@guy.com"
                            expect(subject.isUpdatable).to(beFalse())
                        }
                    }
                }

                context("password") {
                    context("is set") {
                        it("isUpdatable is true") {
                            expect(subject.isUpdatable).to(beFalse())
                            subject.passwordView.textField.text = "anything"
                            expect(subject.isUpdatable).to(beTrue())
                        }
                    }

                    context("is empty") {
                        it("isUpdatable is false") {
                            subject.passwordView.textField.text = "anything"
                            expect(subject.isUpdatable).to(beTrue())
                            subject.passwordView.textField.text = ""
                            expect(subject.isUpdatable).to(beFalse())
                        }
                    }
                }
            }

            describe("valueChanged") {
                it("calls the delegate function when email is set") {
                    showController(subject)
                    let fake = FakeCredentialSettingsDelegate()
                    subject.delegate = fake
                    subject.emailView.textField.text = "email@example.com"
                    subject.emailView.textField.sendActions(for: .editingChanged)
                    expect(fake.didCall).to(beTrue())
                }

                it("calls the delegate function when username is set") {
                    showController(subject)
                    let fake = FakeCredentialSettingsDelegate()
                    subject.delegate = fake
                    subject.usernameView.textField.text = "username"
                    subject.usernameView.textField.sendActions(for: .editingChanged)
                    expect(fake.didCall).to(beTrue())
                }

                it("calls the delegate function when password is set") {
                    showController(subject)
                    let fake = FakeCredentialSettingsDelegate()
                    subject.delegate = fake
                    subject.passwordView.textField.text = "pa$$w0rd"
                    subject.passwordView.textField.sendActions(for: .editingChanged)
                    expect(fake.didCall).to(beTrue())
                }
            }

            describe("height") {
                beforeEach {
                    let user: User = stub(["username": "TestName", "profile": Profile.stub(["email": "some@guy.com"])])
                    subject.currentUser = user
                    showController(subject)
                }

                context("isUpdatable is true") {
                    context("errorLabel is empty") {
                        it("returns 89 * 3 + 128") {
                            subject.passwordView.textField.text = "anything"
                            expect(subject.isUpdatable).to(beTrue())
                            expect(subject.height) == 89 * 3 + 128
                        }
                    }

                    context("errorLabel is not empty") {
                        it("returns 89 * 3 + 128 + errorLabel height + 8") {
                            subject.passwordView.textField.text = "anything"
                            subject.errorLabel.text = "something"
                            subject.errorLabel.sizeToFit()
                            expect(subject.isUpdatable).to(beTrue())
                            expect(subject.height) == 89 * 3 + 128 + subject.errorLabel.frame.height + 8
                        }
                    }
                }

                context("isUpdatable is false") {
                    it("returns 89 * 3") {
                        expect(subject.isUpdatable).to(beFalse())
                        expect(subject.height) == 89 * 3
                    }
                }
            }
        }
    }
}

class FakeCredentialSettingsDelegate: CredentialSettingsDelegate {
    var didCall = false
    var didSetUser = false

    func credentialSettingsUserChanged(_ user: User) {
        didSetUser = true
    }

    func credentialSettingsDidUpdate() {
        didCall = true
    }
}
