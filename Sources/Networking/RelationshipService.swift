////
///  RelationshipService.swift
//

import Moya
import SwiftyJSON

class RelationshipService: NSObject {

    func updateRelationship(
        currentUserId: String,
        userId: String,
        relationshipPriority: RelationshipPriority,
        success: @escaping ElloSuccessCompletion,
        failure: @escaping ElloFailureCompletion)
    {

        // optimistic success
        let optimisticRelationship =
            Relationship(
                id: Tmp.uniqueName(),
                createdAt: Date(),
                ownerId: currentUserId,
                subjectId: userId
            )

        if let subject = optimisticRelationship.subject {
            subject.relationshipPriority = relationshipPriority
            ElloLinkedStore.sharedInstance.setObject(subject, forKey: subject.id, type: .usersType)
            success(optimisticRelationship, ResponseConfig(isFinalValue: false))
        }

        let endpoint = ElloAPI.relationship(userId: userId, relationship: relationshipPriority.rawValue)
        ElloProvider.shared.elloRequest(endpoint, success: { (data, responseConfig) in
            Tracker.shared.relationshipStatusUpdated(relationshipPriority, userId: userId)
            success(data, responseConfig)
        }, failure: { (error, statusCode) in
            Tracker.shared.relationshipStatusUpdateFailed(relationshipPriority, userId: userId)
            failure(error, statusCode)
        })
    }

    func bulkUpdateRelationships(userIds: [String], relationshipPriority: RelationshipPriority, success: @escaping ElloSuccessCompletion, failure: @escaping ElloFailureCompletion) {
        let endpoint = ElloAPI.relationshipBatch(userIds: userIds, relationship: relationshipPriority.rawValue)
        ElloProvider.shared.elloRequest(endpoint,
            success: success,
            failure: failure
        )
    }
}
