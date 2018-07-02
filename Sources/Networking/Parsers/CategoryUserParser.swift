////
///  CategoryUserParser.swift
//

import SwiftyJSON


class CategoryUserParser: IdParser {

    init() {
        super.init(table: .categoryUsersType)
        linkObject(.categoriesType)
        linkObject(.usersType)
        linkObject(.usersType, "featuredBy")
        linkObject(.usersType, "curatorBy")
        linkObject(.usersType, "moderatorBy")
    }

    override func parse(json: JSON) -> CategoryUser {
        let categoryUser = CategoryUser(
            id: json["id"].idValue,
            role: CategoryUser.Role(rawValue: json["role"].stringValue.lowercased()) ?? .unspecified
        )

        categoryUser.mergeLinks(json["links"].dictionaryObject)

        return categoryUser
    }
}
