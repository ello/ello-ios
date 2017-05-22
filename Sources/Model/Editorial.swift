////
///  Editorial.swift
//

import SwiftyJSON

// Version 1: initial
let EditorialVersion = 3

final class Editorial: JSONAble, Groupable {
    typealias JoinInfo = (email: String?, username: String?, password: String?)
    typealias InviteInfo = (emails: String, sent: Bool)

    enum Kind: String {
        case post
        case postStream = "post_stream"
        case external
        case invite
        case join
    }

    let id: String
    let title: String
    let subtitle: String?
    var join: JoinInfo?
    var invite: InviteInfo?
    let url: URL?
    let kind: Kind
    var groupId: String { return "Category-\(id)" }

    init(
        id: String,
        kind: Kind,
        title: String,
        subtitle: String? = nil,
        url: URL? = nil)
    {
        self.id = id
        self.kind = kind
        self.title = title
        self.subtitle = subtitle
        self.url = url
        super.init(version: EditorialVersion)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        id = decoder.decodeKey("id")
        kind = Kind(rawValue: decoder.decodeKey("kind")) ?? .post
        title = decoder.decodeKey("title")
        subtitle = decoder.decodeOptionalKey("subtitle")
        url = decoder.decodeOptionalKey("url")
        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        let encoder = Coder(coder)
        encoder.encodeObject(id, forKey: "id")
        encoder.encodeObject(kind.rawValue, forKey: "kind")
        encoder.encodeObject(title, forKey: "title")
        encoder.encodeObject(subtitle, forKey: "subtitle")
        encoder.encodeObject(url, forKey: "url")
        super.encode(with: coder)
    }

    override class func fromJSON(_ data: [String: Any]) -> JSONAble {
        let json = JSON(data)
        let id = json["id"].stringValue
        let kind = Kind(rawValue: json["kind"].stringValue) ?? .post
        let title = json["title"].stringValue
        let subtitle = json["subtitle"].string
        let url: URL? = json["url"].string.flatMap { URL(string: $0) }

        let editorial = Editorial(
            id: id,
            kind: kind,
            title: title,
            subtitle: subtitle,
            url: url)
        return editorial
    }
}

extension Editorial: JSONSaveable {
    var uniqueId: String? { return "Editorial-\(id)" }
    var tableId: String? { return id }
}
