@testable import Ello
import Quick
import Nimble


class RelationshipPrioritySpec: QuickSpec {
    override func spec() {
        describe("initWithStringValue:") {
            context("when the string matches a raw value") {
                it("returns a Relationship created from the raw value"){
                    let priority = RelationshipPriority(stringValue: "friend")

                    expect(priority) == RelationshipPriority.following
                }
            }

            context("when the string doesn't match a raw value") {
                it("returns RelationshipPriority.none"){
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

class RelationshipSpec: QuickSpec {
    override func spec() {

        describe("+fromJSON:") {

            context("following a user as friend") {
                it("parses correctly") {
                    let parsedRelationship = stubbedJSONData("relationships_following_a_user_as_friend", "relationships")
                    let relationship = Relationship.fromJSON(parsedRelationship) as! Relationship
                    expect(relationship.createdAt).notTo(beNil())
                    expect(relationship.owner!.relationshipPriority.rawValue) == "self"
                    expect(relationship.subject!.relationshipPriority.rawValue) == "friend"
                }
            }

            context("blocking an abusive user") {
                it("parses correctly") {
                    let parsedRelationship = stubbedJSONData("relationships_blocking_an_abusive_user", "relationships")
                    let relationship = Relationship.fromJSON(parsedRelationship) as! Relationship
                    expect(relationship.createdAt).notTo(beNil())
                    expect(relationship.owner!.relationshipPriority.rawValue) == "self"
                    expect(relationship.subject!.relationshipPriority.rawValue) == "block"
                }
            }

            context("making a relationship inactive") {
                it("parses correctly") {
                    let parsedRelationship = stubbedJSONData("relationships_making_a_relationship_inactive", "relationships")
                    let relationship = Relationship.fromJSON(parsedRelationship) as! Relationship
                    expect(relationship.createdAt).notTo(beNil())
                    expect(relationship.owner!.relationshipPriority.rawValue) == "self"
                    expect(relationship.subject!.relationshipPriority.rawValue) == "inactive"
                }
            }
        }

        describe("NSCoding") {

            var filePath = ""
            if let url = URL(string: FileManager.ElloDocumentsDir()) {
                filePath = url.appendingPathComponent("UserSpec").absoluteString
            }

            afterEach {
                do {
                     try FileManager.default.removeItem(atPath: filePath)
                }
                catch {

                }
            }

            context("encoding") {
                it("encodes successfully") {
                    let relationship: Relationship = stub([:])
                    let wasSuccessfulArchived = NSKeyedArchiver.archiveRootObject(relationship, toFile: filePath)
                    expect(wasSuccessfulArchived).to(beTrue())
                }
            }

            context("decoding") {

                it("decodes successfully") {
                    let expectedCreatedAt = Globals.now
                    let relationship: Relationship = stub([
                        "id": "relationship",
                        "createdAt": expectedCreatedAt,
                        "owner": User.stub(["id": "123"]),
                        "subject": User.stub(["id": "456"])
                    ])

                    NSKeyedArchiver.archiveRootObject(relationship, toFile: filePath)
                    let unArchivedRelationship = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as! Relationship
                    expect(unArchivedRelationship.id) == "relationship"
                    expect(unArchivedRelationship.createdAt) == expectedCreatedAt as Date
                    expect(unArchivedRelationship.owner!.id) == "123"
                    expect(unArchivedRelationship.subject!.id) == "456"
                }
            }

        }
    }
}
