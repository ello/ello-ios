////
///  Category.swift
//

import SwiftyJSON

// Version 2: allowInOnboarding
// Version 3: usesPagePromo (removed)
// Version 4: isCreatorType
let CategoryVersion = 4


@objc(Category)
final class Category: Model {
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
    let name: String
    let slug: String
    let categoryDescription: String?
    let order: Int
    let allowInOnboarding: Bool
    let isCreatorType: Bool
    let level: CategoryLevel
    var tileImage: Attachment?

    var isMeta: Bool { return level == .meta }
    var tileURL: URL? { return tileImage?.url }

    var visibleOnSeeMore: Bool {
        return level == .primary || level == .secondary
    }

    init(
        id: String,
        name: String,
        slug: String,
        description: String?,
        order: Int,
        allowInOnboarding: Bool,
        isCreatorType: Bool,
        level: CategoryLevel,
        tileImage: Attachment?
    ) {
        self.id = id
        self.name = name
        self.slug = slug
        self.categoryDescription = description
        self.order = order
        self.allowInOnboarding = allowInOnboarding
        self.isCreatorType = isCreatorType
        self.level = level
        self.tileImage = tileImage
        super.init(version: CategoryVersion)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        id = decoder.decodeKey("id")
        name = decoder.decodeKey("name")
        slug = decoder.decodeKey("slug")
        categoryDescription = decoder.decodeOptionalKey("description")
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

    override func merge(_ other: Model) -> Model {
        if let otherCategory = other as? Category {
            otherCategory.tileImage = otherCategory.tileImage ?? tileImage
        }
        return super.merge(other)
    }

    override func encode(with coder: NSCoder) {
        let encoder = Coder(coder)
        encoder.encodeObject(id, forKey: "id")
        encoder.encodeObject(name, forKey: "name")
        encoder.encodeObject(slug, forKey: "slug")
        encoder.encodeObject(categoryDescription, forKey: "description")
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
        let tileImage = (json["tile_image"]["large"].object as? [String: Any]).map {
            Attachment.fromJSON($0)
        }

        let category = Category(
            id: json["id"].idValue,
            name: json["name"].stringValue,
            slug: json["slug"].stringValue,
            description: json["description"].string,
            order: json["order"].intValue,
            allowInOnboarding: json["allow_in_onboarding"].bool ?? true,
            isCreatorType: json["is_creator_type"].bool ?? true,
            level: level,
            tileImage: tileImage
        )

        category.mergeLinks(data["links"] as? [String: Any])

        return category
    }
}

extension Category: JSONSaveable {
    var uniqueId: String? { return "Category-\(id)" }
    var tableId: String? { return id }
}
