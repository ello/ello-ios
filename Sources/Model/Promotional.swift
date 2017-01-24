////
///  Promotional.swift
//

import SwiftyJSON

let PromotionalVersion = 1

final class Promotional: JSONAble {

    let id: String
    let userId: String
    let categoryId: String
    var image: Asset?

    // links
    var user: User? { return getLinkObject("user") as? User }

    init(
        id: String,
        userId: String,
        categoryId: String
    ) {
        self.id = id
        self.userId = userId
        self.categoryId = categoryId
        super.init(version: PromotionalVersion)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        id = decoder.decodeKey("id")
        userId = decoder.decodeKey("userId")
        categoryId = decoder.decodeKey("categoryId")
        image = decoder.decodeOptionalKey("image")
        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        let encoder = Coder(coder)
        encoder.encodeObject(id, forKey: "id")
        encoder.encodeObject(userId, forKey: "userId")
        encoder.encodeObject(categoryId, forKey: "categoryId")
        encoder.encodeObject(image, forKey: "image")
        super.encode(with: coder)
    }

    override class func fromJSON(_ data: [String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        let id = json["id"].stringValue
        let userId = json["user_id"].stringValue
        let categoryId = json["category_id"].stringValue

        let image = Asset.parseAsset(id, node: data["image"] as? [String: AnyObject])

        let promotional = Promotional(id: id, userId: userId, categoryId: categoryId)
        promotional.image = image

        // links
        promotional.links = data["links"] as? [String: AnyObject]

        return promotional
    }
}

extension Promotional: JSONSaveable {
    var uniqueId: String? { if let id = tableId { return "Promotional-\(id)" } ; return nil }
    var tableId: String? { return id }

}
