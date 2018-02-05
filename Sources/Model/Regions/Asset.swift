////
///  Asset.swift
//

import SwiftyJSON


let AssetVersion = 1

@objc(Asset)
final class Asset: JSONAble {
    enum AttachmentType {
        case optimized
        case ldpi
        case mdpi
        case hdpi
        case xhdpi
        case original
        case large
        case regular
        case small
    }

    let id: String
    var optimized: Attachment?
    var ldpi: Attachment?
    var mdpi: Attachment?
    var hdpi: Attachment?
    var xhdpi: Attachment?
    var original: Attachment?
    // optional avatar
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
    var large: Attachment?
    var regular: Attachment?
    var small: Attachment?
    var allAttachments: [(AttachmentType, Attachment)] {
        let possibles: [(AttachmentType, Attachment?)] = [
            (.optimized, optimized),
            (.ldpi, ldpi),
            (.mdpi, mdpi),
            (.hdpi, hdpi),
            (.xhdpi, xhdpi),
            (.original, original),
            (.large, large),
            (.regular, regular),
            (.small, small)
        ]
        return possibles.flatMap { type, attachment in
            return attachment.map { (type, $0) }
        }
    }

    var isGif: Bool {
        return original?.isGif == true || optimized?.isGif == true
    }

    var isLargeGif: Bool {
        if isGif, let size = self.optimized?.size {
            return size >= 3_145_728
        }
        return false
    }

    var isSmallGif: Bool {
        if isGif, let size = self.optimized?.size {
            return size <= 1_000_000
        }
        return false
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

// MARK: Initialization

    convenience init(url: URL) {
        self.init(id: UUID().uuidString)

        let attachment = Attachment(url: url)
        self.optimized = attachment
        self.ldpi = attachment
        self.mdpi = attachment
        self.hdpi = attachment
        self.xhdpi = attachment
        self.original = attachment
        self.large = attachment
        self.regular = attachment
        self.small = attachment
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

    init(id: String)
    {
        self.id = id
        super.init(version: AssetVersion)
    }

// MARK: NSCoding

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        self.id = decoder.decodeKey("id")
        self.optimized = decoder.decodeOptionalKey("optimized")
        self.ldpi = decoder.decodeOptionalKey("ldpi")
        self.mdpi = decoder.decodeOptionalKey("mdpi")
        self.hdpi = decoder.decodeOptionalKey("hdpi")
        self.xhdpi = decoder.decodeOptionalKey("xhdpi")
        self.original = decoder.decodeOptionalKey("original")
        // optional avatar
        self.large = decoder.decodeOptionalKey("large")
        self.regular = decoder.decodeOptionalKey("regular")
        self.small = decoder.decodeOptionalKey("small")
        super.init(coder: coder)
    }

    override func encode(with encoder: NSCoder) {
        let coder = Coder(encoder)
        coder.encodeObject(id, forKey: "id")
        coder.encodeObject(optimized, forKey: "optimized")
        coder.encodeObject(ldpi, forKey: "ldpi")
        coder.encodeObject(mdpi, forKey: "mdpi")
        coder.encodeObject(hdpi, forKey: "hdpi")
        coder.encodeObject(xhdpi, forKey: "xhdpi")
        coder.encodeObject(original, forKey: "original")
        // optional avatar
        coder.encodeObject(large, forKey: "large")
        coder.encodeObject(regular, forKey: "regular")
        coder.encodeObject(small, forKey: "small")
        super.encode(with: coder.coder)
    }

// MARK: JSONAble

    class func fromJSON(_ data: [String: Any]) -> Asset {
        let json = JSON(data)
        return parseAsset(json["id"].stringValue, node: data["attachment"] as? [String: Any])
    }

    class func parseAsset(_ id: String, node: [String: Any]?) -> Asset {
        let asset = Asset(id: id)
        guard let node = node else { return asset }

        if let optimized = node["optimized"] as? [String: Any] {
            asset.optimized = Attachment.fromJSON(optimized)
        }
        if let ldpi = node["ldpi"] as? [String: Any] {
            asset.ldpi = Attachment.fromJSON(ldpi)
        }
        if let mdpi = node["mdpi"] as? [String: Any] {
            asset.mdpi = Attachment.fromJSON(mdpi)
        }
        if let hdpi = node["hdpi"] as? [String: Any] {
            asset.hdpi = Attachment.fromJSON(hdpi)
        }
        if let xhdpi = node["xhdpi"] as? [String: Any] {
            asset.xhdpi = Attachment.fromJSON(xhdpi)
        }
        if let original = node["original"] as? [String: Any] {
            asset.original = Attachment.fromJSON(original)
        }
        // optional avatar
        if let large = node["large"] as? [String: Any] {
            asset.large = Attachment.fromJSON(large)
        }
        if let regular = node["regular"] as? [String: Any] {
            asset.regular = Attachment.fromJSON(regular)
        }
        if let small = node["small"] as? [String: Any] {
            asset.small = Attachment.fromJSON(small)
        }
        return asset
    }
}

extension Asset {
    func replace(attachmentType: AttachmentType, with attachment: Attachment?) {
        switch attachmentType {
        case .optimized:    optimized = attachment
        case .ldpi:         ldpi = attachment
        case .mdpi:         mdpi = attachment
        case .hdpi:         hdpi = attachment
        case .xhdpi:        xhdpi = attachment
        case .original:     original = attachment
        case .large:        large = attachment
        case .regular:      regular = attachment
        case .small:        small = attachment
        }
    }
}

extension Asset: JSONSaveable {
    var uniqueId: String? { return "Asset-\(id)" }
    var tableId: String? { return id }

}
