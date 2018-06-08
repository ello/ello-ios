////
///  ProfileBadgesPresenterSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileBadgesPresenterSpec: QuickSpec {
    override func spec() {
        describe("ProfileBadgesPresenter") {

            it("assigns badges") {
                let user = User.stub(["badges": ["featured"]])
                let view = ProfileBadgesView()
                ProfileBadgesPresenter.configure(view, user: user, currentUser: nil)

                expect(view.badges.count) == 1
            }
        }
    }
}
