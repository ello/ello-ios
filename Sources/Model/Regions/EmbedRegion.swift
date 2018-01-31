////
///  EmbedRegion.swift
//

import SwiftyJSON


let EmbedRegionVersion = 1

enum EmbedType: String {
    case codepen = "codepen"
    case dailymotion = "dailymotion"
    case mixcloud = "mixcloud"
    case soundcloud = "soundcloud"
    case youtube = "youtube"
    case vimeo = "vimeo"
    case uStream = "ustream"
    case bandcamp = "bandcamp"
    case unknown = "unknown"
}

@objc(EmbedRegion)
final class EmbedRegion: JSONAble, Regionable {
    var isRepost: Bool = false

    let id: String
    let service: EmbedType
    let url: URL
    let thumbnailLargeUrl: URL?
    var isAudioEmbed: Bool {
        return service == EmbedType.mixcloud || service == EmbedType.soundcloud || service == EmbedType.bandcamp
    }

    // MARK: Initialization

    init(
        id: String,
        service: EmbedType,
        url: URL,
        thumbnailLargeUrl: URL?
        )
    {
        self.id = id
        self.service = service
        self.url = url
        self.thumbnailLargeUrl = thumbnailLargeUrl
        super.init(version: EmbedRegionVersion)
    }

    // MARK: NSCoding

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        self.id = decoder.decodeKey("id")
        self.isRepost = decoder.decodeKey("isRepost")
        let serviceRaw: String = decoder.decodeKey("serviceRaw")
        self.service = EmbedType(rawValue: serviceRaw) ?? EmbedType.unknown
        self.url = decoder.decodeKey("url")
        self.thumbnailLargeUrl = decoder.decodeOptionalKey("thumbnailLargeUrl")
        super.init(coder: coder)
    }

    override func encode(with encoder: NSCoder) {
        let coder = Coder(encoder)
        coder.encodeObject(id, forKey: "id")
        coder.encodeObject(isRepost, forKey: "isRepost")
        coder.encodeObject(service.rawValue, forKey: "serviceRaw")
        coder.encodeObject(url, forKey: "url")
        coder.encodeObject(thumbnailLargeUrl, forKey: "thumbnailLargeUrl")
        super.encode(with: coder.coder)
    }

    // MARK: JSONAble

    class func fromJSON(_ data: [String: Any]) -> EmbedRegion {
        let json = JSON(data)
        let thumbnailLargeUrl = json["data"]["thumbnail_large_url"].string.flatMap { URL(string: $0) }

        // create region
        let embedRegion = EmbedRegion(
            id: json["data"]["id"].stringValue,
            service: EmbedType(rawValue: json["data"]["service"].stringValue) ?? .unknown,
            url: URL(string: json["data"]["url"].stringValue) ?? URL(string: "https://ello.co/404")!,
            thumbnailLargeUrl: thumbnailLargeUrl
        )
        return embedRegion
    }

// MARK: Regionable

    let kind: RegionKind = .embed

    func coding() -> NSCoding {
        return self
    }

    func toJSON() -> [String: Any] {
        return [
            "kind": kind.rawValue,
            "data": [
                "url": url.absoluteString,
            ],
        ]
    }
}
