////
///  Editorial.swift
//

import SwiftyJSON


@objc(Editorial)
final class Editorial: Model {
    // Version 3: initial (should have been 1, but copy/paste mistake)
    // Version 4: renderedSubtitle
    static let Version = 4

    typealias JoinInfo = (email: String?, username: String?, password: String?, submitted: Bool)
    typealias InviteInfo = (emails: String, sent: Date?)

    enum Kind: String {
        case post
        case postStream = "post_stream"
        case external
        case `internal`
        case invite
        case join
        case unknown
    }

    enum Size: String {
        case size1x1 = "one_by_one_image"
        // case size2x1 = "two_by_one_image"
        // case size1x2 = "one_by_two_image"
        case size2x2 = "two_by_two_image"

        static let all: [Size] = [size1x1, size2x2]
    }

    let id: String
    let kind: Kind
    let title: String
    let subtitle: String?
    let renderedSubtitle: String?
    var postStreamURL: URL?
    let url: URL?
    var join: JoinInfo?
    var invite: InviteInfo?
    var postId: String? { return post?.id }
    var post: Post? { return getLinkObject("post") }
    var posts: [Post]?
    var images: [Size: Asset] = [:]

    init(
        id: String,
        kind: Kind,
        title: String,
        subtitle: String? = nil,
        renderedSubtitle: String? = nil,
        postStreamURL: URL? = nil,
        url: URL? = nil)
    {
        self.id = id
        self.kind = kind
        self.title = title
        self.subtitle = subtitle
        self.renderedSubtitle = renderedSubtitle
        self.postStreamURL = postStreamURL
        self.url = url
        super.init(version: Editorial.Version)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        id = decoder.decodeKey("id")
        kind = Kind(rawValue: decoder.decodeKey("kind")) ?? .post
        title = decoder.decodeKey("title")
        subtitle = decoder.decodeOptionalKey("subtitle")
        renderedSubtitle = decoder.decodeOptionalKey("renderedSubtitle")
        postStreamURL = decoder.decodeOptionalKey("postStreamURL")
        url = decoder.decodeOptionalKey("url")
        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        let encoder = Coder(coder)
        encoder.encodeObject(id, forKey: "id")
        encoder.encodeObject(kind.rawValue, forKey: "kind")
        encoder.encodeObject(title, forKey: "title")
        encoder.encodeObject(subtitle, forKey: "subtitle")
        encoder.encodeObject(renderedSubtitle, forKey: "renderedSubtitle")
        encoder.encodeObject(postStreamURL, forKey: "postStreamURL")
        encoder.encodeObject(url, forKey: "url")
        super.encode(with: coder)
    }

    class func fromJSON(_ data: [String: Any]) -> Editorial {
        let json = JSON(data)
        let id = json["id"].stringValue
        let kind = Kind(rawValue: json["kind"].stringValue) ?? .unknown
        let title = json["title"].stringValue
        let subtitle = json["subtitle"].string
        let renderedSubtitle = json["rendered_subtitle"].string
        let postStreamURL = json["links"]["post_stream"]["href"].string.flatMap { URL(string: $0) }
        let externalURL: URL? = json["url"].string.flatMap { URL(string: $0) }
        let internalURL: URL? = json["path"].string.flatMap { URL(string: "\(ElloURI.baseURL)\($0)") }

        let editorial = Editorial(
            id: id,
            kind: kind,
            title: title,
            subtitle: subtitle,
            renderedSubtitle: renderedSubtitle,
            postStreamURL: postStreamURL,
            url: externalURL ?? internalURL)

        editorial.mergeLinks(data["links"] as? [String: Any])

        for size in Size.all {
            guard let assetData = data[size.rawValue] as? [String: Any] else { continue }

            let asset = Asset.parseAsset("", node: assetData)
            editorial.images[size] = asset
        }
        return editorial
    }
}

extension Editorial: JSONSaveable {
    var uniqueId: String? { return "Editorial-\(id)" }
    var tableId: String? { return id }
}
