////
///  BlockUserModalConfig.swift
//

struct BlockUserModalConfig {
    let userId: String
    let userAtName: String
    let relationshipPriority: RelationshipPriority
    let changeClosure: RelationshipChangeClosure

    init(userId: String, userAtName: String, relationshipPriority: RelationshipPriority, changeClosure: @escaping RelationshipChangeClosure) {
        self.userId = userId
        self.userAtName = userAtName
        self.relationshipPriority = relationshipPriority
        self.changeClosure = changeClosure
    }

}
