////
///  RegionParser.swift
//

import SwiftyJSON

struct RegionParser {

    static func jsonRegions(json: JSON, isRepostContent: Bool = false) -> [Regionable] {
        guard let content = json.object as? [[String: Any]] else { return [] }

        return content.flatMap { contentDict -> Regionable? in
            guard
                let kindStr = contentDict["kind"] as? String,
                let kind = RegionKind(rawValue: kindStr)
            else { return nil }

            let regionable: Regionable
            switch kind {
            case .text:
                regionable = TextRegion.fromJSON(contentDict)
            case .image:
                regionable = ImageRegion.fromJSON(contentDict)
            case .embed:
                regionable = EmbedRegion.fromJSON(contentDict)
            default:
                return nil
            }

            regionable.isRepost = isRepostContent
            return regionable
        }
    }

    static func graphQLRegions(json: JSON, isRepostContent: Bool = false) -> [Regionable] {
        guard let regions = json.array else { return [] }
        return regions.flatMap { regionJSON -> [Regionable] in
            guard
                let kindStr = regionJSON["kind"].string,
                let kind = RegionKind(rawValue: kindStr)
            else { return [] }

            let regionable: Regionable

            switch kind {
            case .text:
                regionable = parseTextRegion(json: regionJSON)
            case .image:
                regionable = parseImageRegion(json: regionJSON)
            case .embed:
                regionable = parseEmbedRegion(json: regionJSON)
            default:
                return []
            }

            regionable.isRepost = isRepostContent
            return [regionable]
        }
    }

    static private func parseTextRegion(json: JSON) -> TextRegion {
        return TextRegion(content: json["data"].stringValue)
    }

    static private func parseImageRegion(json: JSON) -> ImageRegion {
        let url: URL? = json["data"]["url"].string.flatMap { URL(string: $0) }
        let imageRegion = ImageRegion(url: url)

        if let urlStr = json["linkUrl"].string {
            imageRegion.buyButtonURL = URL(string: urlStr)
        }
        imageRegion.links = json["links"].dictionaryObject
        return imageRegion
    }

    static private func parseEmbedRegion(json: JSON) -> EmbedRegion {
        let thumbnailLargeUrl = json["data"]["thumbnailLargeUrl"].string.flatMap { URL(string: $0) }

        // create region
        let embedRegion = EmbedRegion(
            id: json["data"]["id"].stringValue,
            service: EmbedType(rawValue: json["data"]["service"].stringValue) ?? .unknown,
            url: URL(string: json["data"]["url"].stringValue) ?? URL(string: "https://ello.co/404")!,
            thumbnailLargeUrl: thumbnailLargeUrl
        )
        return embedRegion
    }

}
