////
///  ProfileHeaderStatsPresenterSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileHeaderStatsPresenterSpec: QuickSpec {
    func createUser(isEllo: Bool = false, postsCount: Int = 0, followingCount: Int = 0, followersCount: Int = 0, lovesCount: Int = 0) -> User {
        return User.stub([
            "username": isEllo ? "ello" : "user",
            "postsCount": postsCount,
            "followingCount": followingCount,
            "followersCount": followersCount,
            "lovesCount": lovesCount,
            "totalViewsCount": 0
            ])
    }

    override func spec() {
        describe("ProfileHeaderStatsPresenter") {
            it("should assign posts count") {
                let user = self.createUser(postsCount: 123)
                expect(user.hasProfileData) == true
                let view = ProfileHeaderStatsCell()
                ProfileHeaderStatsPresenter.configure(view, user: user, currentUser: nil)
                expect(view.postsCount) == "123"
            }
            it("should round posts count") {
                let user = self.createUser(postsCount: 1_234)
                expect(user.hasProfileData) == true
                let view = ProfileHeaderStatsCell()
                ProfileHeaderStatsPresenter.configure(view, user: user, currentUser: nil)
                expect(view.postsCount) == "1.2K"
            }

            it("should assign followers count") {
                let user = self.createUser(followersCount: 123)
                expect(user.hasProfileData) == true
                let view = ProfileHeaderStatsCell()
                ProfileHeaderStatsPresenter.configure(view, user: user, currentUser: nil)
                expect(view.followersCount) == "123"
                expect(view.followersEnabled) == true
            }
            it("should disable 0 followers") {
                let user = self.createUser(followersCount: 0)
                expect(user.hasProfileData) == true
                let view = ProfileHeaderStatsCell()
                ProfileHeaderStatsPresenter.configure(view, user: user, currentUser: nil)
                expect(view.followersEnabled) == false
            }
            it("should disable ∞ followers") {
                let user = self.createUser(isEllo: true)
                expect(user.hasProfileData) == true
                let view = ProfileHeaderStatsCell()
                ProfileHeaderStatsPresenter.configure(view, user: user, currentUser: nil)
                expect(view.followersEnabled) == false
            }
            it("should support followers string") {
                let user = self.createUser(isEllo: true)
                expect(user.hasProfileData) == true
                let view = ProfileHeaderStatsCell()
                ProfileHeaderStatsPresenter.configure(view, user: user, currentUser: nil)
                expect(view.followersCount) == "∞"
            }

            it("should assign following count") {
                let user = self.createUser(followingCount: 123)
                let view = ProfileHeaderStatsCell()
                ProfileHeaderStatsPresenter.configure(view, user: user, currentUser: nil)
                expect(view.followingCount) == "123"
                expect(view.followingEnabled) == true
            }
            it("should disable 0 following count") {
                let user = self.createUser(followingCount: 0)
                expect(user.hasProfileData) == true
                let view = ProfileHeaderStatsCell()
                ProfileHeaderStatsPresenter.configure(view, user: user, currentUser: nil)
                expect(view.followingEnabled) == false
            }
            it("should round following count") {
                let user = self.createUser(followingCount: 1_234_000)
                let view = ProfileHeaderStatsCell()
                ProfileHeaderStatsPresenter.configure(view, user: user, currentUser: nil)
                expect(view.followingCount) == "1.2M"
            }

            it("should assign loves count") {
                let user = self.createUser(lovesCount: 123)
                expect(user.hasProfileData) == true
                let view = ProfileHeaderStatsCell()
                ProfileHeaderStatsPresenter.configure(view, user: user, currentUser: nil)
                expect(view.lovesCount) == "123"
            }
            it("should round loves count") {
                let user = self.createUser(lovesCount: 1_567_000_000)
                expect(user.hasProfileData) == true
                let view = ProfileHeaderStatsCell()
                ProfileHeaderStatsPresenter.configure(view, user: user, currentUser: nil)
                expect(view.lovesCount) == "1.6B"
            }
        }
    }
}
