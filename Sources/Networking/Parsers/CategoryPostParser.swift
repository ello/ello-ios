////
///  CategoryPostParser.swift
//

import SwiftyJSON


class CategoryPostParser: IdParser {

    init() {
        super.init(table: .categoryPostsType)
        linkObject(.categoriesType)
        linkObject(.usersType, "submittedBy")
        linkObject(.usersType, "featuredBy")
        linkObject(.usersType, "unfeaturedBy")
        linkObject(.usersType, "removedBy")
    }

    override func parse(json: JSON) -> CategoryPost {
        var actions: [CategoryPost.Action] = []
        if let actionsJson = json["actions"].dictionary {
            for (name, actionJson) in actionsJson {
                guard let action = CategoryPost.Action(name: name, json: actionJson) else { continue }
                actions.append(action)
            }
        }

        let submittedAt = json["submittedAt"].stringValue.toDate() ?? Globals.now
        let featuredAt = json["featuredAt"].stringValue.toDate() ?? Globals.now
        let unfeaturedAt = json["unfeaturedAt"].stringValue.toDate() ?? Globals.now
        let removedAt = json["removedAt"].stringValue.toDate() ?? Globals.now

        let categoryPost = CategoryPost(
            id: json["id"].stringValue,
            status: CategoryPost.Status(rawValue: json["status"].stringValue) ?? .unspecified,
            actions: actions,
            submittedAt: submittedAt,
            featuredAt: featuredAt,
            unfeaturedAt: unfeaturedAt,
            removedAt: removedAt
        )

        categoryPost.mergeLinks(json["links"].dictionaryObject)

        return categoryPost
    }
}
