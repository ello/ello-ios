////
///  RegionParser.swift
//

import SwiftyJSON

struct RegionParser {

    static func regions(_ key: String, json: JSON, isRepostContent: Bool = false) -> [Regionable] {
        if let content = json[key].object as? [[String: AnyObject]] {
            return content.map { (contentDict) -> Regionable in
                let kind = RegionKind(rawValue: contentDict["kind"] as! String) ?? RegionKind.unknown
                let regionable: Regionable
                switch kind {
                case .text:
                    regionable = TextRegion.fromJSON(contentDict) as! TextRegion
                case .image:
                    regionable = ImageRegion.fromJSON(contentDict) as! ImageRegion
                case .embed:
                    regionable = EmbedRegion.fromJSON(contentDict) as! EmbedRegion
                default:
                    regionable = UnknownRegion(name: "Unknown")
                }
                regionable.isRepost = isRepostContent
                return regionable
            }
        }
        else {
            return []
        }
    }
}
