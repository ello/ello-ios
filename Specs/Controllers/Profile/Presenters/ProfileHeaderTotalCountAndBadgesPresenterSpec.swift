////
///  ProfileHeaderTotalCountAndBadgesPresenterSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileHeaderTotalCountAndBadgesPresenterSpec: QuickSpec {
    override func spec() {
        describe("ProfileHeaderTotalCountAndBadgesPresenter") {

            it("assigns posts count") {
                let user = User.stub([
                    "postsCount": 1,
                    "followingCount": 1,
                    "followersCount": 1,
                    "lovesCount": 1,
                    "totalViewsCount": 2_401_000,
                    ])
                let view = ProfileHeaderTotalCountAndBadgesCell()
                ProfileHeaderTotalCountAndBadgesPresenter.configure(view, user: user, currentUser: nil)

                expect(view.count) == "2.4M"
            }

            it("renders nothing when no totalViewCount is present") {
                let user = User.stub([:])
                let view = ProfileHeaderTotalCountAndBadgesCell()
                ProfileHeaderTotalCountAndBadgesPresenter.configure(view, user: user, currentUser: nil)

                expect(view.count).to(beNil())
            }

            it("assigns badges") {
                let user = User.stub(["badges": ["featured"]])
                let view = ProfileBadgesView()
                ProfileBadgesPresenter.configure(view, user: user, currentUser: nil)

                expect(view.badges.count) == 1
            }
        }
    }
}
