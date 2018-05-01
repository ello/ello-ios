////
///  TextRegion.swift
//

import SwiftyJSON


let TextRegionVersion = 1

@objc(TextRegion)
final class TextRegion: Model, Regionable {
    let content: String
    var isRepost: Bool = false
    let kind: RegionKind = .text

    init(content: String) {
        self.content = content
        super.init(version: TextRegionVersion)
    }

    override func encode(with encoder: NSCoder) {
        let coder = Coder(encoder)
        coder.encodeObject(content, forKey: "content")
        coder.encodeObject(isRepost, forKey: "isRepost")
        super.encode(with: coder.coder)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        self.content = decoder.decodeKey("content")
        self.isRepost = decoder.decodeKey("isRepost")
        super.init(coder: coder)
    }

    class func fromJSON(_ data: [String: Any]) -> TextRegion {
        let json = JSON(data)
        let content = json["data"].stringValue
        return TextRegion(content: content)
    }

    func coding() -> NSCoding {
        return self
    }

    func toJSON() -> [String: Any] {
        return [
            "kind": kind.rawValue,
            "data": content
        ]
    }
}

extension TextRegion {
    override var description: String {
        return "<\(type(of: self)): \"\(content)\">"
    }

    override var debugDescription: String { return description }
}
