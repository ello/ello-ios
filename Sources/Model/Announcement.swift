////
///  Announcement.swift
//

import SwiftyJSON

let AnnouncementVersion = 1

@objc
final class Announcement: JSONAble, Groupable {
    let id: String
    let header: String
    let body: String
    let ctaURL: URL?
    let ctaCaption: String
    let createdAt: Date
    var image: Asset?
    var preferredAttachment: Attachment? { return image?.hdpi }
    var imageURL: URL? { return preferredAttachment?.url }

    var groupId: String { return "Announcement-\(id)" }

    init(
        id: String,
        header: String,
        body: String,
        ctaURL: URL?,
        ctaCaption: String,
        createdAt: Date) {
        self.id = id
        self.header = header
        self.body = body
        self.ctaURL = ctaURL
        self.ctaCaption = ctaCaption
        self.createdAt = createdAt
        super.init(version: AnnouncementVersion)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        id = decoder.decodeKey("id")
        header = decoder.decodeKey("header")
        body = decoder.decodeKey("body")
        ctaURL = decoder.decodeKey("ctaURL")
        ctaCaption = decoder.decodeKey("ctaCaption")
        createdAt = decoder.decodeKey("createdAt")
        image = decoder.decodeOptionalKey("image")
        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        let encoder = Coder(coder)
        encoder.encodeObject(id, forKey: "id")
        encoder.encodeObject(header, forKey: "header")
        encoder.encodeObject(body, forKey: "body")
        encoder.encodeObject(ctaURL, forKey: "ctaURL")
        encoder.encodeObject(ctaCaption, forKey: "ctaCaption")
        encoder.encodeObject(createdAt, forKey: "createdAt")
        encoder.encodeObject(image, forKey: "image")
        super.encode(with: coder)
    }

    override class func fromJSON(_ data: [String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        let id = json["id"].stringValue
        let header = json["header"].stringValue
        let body = json["body"].stringValue
        let ctaURL = json["cta_href"].string.flatMap { URL(string: $0) }
        let ctaCaption = json["cta_caption"].stringValue
        let createdAt: Date = json["created_at"].string?.toDate() ?? Date()

        let announcement = Announcement(id: id,
            header: header,
            body: body,
            ctaURL: ctaURL,
            ctaCaption: ctaCaption,
            createdAt: createdAt
            )
        announcement.image = Asset.parseAsset("image_\(id)", node: data["image"] as? [String: AnyObject])
        return announcement
    }
}

extension Announcement: JSONSaveable {
    var uniqueId: String? { if let id = tableId { return "Announcement-\(id)" } ; return nil }
    var tableId: String? { return id }

}
