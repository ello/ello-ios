////
///  Announcement.swift
//

import SwiftyJSON

// version 2: added 'isStaffPreview'
let AnnouncementVersion = 2

@objc(Announcement)
final class Announcement: Model {
    let id: String
    let isStaffPreview: Bool
    let header: String
    let body: String
    let ctaURL: URL?
    let ctaCaption: String
    let image: Asset?

    var preferredAttachment: Attachment? { return image?.hdpi }
    var imageURL: URL? { return preferredAttachment?.url }

    init(
        id: String,
        isStaffPreview: Bool,
        header: String,
        body: String,
        ctaURL: URL?,
        ctaCaption: String,
        image: Asset?
        ) {
        self.id = id
        self.isStaffPreview = isStaffPreview
        self.header = header
        self.body = body
        self.ctaURL = ctaURL
        self.ctaCaption = ctaCaption
        self.image = image
        super.init(version: AnnouncementVersion)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        id = decoder.decodeKey("id")
        let version: Int = decoder.decodeKey("version")
        if version < 2 {
            isStaffPreview = false
        }
        else {
            isStaffPreview = decoder.decodeKey("isStaffPreview")
        }
        header = decoder.decodeKey("header")
        body = decoder.decodeKey("body")
        ctaURL = decoder.decodeKey("ctaURL")
        ctaCaption = decoder.decodeKey("ctaCaption")
        image = decoder.decodeOptionalKey("image")
        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        let encoder = Coder(coder)
        encoder.encodeObject(id, forKey: "id")
        encoder.encodeObject(isStaffPreview, forKey: "isStaffPreview")
        encoder.encodeObject(header, forKey: "header")
        encoder.encodeObject(body, forKey: "body")
        encoder.encodeObject(ctaURL, forKey: "ctaURL")
        encoder.encodeObject(ctaCaption, forKey: "ctaCaption")
        encoder.encodeObject(image, forKey: "image")
        super.encode(with: coder)
    }

    class func fromJSON(_ data: [String: Any]) -> Announcement {
        let json = JSON(data)

        let id = json["id"].idValue

        let announcement = Announcement(
            id: id,
            isStaffPreview: json["is_staff_preview"].boolValue,
            header: json["header"].stringValue,
            body: json["body"].stringValue,
            ctaURL: json["cta_href"].string.flatMap { URL(string: $0) },
            ctaCaption: json["cta_caption"].stringValue,
            image: Asset.parseAsset("image_\(id)", node: data["image"] as? [String: Any])
            )

        announcement.mergeLinks(data["links"] as? [String: Any])

        return announcement
    }
}

extension Announcement: JSONSaveable {
    var uniqueId: String? { return "Announcement-\(id)" }
    var tableId: String? { return id }
}
