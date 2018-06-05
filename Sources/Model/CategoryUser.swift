////
///  CategoryUser.swift
//

import SwiftyJSON
import Moya


@objc(CategoryUser)
final class CategoryUser: Model {
    static let Version = 1

    let id: String
    let role: Role

    var category: Category? { return getLinkObject("category") }
    var user: User? { return getLinkObject("user") }
    var featuredBy: User? { return getLinkObject("featured_by") }
    var curatorBy: User? { return getLinkObject("curator_by") }
    var moderatorBy: User? { return getLinkObject("moderator_by") }

    enum Role: String {
        case featured
        case curator
        case moderator
        case unspecified
    }

    init(id: String, role: Role)
    {
        self.id = id
        self.role = role
        super.init(version: CategoryUser.Version)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        id = decoder.decodeKey("id")
        role = Role(rawValue: decoder.decodeKey("role")) ?? .unspecified
        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        let encoder = Coder(coder)
        encoder.encodeObject(id, forKey: "id")
        encoder.encodeObject(role.rawValue, forKey: "role")
        super.encode(with: coder)
    }

    class func fromJSON(_ data: [String: Any]) -> CategoryUser {
        let json = JSON(data)

        let categoryUser = CategoryUser(
            id: json["id"].stringValue,
            role: CategoryUser.Role(rawValue: json["role"].stringValue) ?? .unspecified
        )

        categoryUser.mergeLinks(json["links"].dictionaryObject)

        return categoryUser
    }
}

extension CategoryUser: JSONSaveable {
    var uniqueId: String? { return "CategoryUser-\(id)" }
    var tableId: String? { return id }
}
