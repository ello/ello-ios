////
///  AssetParser.swift
//

import SwiftyJSON


class AssetParser: IdParser {

    init() {
        super.init(table: .assetsType)
    }

    override func parse(json: JSON) -> Asset {
        return Asset.parseAsset(json["id"].stringValue, node: json["attachment"].dictionaryObject)
    }
}
