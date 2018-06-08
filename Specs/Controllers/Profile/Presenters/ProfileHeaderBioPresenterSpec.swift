////
///  ProfileHeaderBioPresenterSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileHeaderBioPresenterSpec: QuickSpec {
    override func spec() {
        describe("ProfileHeaderBioPresenter") {
            it("should assign bio") {
                let user = User.stub(["formattedShortBio": "<p>bio</p>"])
                let view = ProfileHeaderBioCell()
                ProfileHeaderBioPresenter.configure(view, user: user, currentUser: nil)
                expect(view.bio) == "<p>bio</p>"
            }
        }
    }
}
