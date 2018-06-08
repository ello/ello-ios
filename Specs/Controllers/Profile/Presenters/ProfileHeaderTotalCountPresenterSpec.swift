////
///  ProfileHeaderTotalCountPresenterSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileHeaderTotalCountPresenterSpec: QuickSpec {
    override func spec() {
        describe("ProfileHeaderTotalCountPresenter") {

            it("assigns posts count") {
                let user = User.stub([
                    "postsCount": 1,
                    "followingCount": 1,
                    "followersCount": 1,
                    "lovesCount": 1,
                    "totalViewsCount": 2_401_000,
                    ])
                let view = ProfileHeaderTotalCountCell()
                ProfileHeaderTotalCountPresenter.configure(view, user: user, currentUser: nil)

                expect(view.count) == "2.4M"
            }

            it("renders nothing when no totalViewCount is present") {
                let user = User.stub([:])
                let view = ProfileHeaderTotalCountCell()
                ProfileHeaderTotalCountPresenter.configure(view, user: user, currentUser: nil)

                expect(view.count).to(beNil())
            }
        }
    }
}
