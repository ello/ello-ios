////
///  ProfileServiceSpec.swift
//

import Foundation

@testable import Ello
import Quick
import Moya
import Nimble

class ProfileServiceSpec: QuickSpec {
    override func spec() {
        describe("-loadCurrentUser") {

            let profileService = ProfileService()

            context("success") {
                it("Calls success with a User") {
                    var loadedUser: User?

                    profileService.loadCurrentUser()
                        .then { user in
                            loadedUser = user
                        }
                        .ignoreErrors()

                    expect(loadedUser).toNot(beNil())

                    //smoke test the user
                    expect(loadedUser!.id) == "42"
                    expect(loadedUser!.username) == "archer"
                    expect(loadedUser!.formattedShortBio) == "<p>Have been <strong>spying</strong> for a while now.</p>"
                    expect(loadedUser!.coverImageURL(viewsAdultContent: true)?.absoluteString) == "https://d1qqdyhbrvi5gr.cloudfront.net/uploads/user/cover_image/565/ello-hdpi-768defd5.jpg"
                }
            }

        }

        describe("updateUserProfile") {
            let profileService = ProfileService()

            context("success") {
                it("Calls success with a User") {
                    var returnedUser: User?

                    profileService.updateUserProfile([:])
                        .thenFinally { user in
                            returnedUser = user
                        }
                        .ignoreErrors()

                    expect(returnedUser).toNot(beNil())

                    //smoke test the user
                    expect(returnedUser?.id) == "42"
                    expect(returnedUser?.username) == "odinarcher"
                    expect(returnedUser?.formattedShortBio) == "<p>I work for <strong>Odin</strong> now! MOTHER!</p>"
                }
            }
        }
    }
}
