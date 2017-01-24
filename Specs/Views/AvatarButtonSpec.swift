////
///  AvatarButtonSpec.swift
//

@testable import Ello
import Quick
import Nimble


class AvatarButtonSpec: QuickSpec {
    override func spec() {
        describe("AvatarButton") {
            context("assigning user") {
                var subject: AvatarButton!
                var user: User!
                let url = URL(string: "http://www.example.com/image")!

                beforeEach {
                    subject = AvatarButton()
                    user = User.empty()
                }

                it("should assign the asset url via User") {
                    let asset = Asset(url: url as URL)
                    user.avatar = asset
                    subject.setUserAvatarURL(user.avatarURL())
                    expect(subject.imageURL) == url as URL
                }

                it("should assign the asset url") {
                    subject.setUserAvatarURL(url as URL)
                    expect(subject.imageURL) == url as URL
                }

                it("should assign the asset large url") {
                    let asset = Asset(id: NSUUID().uuidString)
                    let attachment = Attachment(url: url as URL)
                    asset.large = attachment
                    user.avatar = asset
                    subject.setUserAvatarURL(user.avatarURL())
                    expect(subject.imageURL) == url as URL
                }

                it("should assign the asset optimized url") {
                    let asset = Asset(id: NSUUID().uuidString)
                    let attachment = Attachment(url: url as URL)
                    asset.optimized = attachment
                    user.avatar = asset
                    subject.setUserAvatarURL(user.avatarURL())
                    expect(subject.imageURL) == url as URL
                }

            }
        }
    }
}
