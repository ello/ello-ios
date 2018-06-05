////
///  RelationshipController.swift
//

typealias RelationshipChangeClosure = (_ relationshipPriority: RelationshipPriorityWrapper) -> Void
typealias RelationshipChangeCompletion = (_ status: RelationshipRequestStatusWrapper, _ relationship: Relationship?, _ isFinalValue: Bool) -> Void

class RelationshipRequestStatusWrapper: NSObject {
    let status: RelationshipRequestStatus
    init(status: RelationshipRequestStatus) { self.status = status }
}

enum RelationshipRequestStatus: String {
    case success
    case failure
}

@objc
protocol RelationshipResponder: class {
    func relationshipTapped(_ userId: String, prev prevRelationshipPriority: RelationshipPriorityWrapper, relationshipPriority: RelationshipPriorityWrapper, complete: @escaping RelationshipChangeCompletion)
    func launchBlockModal(_ userId: String, userAtName: String, relationshipPriority: RelationshipPriorityWrapper, changeClosure: @escaping RelationshipChangeClosure)
    func updateRelationship(_ currentUserId: String, userId: String, prev prevRelationshipPriority: RelationshipPriorityWrapper, relationshipPriority: RelationshipPriorityWrapper, complete: @escaping RelationshipChangeCompletion)
}

class RelationshipController: UIResponder {
    var currentUser: User?
    let responderChainable: ResponderChainableController

    override var canBecomeFirstResponder: Bool { return false }

    override var next: UIResponder? {
        return responderChainable.next()
    }

    init(responderChainable: ResponderChainableController) {
        self.responderChainable = responderChainable
    }

}

extension RelationshipController: RelationshipResponder {

    func relationshipTapped(
        _ userId: String,
        prev prevRelationshipPriority: RelationshipPriorityWrapper,
        relationshipPriority: RelationshipPriorityWrapper,
        complete: @escaping RelationshipChangeCompletion)
    {
        guard currentUser != nil else {
            postNotification(LoggedOutNotifications.userActionAttempted, value: .relationshipChange)
            complete(RelationshipRequestStatusWrapper(status: .success), .none, true)
            return
        }
        Tracker.shared.relationshipButtonTapped(relationshipPriority.priority, userId: userId)

        if let currentUserId = currentUser?.id {
            self.updateRelationship(currentUserId, userId: userId, prev: prevRelationshipPriority, relationshipPriority: relationshipPriority, complete: complete)
        }
    }

    func launchBlockModal(
        _ userId: String,
        userAtName: String,
        relationshipPriority: RelationshipPriorityWrapper,
        changeClosure: @escaping RelationshipChangeClosure)
    {
        let vc = BlockUserModalViewController(config: BlockUserModalConfig(userId: userId, userAtName: userAtName, relationshipPriority: relationshipPriority.priority, changeClosure: changeClosure))
        vc.currentUser = currentUser
        responderChainable.controller?.present(vc, animated: true, completion: nil)
    }

    func updateRelationship(
        _ currentUserId: String,
        userId: String,
        prev prevRelationshipPriority: RelationshipPriorityWrapper,
        relationshipPriority newRelationshipPriority: RelationshipPriorityWrapper,
        complete: @escaping RelationshipChangeCompletion)
    {
        let (optimisticRelationship, promise) = RelationshipService().updateRelationship(currentUserId: currentUserId, userId: userId, relationshipPriority: newRelationshipPriority.priority)
        if let relationship = optimisticRelationship {
            complete(RelationshipRequestStatusWrapper(status: .success), relationship, false)
        }

        promise.done { relationship in
            complete(RelationshipRequestStatusWrapper(status: .success), relationship, true)

            if let relationship = relationship {
                if let owner = relationship.owner {
                    postNotification(RelationshipChangedNotification, value: owner)
                }
                if let subject = relationship.subject {
                    postNotification(RelationshipChangedNotification, value: subject)
                }
            }

            if prevRelationshipPriority != newRelationshipPriority {
                var blockDelta = 0
                if prevRelationshipPriority.priority == .block { blockDelta -= 1 }
                if newRelationshipPriority.priority == .block { blockDelta += 1 }
                if blockDelta != 0 {
                    postNotification(BlockedCountChangedNotification, value: (userId, blockDelta))
                }

                var mutedDelta = 0
                if prevRelationshipPriority.priority == .mute { mutedDelta -= 1 }
                if newRelationshipPriority.priority == .mute { mutedDelta += 1 }
                if mutedDelta != 0 {
                    postNotification(MutedCountChangedNotification, value: (userId, mutedDelta))
                }
            }
        }
        .catch { _ in
            complete(RelationshipRequestStatusWrapper(status: .failure), nil, true)
        }
    }
}
