////
///  UserServiceSpec.swift
//

@testable import Ello
import Quick
import Nimble


class UserServiceSpec: QuickSpec {
    override func spec() {
        describe("UserService") {
            var subject: UserService!
            beforeEach {
                subject = UserService()
            }
            describe("join(email:username:password:invitationCode:)") {
                it("stores the email and password in the keychain") {
                    subject.join(
                        email: "fake@example.com",
                        username: "fake-username",
                        password: "fake-password",
                        invitationCode: .none,
                        success: {},
                        failure: .none
                    )

                    let authToken = AuthToken()
                    expect(authToken.username) == "fake-username"
                    expect(authToken.password) == "fake-password"
                }
            }
        }
    }
}
