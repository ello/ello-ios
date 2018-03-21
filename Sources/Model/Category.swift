////
///  Category.swift
//

import SwiftyJSON

// Version 2: allowInOnboarding
// Version 3: usesPagePromo (removed)
// Version 4: isCreatorType
let CategoryVersion = 4


@objc(Category)
final class Category: JSONAble, Groupable {
    enum Selection {
        case all
        case subscribed
        case category(String)

        var shareLink: URL? {
            switch self {
            case .all: return URL(string: "\(ElloURI.baseURL)/discover")
            case .subscribed: return URL(string: "\(ElloURI.baseURL)/discover/subscribed")
            case let .category(slug): return URL(string: "\(ElloURI.baseURL)/discover/\(slug)")
            }
        }
    }

    let id: String
    var groupId: String { return "Category-\(id)" }
    let name: String
    let slug: String
    let order: Int
    let allowInOnboarding: Bool
    let isCreatorType: Bool
    let level: CategoryLevel
    var isMeta: Bool { return level == .meta }
    var tileURL: URL? { return tileImage?.url }
    var tileImage: Attachment?

    var visibleOnSeeMore: Bool {
        return level == .primary || level == .secondary
    }

    init(id: String,
        name: String,
        slug: String,
        order: Int,
        allowInOnboarding: Bool,
        isCreatorType: Bool,
        level: CategoryLevel)
    {
        self.id = id
        self.name = name
        self.slug = slug
        self.order = order
        self.allowInOnboarding = allowInOnboarding
        self.isCreatorType = isCreatorType
        self.level = level
        super.init(version: CategoryVersion)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        id = decoder.decodeKey("id")
        name = decoder.decodeKey("name")
        slug = decoder.decodeKey("slug")
        order = decoder.decodeKey("order")
        level = CategoryLevel(rawValue: decoder.decodeKey("level"))!
        let version: Int = decoder.decodeKey("version")
        if version > 1 {
            allowInOnboarding = decoder.decodeKey("allowInOnboarding")
        }
        else {
            allowInOnboarding = true
        }
        if version > 3 {
            isCreatorType = decoder.decodeKey("isCreatorType")
        }
        else {
            isCreatorType = false
        }
        tileImage = decoder.decodeOptionalKey("tileImage")
        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        let encoder = Coder(coder)
        encoder.encodeObject(id, forKey: "id")
        encoder.encodeObject(name, forKey: "name")
        encoder.encodeObject(slug, forKey: "slug")
        encoder.encodeObject(order, forKey: "order")
        encoder.encodeObject(allowInOnboarding, forKey: "allowInOnboarding")
        encoder.encodeObject(isCreatorType, forKey: "isCreatorType")
        encoder.encodeObject(level.rawValue, forKey: "level")
        encoder.encodeObject(tileImage, forKey: "tileImage")
        super.encode(with: coder)
    }

    class func fromJSON(_ data: [String: Any]) -> Category {
        let json = JSON(data)
        let level: CategoryLevel = CategoryLevel(rawValue: json["level"].stringValue) ?? .unknown

        let category = Category(
            id: json["id"].stringValue,
            name: json["name"].stringValue,
            slug: json["slug"].stringValue,
            order: json["order"].intValue,
            allowInOnboarding: json["allow_in_onboarding"].bool ?? true,
            isCreatorType: json["is_creator_type"].bool ?? true,
            level: level
            )

        category.links = data["links"] as? [String: Any]

        if let attachmentJson = json["tile_image"]["large"].object as? [String: Any] {
            category.tileImage = Attachment.fromJSON(attachmentJson)
        }

        return category
    }
}

extension Category: JSONSaveable {
    var uniqueId: String? { return "Category-\(id)" }
    var tableId: String? { return id }
}
