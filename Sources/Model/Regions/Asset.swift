////
///  Asset.swift
//

import SwiftyJSON


let AssetVersion = 1

@objc(Asset)
final class Asset: Model {
    enum AttachmentType {
        case optimized
        case mdpi
        case hdpi
        case xhdpi
        case original
        case large
        case regular
    }

    let id: String
    var optimized: Attachment?
    var mdpi: Attachment?
    var hdpi: Attachment?
    var xhdpi: Attachment?
    var original: Attachment?
    var large: Attachment?
    var regular: Attachment?
    var allAttachments: [(AttachmentType, Attachment)] {
        let possibles: [(AttachmentType, Attachment?)] = [
            (.optimized, optimized),
            (.mdpi, mdpi),
            (.hdpi, hdpi),
            (.xhdpi, xhdpi),
            (.original, original),
            (.large, large),
            (.regular, regular),
        ]
        return possibles.compactMap { type, attachment in
            return attachment.map { (type, $0) }
        }
    }

    var isGif: Bool {
        return original?.isGif == true || optimized?.isGif == true
    }

    var isLargeGif: Bool {
        if isGif, let size = optimized?.size {
            return size >= 3_145_728
        }
        return false
    }

    var isSmallGif: Bool {
        if isGif, let size = optimized?.size {
            return size <= 1_000_000
        }
        return false
    }

    var largeOrBest: Attachment? {
        if isGif, let original = original {
            return original
        }

        if DeviceScreen.isRetina {
            if let large = large { return large }
            if let xhdpi = xhdpi { return xhdpi }
            if let optimized = optimized { return optimized }
        }
        if let hdpi = hdpi { return hdpi }
        if let regular = regular { return regular }

        return nil
    }

    var oneColumnAttachment: Attachment? {
        return Window.isWide(Window.width) && DeviceScreen.isRetina ? xhdpi : hdpi
    }

    var gridLayoutAttachment: Attachment? {
        return Window.isWide(Window.width) && DeviceScreen.isRetina ? hdpi : mdpi
    }

    var aspectRatio: CGFloat {
        var attachment: Attachment?

        if let tryAttachment = oneColumnAttachment {
            attachment = tryAttachment
        }
        else if let tryAttachment = optimized {
            attachment = tryAttachment
        }

        if  let attachment = attachment,
            let width = attachment.width,
            let height = attachment.height
        {
            return CGFloat(width)/CGFloat(height)
        }
        return 4.0/3.0
    }

    convenience init(url: URL) {
        self.init(id: UUID().uuidString)

        let attachment = Attachment(url: url)
        self.optimized = attachment
        self.mdpi = attachment
        self.hdpi = attachment
        self.xhdpi = attachment
        self.original = attachment
        self.large = attachment
        self.regular = attachment
    }

    convenience init(url: URL, gifData: Data, posterImage: UIImage) {
        self.init(id: UUID().uuidString)

        let optimized = Attachment(url: url)
        optimized.type = "image/gif"
        optimized.size = gifData.count
        optimized.width = Int(posterImage.size.width)
        optimized.height = Int(posterImage.size.height)
        self.optimized = optimized

        let hdpi = Attachment(url: url)
        hdpi.width = Int(posterImage.size.width)
        hdpi.height = Int(posterImage.size.height)
        hdpi.image = posterImage
        self.hdpi = hdpi
    }

    convenience init(url: URL, image: UIImage) {
        self.init(id: UUID().uuidString)

        let optimized = Attachment(url: url)
        optimized.width = Int(image.size.width)
        optimized.height = Int(image.size.height)
        optimized.image = image

        self.optimized = optimized
    }

    init(id: String) {
        self.id = id
        super.init(version: AssetVersion)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        self.id = decoder.decodeKey("id")
        self.optimized = decoder.decodeOptionalKey("optimized")
        self.mdpi = decoder.decodeOptionalKey("mdpi")
        self.hdpi = decoder.decodeOptionalKey("hdpi")
        self.xhdpi = decoder.decodeOptionalKey("xhdpi")
        self.original = decoder.decodeOptionalKey("original")
        // optional avatar
        self.large = decoder.decodeOptionalKey("large")
        self.regular = decoder.decodeOptionalKey("regular")
        super.init(coder: coder)
    }

    override func encode(with encoder: NSCoder) {
        let coder = Coder(encoder)
        coder.encodeObject(id, forKey: "id")
        coder.encodeObject(optimized, forKey: "optimized")
        coder.encodeObject(mdpi, forKey: "mdpi")
        coder.encodeObject(hdpi, forKey: "hdpi")
        coder.encodeObject(xhdpi, forKey: "xhdpi")
        coder.encodeObject(original, forKey: "original")
        // optional avatar
        coder.encodeObject(large, forKey: "large")
        coder.encodeObject(regular, forKey: "regular")
        super.encode(with: coder.coder)
    }

    class func fromJSON(_ data: [String: Any]) -> Asset {
        let json = JSON(data)
        return parseAsset(json["id"].stringValue, node: data["attachment"] as? [String: Any])
    }

    class func parseAsset(_ id: String, node: [String: Any]?) -> Asset {
        let asset = Asset(id: id)
        guard let node = node else { return asset }

        let attachments: [(String, AttachmentType)] = [
            ("optimized", .optimized),
            ("mdpi", .mdpi),
            ("hdpi", .hdpi),
            ("xhdpi", .xhdpi),
            ("original", .original),
            ("large", .large),
            ("regular", .regular),
        ]
        for (name, type) in attachments {
            guard let attachment = node[name] as? [String: Any],
                let url = attachment["url"] as? String,
                url != ""
            else { continue }
            asset.replace(attachmentType: type, with: Attachment.fromJSON(attachment))
        }
        return asset
    }
}

extension Asset {
    func replace(attachmentType: AttachmentType, with attachment: Attachment?) {
        switch attachmentType {
        case .optimized:    optimized = attachment
        case .mdpi:         mdpi = attachment
        case .hdpi:         hdpi = attachment
        case .xhdpi:        xhdpi = attachment
        case .original:     original = attachment
        case .large:        large = attachment
        case .regular:      regular = attachment
        }
    }
}

extension Asset: JSONSaveable {
    var uniqueId: String? { return "Asset-\(id)" }
    var tableId: String? { return id }
}
