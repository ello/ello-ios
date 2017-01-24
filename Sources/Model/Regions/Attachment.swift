////
///  Attachment.swift
//

import Foundation
import SwiftyJSON


let AttachmentVersion = 1

@objc(Attachment)
final class Attachment: JSONAble {

    // required
    let url: URL
    // optional
    var size: Int?
    var width: Int?
    var height: Int?
    var type: String?
    var image: UIImage?

// MARK: Initialization

    init(url: URL) {
        self.url = url
        super.init(version: AttachmentVersion)
    }

// MARK: NSCoding

    required init(coder aDecoder: NSCoder) {
        let decoder = Coder(aDecoder)
        // required
        self.url = decoder.decodeKey("url")
        // optional
        self.height = decoder.decodeOptionalKey("height")
        self.width = decoder.decodeOptionalKey("width")
        self.size = decoder.decodeOptionalKey("size")
        self.type = decoder.decodeOptionalKey("type")
        self.image = decoder.decodeOptionalKey("image")
        super.init(coder: decoder.coder)
    }

    override func encode(with encoder: NSCoder) {
        let coder = Coder(encoder)
        // required
        coder.encodeObject(url, forKey: "url")
        // optional
        coder.encodeObject(height, forKey: "height")
        coder.encodeObject(width, forKey: "width")
        coder.encodeObject(size, forKey: "size")
        coder.encodeObject(type, forKey: "type")
        coder.encodeObject(image, forKey: "image")
        super.encode(with: coder.coder)
    }

// MARK: JSONAble

    override class func fromJSON(_ data: [String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        var url = json["url"].stringValue
        if url.hasPrefix("//") {
            url = "https:\(url)"
        }
        // create attachment
        let attachment = Attachment(url: URL(string: url)!)
        // optional
        attachment.size = json["metadata"]["size"].int
        attachment.width = json["metadata"]["width"].int
        attachment.height = json["metadata"]["height"].int
        attachment.type = json["metadata"]["type"].string
        return attachment
    }
}

extension Attachment: JSONSaveable {
    var uniqueId: String? { if let id = tableId { return "Attachment-\(id)" } ; return nil }
    var tableId: String? { return url.absoluteString }

}
