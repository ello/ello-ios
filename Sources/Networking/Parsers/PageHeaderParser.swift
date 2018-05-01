////
///  PageHeaderParser.swift
//

import SwiftyJSON


class PageHeaderParser: IdParser {

    init() {
        super.init(table: .pageHeadersType)
        linkObject(.usersType)
    }

    override func parse(json: JSON) -> PageHeader {
        let kind = PageHeader.Kind(rawValue: json["kind"].stringValue) ?? .generic
        let image = Asset.parseAsset("page_header_\(json["id"].stringValue)", node: json["image"].dictionaryObject)

        let header = PageHeader(
            id: json["id"].stringValue,
            postToken: json["postToken"].string,
            categoryId: json["category"]["id"].id,
            header: json["header"].stringValue,
            subheader: json["subheader"].stringValue,
            ctaCaption: json["ctaLink"]["text"].stringValue,
            ctaURL: json["ctaLink"]["url"].string.flatMap { URL(string: $0) },
            isSponsored: json["isSponsored"].boolValue,
            image: image,
            kind: kind
        )

        header.mergeLinks(json["links"].dictionaryObject)

        return header
    }
}
