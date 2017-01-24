////
///  UserServiceSpec.swift
//

import Foundation

@testable import Ello
import Quick
import Moya
import Nimble


class UserServiceSpec: QuickSpec {
    override func spec() {
        var subject = UserService()

        describe("-join") {

            context("success") {

                it("Calls success with a User") {
                    var loadedUser: User?

                    subject.join(email: "fake@example.com",
                        username: "fake-username",
                        password: "fake-password",
                        invitationCode: .none,
                        success: {
                            (user, responseConfig) in
                            loadedUser = user
                        }, failure: .none)

                    expect(loadedUser).toNot(beNil())

                    //smoke test the user
                    expect(loadedUser!.userId) == "1"
                    expect(loadedUser!.email) == "sterling@isisagency.com"
                    expect(loadedUser!.username) == "archer"
                }
            }

            xcontext("failure") {}

        }
    }
}
