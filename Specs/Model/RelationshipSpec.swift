import Ello
import Quick
import Nimble


class RelationshipPrioritySpec: QuickSpec {
    override func spec() {
        describe("initWithStringValue:") {
            context("when the string matches a raw value") {
                it("returns a Relationship created from the raw value"){
                    let relationship = RelationshipPriority(stringValue: "friend")

                    expect(relationship).to(equal(RelationshipPriority.Following))
                }
            }

            context("when the string doesn't match a raw value") {
                it("returns Relationship.None"){
                    let relationship = RelationshipPriority(stringValue: "bad_string")

                    expect(relationship).to(equal(RelationshipPriority.None))
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
                    expect(relationship.createdAt).to(beAKindOf(NSDate.self))
                    expect(relationship.owner!.relationshipPriority.rawValue) == "self"
                    expect(relationship.subject!.relationshipPriority.rawValue) == "friend"
                }
            }

            context("blocking an abusive user") {
                it("parses correctly") {
                    let parsedRelationship = stubbedJSONData("relationships_blocking_an_abusive_user", "relationships")
                    let relationship = Relationship.fromJSON(parsedRelationship) as! Relationship
                    expect(relationship.createdAt).to(beAKindOf(NSDate.self))
                    expect(relationship.owner!.relationshipPriority.rawValue) == "self"
                    expect(relationship.subject!.relationshipPriority.rawValue) == "block"
                }
            }

            context("making a relationship inactive") {
                it("parses correctly") {
                    let parsedRelationship = stubbedJSONData("relationships_making_a_relationship_inactive", "relationships")
                    let relationship = Relationship.fromJSON(parsedRelationship) as! Relationship
                    expect(relationship.createdAt).to(beAKindOf(NSDate.self))
                    expect(relationship.owner!.relationshipPriority.rawValue) == "self"
                    expect(relationship.subject!.relationshipPriority.rawValue) == "inactive"
                }
            }
        }

        describe("NSCoding") {

            var filePath = ""
            if let url = NSURL(string: NSFileManager.ElloDocumentsDir()) {
                filePath = url.URLByAppendingPathComponent("UserSpec")!.absoluteString!
            }

            afterEach {
                do {
                     try NSFileManager.defaultManager().removeItemAtPath(filePath)
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
                    let expectedCreatedAt = NSDate()
                    let relationship: Relationship = stub([
                        "id": "relationship",
                        "createdAt": expectedCreatedAt,
                        "owner": User.stub(["id": "123"]),
                        "subject": User.stub(["id": "456"])
                    ])

                    NSKeyedArchiver.archiveRootObject(relationship, toFile: filePath)
                    let unArchivedRelationship = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as! Relationship
                    expect(unArchivedRelationship.id) == "relationship"
                    expect(unArchivedRelationship.createdAt) == expectedCreatedAt
                    expect(unArchivedRelationship.owner!.id) == "123"
                    expect(unArchivedRelationship.subject!.id) == "456"
                }
            }

        }
    }
}
