////
///  Relationship.swift
//

import SwiftyJSON


@objc(Relationship)
final class Relationship: Model {
    static let Version = 1

    let id: String

    var owner: User? { return getLinkObject("owner") }
    var subject: User? { return getLinkObject("subject") }

    convenience init(ownerId: String, subjectId: String) {
        self.init(id: UUID().uuidString)
        addLinkObject("owner", id: ownerId, type: .usersType)
        addLinkObject("subject", id: subjectId, type: .usersType)
    }

    init(id: String) {
        self.id = id
        super.init(version: Relationship.Version)

    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        self.id = decoder.decodeKey("id")
        super.init(coder: coder)
    }

    override func encode(with encoder: NSCoder) {
        let coder = Coder(encoder)
        coder.encodeObject(id, forKey: "id")
        super.encode(with: coder.coder)
    }

    class func fromJSON(_ data: [String: Any]) -> Relationship {
        let json = JSON(data)

        let relationship = Relationship(id: json["id"].idValue)

        relationship.mergeLinks(json["links"].dictionaryObject)

        return relationship
    }
}

extension Relationship: JSONSaveable {
    var uniqueId: String? { return "Relationship-\(id)" }
    var tableId: String? { return id }
}
