////
///  RelationshipService.swift
//

import Moya
import SwiftyJSON
import PromiseKit


class RelationshipService: NSObject {

    func updateRelationship(
        currentUserId: String,
        userId: String,
        relationshipPriority: RelationshipPriority
        ) -> (Relationship?, Promise<Relationship?>)
    {
        // optimistic success
        let optimisticRelationship =
            Relationship(
                id: Tmp.uniqueName(),
                createdAt: Date(),
                ownerId: currentUserId,
                subjectId: userId
            )
        var returnedRelationship: Relationship?

        if let subject = optimisticRelationship.subject {
            subject.relationshipPriority = relationshipPriority
            ElloLinkedStore.sharedInstance.setObject(subject, forKey: subject.id, type: .usersType)
            returnedRelationship = optimisticRelationship
        }

        let endpoint: ElloAPI = .relationship(userId: userId, relationship: relationshipPriority.rawValue)
        return (
            returnedRelationship,
            ElloProvider.shared.request(endpoint)
                .then { response -> Relationship? in
                    Tracker.shared.relationshipStatusUpdated(relationshipPriority, userId: userId)
                    return response.0 as? Relationship
                }
                .catch { (error) in
                    Tracker.shared.relationshipStatusUpdateFailed(relationshipPriority, userId: userId)
                }
            )
    }
}
