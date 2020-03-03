@testable import Ello
import Quick
import Nimble


class RelationshipPrioritySpec: QuickSpec {
    override func spec() {
        describe("RelationshipPriority") {
            context("when the string matches a raw value") {
                it("returns a Relationship created from the raw value") {
                    let priority = RelationshipPriority(stringValue: "friend")

                    expect(priority) == RelationshipPriority.following
                }
            }

            context("when the string doesn't match a raw value") {
                it("returns RelationshipPriority.none") {
                    let priority = RelationshipPriority(stringValue: "bad_string")

                    expect(priority) == RelationshipPriority.none
                }
            }

            context("when the string is 'noise'") {
                it("returns RelationshipPriority.following") {
                    let priority = RelationshipPriority(stringValue: "noise")

                    expect(priority) == RelationshipPriority.following
                }
            }
        }
    }
}
