////
///  RelationshipServiceSpec.swift
//

@testable import Ello
import Quick
import Nimble


class RelationshipServiceSpec: QuickSpec {
    override func spec() {
        describe("RelationshipService") {
            var subject: RelationshipService!
            beforeEach {
                subject = RelationshipService()
            }

            describe("updateRelationship(currentUserId:userId:relationshipPriority:)") {
                context("when currentUserId == nil") {
                    it("should not have optimistic result") {
                        let (optimisticResult, _) = subject.updateRelationship(
                            currentUserId: nil,
                            userId: "42",
                            relationshipPriority: .following
                        )
                        expect(optimisticResult).to(beNil())
                    }
                }

                context("when currentUser and user are available") {
                    it("should return an optimisticResult") {
                        let currentUser: User = stub([:])
                        let user: User = stub([:])
                        ElloLinkedStore.shared.setObject(user, forKey: user.id, type: .usersType)
                        let (optimisticResult, _) = subject.updateRelationship(
                            currentUserId: currentUser.id,
                            userId: user.id,
                            relationshipPriority: .following
                        )
                        expect(optimisticResult).notTo(beNil())
                    }

                    it("should set the relationshipPriority") {
                        let currentUser: User = stub([:])
                        let user: User = stub(["relationshipPriority": RelationshipPriority.none])
                        ElloLinkedStore.shared.setObject(user, forKey: user.id, type: .usersType)

                        _ = subject.updateRelationship(
                            currentUserId: currentUser.id,
                            userId: user.id,
                            relationshipPriority: .following
                        )
                        let newUser: User? = ElloLinkedStore.shared.getObject(
                            user.id,
                            type: .usersType
                        ) as? User
                        expect(newUser?.relationshipPriority) == RelationshipPriority.following
                    }
                }
            }
        }
    }
}
