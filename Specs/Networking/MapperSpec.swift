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
                    let friendData = stubbedJSONDataArray("friends", "activities")
                    let activities = Mapper.mapToObjectArray(friendData, type: .activitiesType)

                    expect(notifications.first).to(beAKindOf(Notification.self))
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
