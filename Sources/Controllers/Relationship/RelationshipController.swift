////
///  RelationshipController.swift
//

typealias RelationshipChangeClosure = (_ relationshipPriority: RelationshipPriority) -> Void
typealias RelationshipChangeCompletion = (_ status: RelationshipRequestStatus, _ relationship: Relationship?, _ isFinalValue: Bool) -> Void

enum RelationshipRequestStatus: String {
    case success = "success"
    case failure = "failure"
}

protocol RelationshipControllerDelegate: class {
    func shouldSubmitRelationship(_ userId: String, relationshipPriority: RelationshipPriority) -> Bool
    func relationshipChanged(_ userId: String, status: RelationshipRequestStatus, relationship: Relationship?)
}

protocol RelationshipDelegate: class {
    func relationshipTapped(_ userId: String, prev prevRelationshipPriority: RelationshipPriority, relationshipPriority: RelationshipPriority, complete: @escaping RelationshipChangeCompletion)
    func launchBlockModal(_ userId: String, userAtName: String, relationshipPriority: RelationshipPriority, changeClosure: @escaping RelationshipChangeClosure)
    func updateRelationship(_ currentUserId: String, userId: String, prev prevRelationshipPriority: RelationshipPriority, relationshipPriority: RelationshipPriority, complete: @escaping RelationshipChangeCompletion)
}

class RelationshipController {
    var currentUser: User?
    weak var delegate: RelationshipControllerDelegate?
    weak var presentingController: UIViewController?

    required init(presentingController: UIViewController) {
        self.presentingController = presentingController
    }

}

// MARK: RelationshipController: RelationshipDelegate
extension RelationshipController: RelationshipDelegate {
    func relationshipTapped(_ userId: String, prev prevRelationshipPriority: RelationshipPriority, relationshipPriority: RelationshipPriority, complete: @escaping RelationshipChangeCompletion) {
        Tracker.shared.relationshipButtonTapped(relationshipPriority, userId: userId)
        if let shouldSubmit = delegate?.shouldSubmitRelationship(userId, relationshipPriority: relationshipPriority), !shouldSubmit {
            let relationship = Relationship(id: UUID().uuidString, createdAt: Date(), ownerId: "", subjectId: userId)
            complete(.success, relationship, true)
            return
        }

        if let currentUserId = currentUser?.id {
            self.updateRelationship(currentUserId, userId: userId, prev: prevRelationshipPriority, relationshipPriority: relationshipPriority, complete: complete)
        }
    }

    func launchBlockModal(_ userId: String, userAtName: String, relationshipPriority: RelationshipPriority, changeClosure: @escaping RelationshipChangeClosure) {
        let vc = BlockUserModalViewController(config: BlockUserModalConfig(userId: userId, userAtName: userAtName, relationshipPriority: relationshipPriority, changeClosure: changeClosure))
        vc.currentUser = currentUser
        vc.relationshipDelegate = self
        presentingController?.present(vc, animated: true, completion: nil)
    }

    func updateRelationship(_ currentUserId: String, userId: String, prev prevPriority: RelationshipPriority, relationshipPriority newRelationshipPriority: RelationshipPriority, complete: @escaping RelationshipChangeCompletion) {
        var prevRelationshipPriority = prevPriority
        RelationshipService().updateRelationship(currentUserId: currentUserId, userId: userId, relationshipPriority: newRelationshipPriority,
            success: { (data, responseConfig) in
                if let relationship = data as? Relationship {
                    complete(.success, relationship, responseConfig.isFinalValue)

                    self.delegate?.relationshipChanged(userId, status: .success, relationship: relationship)
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
                    complete(.success, nil, responseConfig.isFinalValue)

                    self.delegate?.relationshipChanged(userId, status: .success, relationship: nil)
                }

                if prevRelationshipPriority != newRelationshipPriority {
                    var blockDelta = 0
                    if prevRelationshipPriority == .block { blockDelta -= 1 }
                    if newRelationshipPriority == .block { blockDelta += 1 }
                    if blockDelta != 0 {
                        postNotification(BlockedCountChangedNotification, value: (userId, blockDelta))
                    }

                    var mutedDelta = 0
                    if prevRelationshipPriority == .mute { mutedDelta -= 1 }
                    if newRelationshipPriority == .mute { mutedDelta += 1 }
                    if mutedDelta != 0 {
                        postNotification(MutedCountChangedNotification, value: (userId, mutedDelta))
                    }

                    prevRelationshipPriority = newRelationshipPriority
                }
            },
            failure: { (error, statusCode) in
                complete(.failure, nil, true)

                self.delegate?.relationshipChanged(userId, status: .failure, relationship: nil)
            })
    }
}
