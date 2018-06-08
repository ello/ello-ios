////
///  ProfileHeaderAvatarPresenterSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileHeaderAvatarPresenterSpec: QuickSpec {
    override func spec() {
        describe("ProfileHeaderAvatarPresenter") {
            context("has avatar cached") {
                it("assigns avatar image") {
                    let user = User.stub([:])
                    let view = ProfileHeaderAvatarCell()
                    let avatarImage = specImage(named: "specs-avatar")!
                    TemporaryCache.save(.avatar, image: avatarImage)
                    ProfileHeaderAvatarPresenter.configure(view, user: user, currentUser: user)

                    expect(view.avatarImage) == avatarImage
                    expect(view.avatarURL).to(beNil())

                    TemporaryCache.clear()
                }
            }

            context("does not have avatar cached") {
                it("should assigns avatar url") {

                    let attachment = Attachment.stub([
                        "url": "http://ello.co/avatar.png",
                        "height": 0,
                        "width": 0,
                        "type": "png",
                        "size": 0]
                    )
                    let asset = Asset.stub(["attachment": attachment])

                    let user = User.stub(["avatar": asset])
                    let view = ProfileHeaderAvatarCell()
                    ProfileHeaderAvatarPresenter.configure(view, user: user, currentUser: nil)

                    expect(view.avatarImage).to(beNil())
                    expect(view.avatarURL?.absoluteString) == "http://ello.co/avatar.png"
                }
            }
        }
    }
}
