////
///  ImageRegion.swift
//

import SwiftyJSON


let ImageRegionVersion = 1

@objc(ImageRegion)
final class ImageRegion: Model, Regionable {
    let url: URL?
    let buyButtonURL: URL?
    var isRepost: Bool  = false
    let kind: RegionKind = .image

    var asset: Asset? { return getLinkObject("assets") }

    var fullScreenURL: URL? {
        guard let asset = asset else { return url }

        let assetURL: URL?
        if asset.isGif { assetURL = asset.optimized?.url }
        else { assetURL = asset.oneColumnAttachment?.url }

        return assetURL ?? url
    }

    init(url: URL?, buyButtonURL: URL?) {
        self.url = url
        self.buyButtonURL = buyButtonURL
        super.init(version: ImageRegionVersion)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        self.isRepost = decoder.decodeKey("isRepost")
        self.url = decoder.decodeOptionalKey("url")
        self.buyButtonURL = decoder.decodeOptionalKey("buyButtonURL")
        super.init(coder: coder)
    }

    override func encode(with encoder: NSCoder) {
        let coder = Coder(encoder)
        coder.encodeObject(isRepost, forKey: "isRepost")
        coder.encodeObject(url, forKey: "url")
        coder.encodeObject(buyButtonURL, forKey: "buyButtonURL")
        super.encode(with: coder.coder)
    }

    class func fromJSON(_ data: [String: Any]) -> ImageRegion {
        let json = JSON(data)

        var url: URL?
        if var urlStr = json["data"]["url"].string {
            if urlStr.hasPrefix("//") {
                urlStr = "https:\(urlStr)"
            }
            url = URL(string: urlStr)
        }

        let buyButtonURL = json["link_url"].url
        let imageRegion = ImageRegion(url: url, buyButtonURL: buyButtonURL)
        imageRegion.mergeLinks(data["links"] as? [String: Any])
        return imageRegion
    }

    func coding() -> NSCoding {
        return self
    }

    func toJSON() -> [String: Any] {
        var json: [String: Any] = [
            "kind": kind.rawValue,
        ]
        if let url = url?.absoluteString {
            json["data"] = [
                "url": url
            ]
        }

        if let buyButtonURL = buyButtonURL {
            json["link_url"] = buyButtonURL.absoluteString
        }

        return json
    }
}
