////
///  CategoryPostParser.swift
//

import SwiftyJSON


class CategoryPostParser: IdParser {

    init() {
        super.init(table: .categoryPostsType)
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

        category.mergeLinks(json["links"].dictionaryObject)

        if let attachmentJson = json["tileImage"]["large"].object as? [String: Any] {
            category.tileImage = Attachment.fromJSON(attachmentJson)
        }

        return category
    }
}
