////
///  MapperSpec.swift
//

@testable import Ello
import Quick
import Nimble
import Moya


class MapperSpec: QuickSpec {
    override func spec() {
        describe("Mapper") {
            describe("+mapToObjectArray:type:") {
                it("returns an array of mapped domain objects") {
                    let friendData = stubbedJSONDataArray("artist_invites", "artist_invites")
                    let artistInvites = Mapper.mapToObjectArray(friendData, type: .artistInvitesType)

                    expect(artistInvites.first).to(beAKindOf(ArtistInvite.self))
                }
            }

            describe("+mapToObject:type:") {
                it("returns a mapped domain objects") {
                    let userData = stubbedJSONData("user", "users")
                    let user = Mapper.mapToObject(userData, type: .usersType)

                    expect(user).toNot(beNil())
                    expect(user).to(beAKindOf(User.self))
                }
            }
        }
    }
}
