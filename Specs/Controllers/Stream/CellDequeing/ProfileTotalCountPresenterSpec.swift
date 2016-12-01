////
///  ProfileTotalCountPresenterSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileTotalCountPresenterSpec: QuickSpec {
    override func spec() {
        describe("ProfileTotalCountPresenter") {

            it("assigns posts count") {
                let user = User.stub(["totalViewsCount": 2_401_000])
                let view = ProfileTotalCountView()
                ProfileTotalCountPresenter.configure(view, user: user, currentUser: nil)

                expect(view.count) == "2.4M"
            }

            it("renders nothing when no totalViewCount is present") {
                let user = User.stub([:])
                let view = ProfileTotalCountView()
                ProfileTotalCountPresenter.configure(view, user: user, currentUser: nil)

                expect(view.count).to(beNil())
            }

            it("shows cateogry badge if user is featured in one or more catgegories") {
                let category: Ello.Category = Ello.Category.stub(["id" : "1", "name" : "art"])
                let categories = [ category ]
                let user = User.stub(["categories" : categories])
                let view = ProfileTotalCountView()
                ProfileTotalCountPresenter.configure(view, user: user, currentUser: nil)

                expect(view.badgeVisible) == true
            }

            it("hides cateogry badge if user is not featured in any catgegories") {
                let user = User.stub([:])
                let view = ProfileTotalCountView()
                ProfileTotalCountPresenter.configure(view, user: user, currentUser: nil)

                expect(view.badgeVisible) == false
            }
        }
    }
}
