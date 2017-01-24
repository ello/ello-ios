////
///  RelationshipServiceSpec.swift
//

@testable import Ello
import Quick
import Nimble
import Moya


class RelationshipServiceSpec: QuickSpec {
    override func spec() {
        describe("-updateRelationship") {

            let subject = RelationshipService()

            it("succeeds") {
                var loadedSuccessfully = false
                subject.updateRelationship(currentUserId: "", userId: "42", relationshipPriority: RelationshipPriority.following,
                    success: {
                        (data, responseConfig) in
                        loadedSuccessfully = true
                    },
                    failure: { _ in }
                )
                expect(loadedSuccessfully).to(beTrue())
            }

            it("fails") {
                ElloProvider.sharedProvider = ElloProvider.ErrorStubbingProvider()
                var loadedSuccessfully = true
                subject.updateRelationship(currentUserId: "", userId: "42", relationshipPriority: RelationshipPriority.following,
                    success: {
                        (data, responseConfig) in
                        loadedSuccessfully = true
                    },
                    failure: {
                        (error, statusCode) in
                        loadedSuccessfully = false
                    }
                )
                expect(loadedSuccessfully).to(beFalse())
            }
        }
    }
}
