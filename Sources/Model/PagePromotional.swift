////
///  PagePromotional.swift
//

import SwiftyJSON


let PagePromotionalVersion = 1

final class PagePromotional: JSONAble {

    let id: String
    let header: String
    let subheader: String
    let ctaCaption: String
    let ctaURL: URL?
    let image: Asset?
    var tileURL: URL? { return image?.oneColumnAttachment?.url as URL? }

    // links
    var user: User? { return getLinkObject("user") as? User }

    init(
        id: String,
        header: String,
        subheader: String,
        ctaCaption: String,
        ctaURL: URL?,
        image: Asset?
    ) {
        self.id = id
        self.header = header
        self.subheader = subheader
        self.ctaCaption = ctaCaption
        self.ctaURL = ctaURL
        self.image = image
        super.init(version: PagePromotionalVersion)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        id = decoder.decodeKey("id")
        header = decoder.decodeKey("header")
        subheader = decoder.decodeKey("subheader")
        ctaCaption = decoder.decodeKey("ctaCaption")
        ctaURL = decoder.decodeOptionalKey("ctaURL")
        image = decoder.decodeOptionalKey("image")
        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        let encoder = Coder(coder)
        encoder.encodeObject(id, forKey: "id")
        encoder.encodeObject(header, forKey: "header")
        encoder.encodeObject(subheader, forKey: "subheader")
        encoder.encodeObject(ctaCaption, forKey: "ctaCaption")
        encoder.encodeObject(ctaURL, forKey: "ctaURL")
        encoder.encodeObject(image, forKey: "image")
        super.encode(with: coder)
    }

    override class func fromJSON(_ data: [String: Any]) -> JSONAble {
        let json = JSON(data)
        let id = json["id"].stringValue
        let header = json["header"].stringValue
        let subheader = json["subheader"].stringValue
        let ctaCaption = json["cta_caption"].stringValue
        let ctaURL = json["cta_href"].string.flatMap { URL(string: $0) }

        let image = Asset.parseAsset(id, node: data["image"] as? [String: Any])

        let promotional = PagePromotional(
            id: id,
            header: header,
            subheader: subheader,
            ctaCaption: ctaCaption,
            ctaURL: ctaURL,
            image: image
            )
        promotional.links = data["links"] as? [String: Any]
        return promotional
    }
}

extension PagePromotional: JSONSaveable {
    var uniqueId: String? { return "PagePromotional-\(id)" }
    var tableId: String? { return id }

}
