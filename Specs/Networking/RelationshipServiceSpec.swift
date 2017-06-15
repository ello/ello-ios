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
                subject.updateRelationship(currentUserId: "", userId: "42", relationshipPriority: RelationshipPriority.following).1
                    .thenFinally { _ in
                        loadedSuccessfully = true
                    }
                    .ignoreErrors()
                expect(loadedSuccessfully).to(beTrue())
            }

            it("fails") {
                ElloProvider.sharedProvider = ElloProvider.ErrorStubbingProvider()
                var loadedSuccessfully = true
                subject.updateRelationship(currentUserId: "", userId: "42", relationshipPriority: RelationshipPriority.following).1
                    .thenFinally { _ in
                        loadedSuccessfully = true
                    }
                    .catch { _ in
                        loadedSuccessfully = false
                    }

                expect(loadedSuccessfully).to(beFalse())
            }
        }
    }
}
