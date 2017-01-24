////
///  MapperSpec.swift
//

@testable import Ello
import Quick
import Nimble
import Moya


class MapperSpec: QuickSpec {
    override func spec() {

        describe("+mapJSON:") {

            var loadedData: Data!

            context("valid json") {

                it("returns a valid data, nil error tuple") {
                    loadedData = stubbedData("user")
                    let (mappedJSON, error) = Mapper.mapJSON(loadedData)

                    expect(mappedJSON).toNot(beNil())
                    expect(error).to(beNil())
                }
            }

            context("invalid json") {

                it("returns a nil nsdata, valid error tuple") {
                    loadedData = "invalid".data(using: String.Encoding.utf8)
                    let (mappedJSON, error) = Mapper.mapJSON(loadedData)

                    expect(mappedJSON).to(beNil())
                    expect(error).toNot(beNil())
                }
            }

            context("empty data") {

                it("returns a nil data, valid error tuple") {
                    loadedData = stubbedData("empty")
                    let (mappedJSON, error) = Mapper.mapJSON(loadedData)

                    expect(mappedJSON).to(beNil())
                    expect(error).toNot(beNil())
                }
            }

        }

        describe("+mapToObjectArray:type:") {

            context("valid input") {

                it("returns an array of mapped domain objects") {
                    let friendData = stubbedJSONDataArray("friends", "activities")
                    let activities = Mapper.mapToObjectArray(friendData, type: .activitiesType)

                    expect(activities.first).to(beAKindOf(Activity.self))
                }
            }
        }

        describe("+mapToObject:type:") {

            context("valid input") {

                it("returns a mapped domain objects") {
                    let userData = stubbedJSONData("user", "users")
                    let user = Mapper.mapToObject(userData as AnyObject, type: .usersType)

                    expect(user).toNot(beNil())
                    expect(user).to(beAKindOf(User.self))
                }
            }

            context("invalid input") {

                it("returns nil") {
                    let invalidAnyObject: AnyObject = NSString(string: "invalid") as AnyObject

                    expect(Mapper.mapToObject(invalidAnyObject, type: .usersType)).to(beNil())
                }
            }
        }
    }
}
