////
///  PageHeader.swift
//

import SwiftyJSON


@objc(PageHeader)
final class PageHeader: Model {
    // version 1: initial
    static let Version = 1

    enum Kind: String {
        case artistInvite = "ARTIST_INVITE"
        case category = "CATEGORY"
        case editorial = "EDITORIAL"
        case generic = "GENERIC"

        var hasHtml: Bool {
            switch self {
            case .editorial, .artistInvite: return true
            case .category, .generic: return false
            }
        }
    }

    let id: String
    let postToken: String?
    let categoryId: String?
    let header: String
    let subheader: String
    let ctaCaption: String
    let ctaURL: URL?
    var isSponsored: Bool
    let image: Asset?
    var tileURL: URL? { return image?.oneColumnAttachment?.url }
    var kind: Kind

    var user: User? { return getLinkObject("user") }

    init(
        id: String,
        postToken: String?,
        categoryId: String?,
        header: String,
        subheader: String,
        ctaCaption: String,
        ctaURL: URL?,
        isSponsored: Bool,
        image: Asset?,
        kind: Kind
    ) {
        self.id = id
        self.postToken = postToken
        self.categoryId = categoryId
        self.header = header
        self.subheader = subheader
        self.ctaCaption = ctaCaption
        self.ctaURL = ctaURL
        self.isSponsored = isSponsored
        self.image = image
        self.kind = kind
        super.init(version: PageHeader.Version)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        id = decoder.decodeKey("id")
        postToken = decoder.decodeOptionalKey("postToken")
        categoryId = decoder.decodeOptionalKey("categoryId")
        header = decoder.decodeKey("header")
        subheader = decoder.decodeKey("subheader")
        ctaCaption = decoder.decodeKey("ctaCaption")
        ctaURL = decoder.decodeOptionalKey("ctaURL")
        isSponsored = decoder.decodeKey("isSponsored")
        image = decoder.decodeOptionalKey("image")
        let kindString: String = decoder.decodeKey("kind")
        kind = Kind(rawValue: kindString) ?? .generic
        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        let encoder = Coder(coder)
        encoder.encodeObject(id, forKey: "id")
        encoder.encodeObject(postToken, forKey: "postToken")
        encoder.encodeObject(categoryId, forKey: "categoryId")
        encoder.encodeObject(header, forKey: "header")
        encoder.encodeObject(subheader, forKey: "subheader")
        encoder.encodeObject(ctaCaption, forKey: "ctaCaption")
        encoder.encodeObject(ctaURL, forKey: "ctaURL")
        encoder.encodeObject(isSponsored, forKey: "isSponsored")
        encoder.encodeObject(image, forKey: "image")
        encoder.encodeObject(kind.rawValue, forKey: "kind")
        super.encode(with: coder)
    }
}

extension PageHeader: JSONSaveable {
    var uniqueId: String? { return "PageHeader-\(id)" }
    var tableId: String? { return id }
}
