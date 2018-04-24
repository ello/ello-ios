////
///  CategoryPost.swift
//

import SwiftyJSON



@objc(CategoryPost)
final class CategoryPost: Model, Groupable {
    static let CategoryPostVersion = 1

    let id: String
    var groupId: String { return "CategoryPost-\(id)" }
    var category: Category? { return getLinkObject("category") }
    var featuredBy: User? { return getLinkObject("featuredBy") }

    init(id: String)
    {
        self.id = id
        super.init(version: CategoryPost.CategoryPostVersion)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        id = decoder.decodeKey("id")
        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        let encoder = Coder(coder)
        encoder.encodeObject(id, forKey: "id")
        super.encode(with: coder)
    }

    class func fromJSON(_ data: [String: Any]) -> CategoryPost {
        let json = JSON(data)

        let categoryPost = CategoryPost(
            id: json["id"].stringValue
            )

        categoryPost.mergeLinks(data["links"] as? [String: Any])

        return categoryPost
    }
}

extension CategoryPost: JSONSaveable {
    var uniqueId: String? { return "CategoryPost-\(id)" }
    var tableId: String? { return id }
}
