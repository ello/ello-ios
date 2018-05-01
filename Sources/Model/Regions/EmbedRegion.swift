////
///  EmbedRegion.swift
//

import SwiftyJSON


let EmbedRegionVersion = 1

@objc(EmbedRegion)
final class EmbedRegion: Model, Regionable {
    enum Service: String {
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

    let id: String
    let service: Service
    let url: URL
    let thumbnailLargeUrl: URL?

    var isRepost: Bool = false
    let kind: RegionKind = .embed

    var isAudioEmbed: Bool {
        return service == Service.mixcloud || service == Service.soundcloud || service == Service.bandcamp
    }

    init(
        id: String,
        service: Service,
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

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        self.id = decoder.decodeKey("id")
        self.isRepost = decoder.decodeKey("isRepost")
        let serviceRaw: String = decoder.decodeKey("serviceRaw")
        self.service = Service(rawValue: serviceRaw) ?? Service.unknown
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

    class func fromJSON(_ data: [String: Any]) -> EmbedRegion {
        let json = JSON(data)
        let thumbnailLargeUrl = json["data"]["thumbnail_large_url"].string.flatMap { URL(string: $0) }

        let embedRegion = EmbedRegion(
            id: json["data"]["id"].stringValue,
            service: Service(rawValue: json["data"]["service"].stringValue) ?? .unknown,
            url: URL(string: json["data"]["url"].stringValue) ?? URL(string: "https://ello.co/404")!,
            thumbnailLargeUrl: thumbnailLargeUrl
        )
        return embedRegion
    }

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
