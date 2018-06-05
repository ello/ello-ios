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
        let tileImage = (json["tileImage"]["large"].object as? [String: Any]).map { Attachment.fromJSON($0) }

        let category = Category(
            id: json["id"].stringValue,
            name: json["name"].stringValue,
            slug: json["slug"].stringValue,
            description: json["description"].string,
            order: json["order"].intValue,
            allowInOnboarding: json["allowInOnboarding"].bool ?? true,
            isCreatorType: json["isCreatorType"].bool ?? true,
            level: level,
            tileImage: tileImage
            )

        category.mergeLinks(json["links"].dictionaryObject)

        return category
    }
}
