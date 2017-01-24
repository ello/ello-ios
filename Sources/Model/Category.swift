////
///  Category.swift
//

import SwiftyJSON

let CategoryVersion = 3

// Version 3: isSponsored, body, header, ctaCaption, ctaURL, promotionals

final class Category: JSONAble, Groupable {
    static let featured = Category(id: "meta1", name: InterfaceString.Discover.Featured, slug: "recommended", order: 0, allowInOnboarding: false, usesPagePromo: true, level: .meta, tileImage: nil)
    static let trending = Category(id: "meta2", name: InterfaceString.Discover.Trending, slug: "trending", order: 1, allowInOnboarding: false, usesPagePromo: true, level: .meta, tileImage: nil)
    static let recent = Category(id: "meta3", name: InterfaceString.Discover.Recent, slug: "recent", order: 2, allowInOnboarding: false, usesPagePromo: true, level: .meta, tileImage: nil)

    let id: String
    var groupId: String { return "Category-\(id)" }
    let name: String
    let slug: String
    var tileURL: URL? { return tileImage?.url as URL? }
    var isSponsored: Bool?
    var body: String?
    var header: String?
    var ctaCaption: String?
    var ctaURL: URL?
    let tileImage: Attachment?
    let order: Int
    let allowInOnboarding: Bool
    let level: CategoryLevel
    var isMeta: Bool { return level == .meta }
    var usesPagePromo: Bool
    var hasPromotionalData: Bool {
        return body != nil
    }

    var endpoint: ElloAPI {
        switch level {
        case .meta: return .discover(type: DiscoverType(rawValue: slug)!)
        default: return .categoryPosts(slug: slug)
        }
    }

    // links
    var promotionals: [Promotional]? { return getLinkArray("promotionals") as? [Promotional] }
    fileprivate var _randomPromotional: Promotional?
    var randomPromotional: Promotional? {
        get {
            if _randomPromotional == nil {
                _randomPromotional = promotionals?.randomItem()
            }
            return _randomPromotional
        }
        set {
            _randomPromotional = newValue
        }
    }

    var visibleOnSeeMore: Bool {
        return level == .primary || level == .secondary
    }

    init(id: String,
        name: String,
        slug: String,
        order: Int,
        allowInOnboarding: Bool,
        usesPagePromo: Bool,
        level: CategoryLevel,
        tileImage: Attachment?)
    {
        self.id = id
        self.name = name
        self.slug = slug
        self.order = order
        self.allowInOnboarding = allowInOnboarding
        self.usesPagePromo = usesPagePromo
        self.level = level
        self.tileImage = tileImage
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
        if version > 2 {
            usesPagePromo = decoder.decodeKey("usesPagePromo")
        }
        else {
            usesPagePromo = level == .meta
        }
        tileImage = decoder.decodeOptionalKey("tileImage")
        isSponsored = decoder.decodeOptionalKey("isSponsored")
        body = decoder.decodeOptionalKey("body")
        header = decoder.decodeOptionalKey("header")
        ctaCaption = decoder.decodeOptionalKey("ctaCaption")
        ctaURL = decoder.decodeOptionalKey("ctaURL")
        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        let encoder = Coder(coder)
        encoder.encodeObject(id, forKey: "id")
        encoder.encodeObject(name, forKey: "name")
        encoder.encodeObject(slug, forKey: "slug")
        encoder.encodeObject(order, forKey: "order")
        encoder.encodeObject(allowInOnboarding, forKey: "allowInOnboarding")
        encoder.encodeObject(usesPagePromo, forKey: "usesPagePromo")
        encoder.encodeObject(level.rawValue, forKey: "level")
        encoder.encodeObject(tileImage, forKey: "tileImage")
        encoder.encodeObject(isSponsored, forKey: "isSponsored")
        encoder.encodeObject(body, forKey: "body")
        encoder.encodeObject(header, forKey: "header")
        encoder.encodeObject(ctaCaption, forKey: "ctaCaption")
        encoder.encodeObject(ctaURL, forKey: "ctaURL")
        super.encode(with: coder)
    }

    override func merge(_ other: JSONAble) -> JSONAble {
        if let other = other as? Category {
            if other.links?["promotionals"] == nil, let promotionals = promotionals, promotionals.count > 0 {
                other.addLinkArray("promotionals", array: promotionals.map { $0.id }, type: .promotionalsType)
            }
        }
        return other
    }

    override class func fromJSON(_ data: [String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        let id = json["id"].stringValue
        let name = json["name"].stringValue
        let slug = json["slug"].stringValue
        let order = json["order"].intValue
        let allowInOnboarding = json["allow_in_onboarding"].bool ?? true
        let level: CategoryLevel = CategoryLevel(rawValue: json["level"].stringValue) ?? .unknown
        let usesPagePromo = json["uses_page_promotionals"].bool ?? (level == .meta)
        let tileImage: Attachment?
        if let assetJson = json["tile_image"].object as? [String: AnyObject],
            let attachmentJson = assetJson["large"] as? [String: AnyObject]
        {
            tileImage = Attachment.fromJSON(attachmentJson) as? Attachment
        }
        else {
            tileImage = nil
        }

        // optional
        let isSponsored = json["is_sponsored"].bool
        let body = json["description"].string
        let header = json["header"].string
        let ctaCaption = json["cta_caption"].string
        let ctaURL = json["cta_href"].string.flatMap { URL(string: $0) }

        let category = Category(id: id, name: name, slug: slug, order: order, allowInOnboarding: allowInOnboarding, usesPagePromo: usesPagePromo, level: level, tileImage: tileImage)

        // links
        category.links = data["links"] as? [String: AnyObject]
        category.isSponsored = isSponsored
        category.body = body
        category.header = header
        category.ctaCaption = ctaCaption
        category.ctaURL = ctaURL

        return category
    }
}

extension Category: JSONSaveable {
    var uniqueId: String? { if let id = tableId { return "Category-\(id)" } ; return nil }
    var tableId: String? { return id }
}
