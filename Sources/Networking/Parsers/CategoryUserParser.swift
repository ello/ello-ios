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
            id: json["id"].stringValue,
            role: CategoryUser.Role(rawValue: json["role"].stringValue) ?? .unspecified
        )

        categoryUser.mergeLinks(json["links"].dictionaryObject)

        return categoryUser
    }
}
