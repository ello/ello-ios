////
///  ProfileHeaderNamesPresenterSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileHeaderNamesPresenterSpec: QuickSpec {
    override func spec() {
        describe("ProfileHeaderNamesPresenter") {
            it("should assign name and username") {
                let user = User.stub(["name": "jim", "username": "jimmy"])
                let view = ProfileHeaderNamesCell()
                ProfileHeaderNamesPresenter.configure(view, user: user, currentUser: nil)
                expect(view.name) == "jim"
                expect(view.username) == "@jimmy"
            }
        }
    }
}
