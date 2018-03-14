////
///  CategoryParser.swift
//

import SwiftyJSON


class CategoryParser: IdParser {

    init() {
        super.init(table: .categoriesType)
    }

    override func parse(json: JSON) -> Category {
        let level: CategoryLevel = CategoryLevel(rawValue: json["level"].stringValue) ?? .unknown

        let category = Category(
            id: json["id"].stringValue,
            name: json["name"].stringValue,
            slug: json["slug"].stringValue,
            order: json["order"].intValue,
            allowInOnboarding: json["allowInOnboarding"].bool ?? true,
            isCreatorType: json["isCreatorType"].bool ?? true,
            level: level
        )

        category.links = json["links"].dictionaryObject

        if let attachmentJson = json["tileImage"]["large"].object as? [String: Any] {
            category.tileImage = Attachment.fromJSON(attachmentJson)
        }

        return category
    }
}
