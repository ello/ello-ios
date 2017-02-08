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
    case success = "success"
    case failure = "failure"
}

@objc
protocol RelationshipControllerResponder: class {
    func shouldSubmitRelationship(_ userId: String, relationshipPriority: RelationshipPriorityWrapper) -> Bool
    func relationshipChanged(_ userId: String, status: RelationshipRequestStatusWrapper, relationship: Relationship?)
}

@objc
protocol RelationshipResponder: class {
    func relationshipTapped(_ userId: String, prev prevRelationshipPriority: RelationshipPriorityWrapper, relationshipPriority: RelationshipPriorityWrapper, complete: @escaping RelationshipChangeCompletion)
    func launchBlockModal(_ userId: String, userAtName: String, relationshipPriority: RelationshipPriorityWrapper, changeClosure: @escaping RelationshipChangeClosure)
    func updateRelationship(_ currentUserId: String, userId: String, prev prevRelationshipPriority: RelationshipPriorityWrapper, relationshipPriority: RelationshipPriorityWrapper, complete: @escaping RelationshipChangeCompletion)
}

class RelationshipController: UIResponder {
    var currentUser: User?
    var responderChainable: ResponderChainableController?

    override var next: UIResponder? {
        return responderChainable?.next()
    }

}

// MARK: RelationshipController: RelationshipResponder
extension RelationshipController: RelationshipResponder {

    func relationshipTapped(
        _ userId: String,
        prev prevRelationshipPriority: RelationshipPriorityWrapper,
        relationshipPriority: RelationshipPriorityWrapper,
        complete: @escaping RelationshipChangeCompletion)
    {
        Tracker.shared.relationshipButtonTapped(relationshipPriority.priority, userId: userId)
        let responder = self.target(forAction: #selector(RelationshipControllerResponder.shouldSubmitRelationship(_:relationshipPriority:)), withSender: self) as? RelationshipControllerResponder
        if let shouldSubmit = responder?.shouldSubmitRelationship(userId, relationshipPriority: relationshipPriority), !shouldSubmit {
            let relationship = Relationship(id: UUID().uuidString, createdAt: Date(), ownerId: "", subjectId: userId)
            complete(RelationshipRequestStatusWrapper(status: .success), relationship, true)
            return
        }

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
        responderChainable?.controller?.present(vc, animated: true, completion: nil)
    }

    func updateRelationship(
        _ currentUserId: String,
        userId: String,
        prev prevPriority: RelationshipPriorityWrapper,
        relationshipPriority newRelationshipPriority: RelationshipPriorityWrapper,
        complete: @escaping RelationshipChangeCompletion)
    {
        var prevRelationshipPriority = prevPriority
        RelationshipService().updateRelationship(
            currentUserId: currentUserId,
            userId: userId,
            relationshipPriority: newRelationshipPriority.priority,
            success: { [weak self] (data, responseConfig) in
                guard let `self` = self else { return }
                if let relationship = data as? Relationship {
                    complete(RelationshipRequestStatusWrapper(status: .success), relationship, responseConfig.isFinalValue)

                    let responder = self.target(forAction: #selector(RelationshipControllerResponder.relationshipChanged(_:status:relationship:)), withSender: self) as? RelationshipControllerResponder
                    responder?.relationshipChanged(userId, status: RelationshipRequestStatusWrapper(status: .success), relationship: relationship)
                    if responseConfig.isFinalValue {
                        if let owner = relationship.owner {
                            postNotification(RelationshipChangedNotification, value: owner)
                        }
                        if let subject = relationship.subject {
                            postNotification(RelationshipChangedNotification, value: subject)
                        }
                    }
                }
                else {
                    complete(RelationshipRequestStatusWrapper(status: .success), nil, responseConfig.isFinalValue)
                    let responder = self.target(forAction: #selector(RelationshipControllerResponder.relationshipChanged(_:status:relationship:)), withSender: self) as? RelationshipControllerResponder
                    responder?.relationshipChanged(userId, status: RelationshipRequestStatusWrapper(status: .success), relationship: nil)

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

                    prevRelationshipPriority = newRelationshipPriority
                }
            },
            failure: { [weak self] (error, statusCode) in
                guard let `self` = self else { return }
                complete(RelationshipRequestStatusWrapper(status: .failure), nil, true)
                let responder = self.target(forAction: #selector(RelationshipControllerResponder.relationshipChanged(_:status:relationship:)), withSender: self) as? RelationshipControllerResponder
                responder?.relationshipChanged(userId, status: RelationshipRequestStatusWrapper(status: .failure), relationship: nil)
            })
    }
}
