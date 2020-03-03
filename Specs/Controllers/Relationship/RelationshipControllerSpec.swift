////
///  RelationshipControllerSpec.swift
//


@testable import Ello
import Quick
import Nimble
import Moya


class RelationshipControllerSpec: QuickSpec {

    override func spec() {
        var subject: RelationshipController!

        beforeEach({
            let presentingController = UIViewController()
            let chainable = ResponderChainableController(
                controller: presentingController,
                next: { return presentingController.next }
            )
            showController(presentingController)

            subject = RelationshipController(responderChainable: chainable)

        })

        describe("RelationshipController") {

            describe("-relationshipTapped:relationship:complete:") {
                // extensively tested in RelationshipControlSpec
            }

            describe("-updateRelationship:relationship:complete:") {

                it("succeeds") {
                    var expectedStatus: RelationshipRequestStatus = .failure

                    subject.updateRelationship(
                        "",
                        userId: "test-user-id",
                        prev: RelationshipPriorityWrapper(priority: .none),
                        relationshipPriority: RelationshipPriorityWrapper(priority: .following)
                    ) {
                        (statusWrapper, _, _) in
                        expectedStatus = statusWrapper.status
                    }
                    expect(expectedStatus).to(equal(RelationshipRequestStatus.success))
                }

                it("fails") {
                    ElloProvider.moya = ElloProvider.ErrorStubbingProvider()

                    var expectedStatus: RelationshipRequestStatus = .success

                    subject.updateRelationship(
                        "",
                        userId: "test-user-id",
                        prev: RelationshipPriorityWrapper(priority: .none),
                        relationshipPriority: RelationshipPriorityWrapper(priority: .following)
                    ) {
                        (statusWrapper, _, _) in
                        expectedStatus = statusWrapper.status
                    }
                    expect(expectedStatus).to(equal(RelationshipRequestStatus.failure))
                }
            }

            describe("-launchBlockModal:userAtName:relationship:changeClosure:") {

                it("launches the block user modal view controller") {
                    subject.launchBlockModal(
                        "user-id",
                        userAtName: "@666",
                        relationshipPriority: RelationshipPriorityWrapper(priority: .following)
                    ) {
                        _ in
                    }
                    let presentedVC = subject.responderChainable.controller?.presentedViewController
                        as? BlockUserModalViewController
                    expect(presentedVC).to(beAKindOf(BlockUserModalViewController.self))
                }

            }

        }
    }
}
