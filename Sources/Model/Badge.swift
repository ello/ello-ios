////
///  User.swift
//

import SwiftyJSON


// version 1: initial
// amend: renamed 'link' to 'caption', kept coder/decoder as 'link'
let BadgeVersion: Int = 2

@objc(Badge)
final class Badge: Model {
    var slug: String
    var name: String
    var caption: String
    var url: URL?
    var imageURL: URL?
    var isFeatured: Bool { return slug == "featured" }

    let categories: [Category]?

    static var badges: [String: Badge] {
        get { return readBadges() }
        set {
            let data = NSKeyedArchiver.archivedData(withRootObject: newValue)
            saveBadgesData(data)
        }
    }

    init(badge: Badge, categories: [Category]?) {
        self.slug = badge.slug
        self.name = badge.name
        self.caption = badge.caption
        self.url = badge.url
        self.imageURL = badge.imageURL
        self.categories = categories
        super.init(version: BadgeVersion)
    }

    init(slug: String,
        name: String,
        caption: String,
        url: URL?,
        imageURL: URL?
        )
    {
        self.slug = slug
        self.name = name
        self.caption = caption
        self.url = url
        self.imageURL = imageURL
        self.categories = nil
        super.init(version: BadgeVersion)
    }

    static func lookup(slug: String) -> Badge? {
        return Badge.badges[slug]
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        self.slug = decoder.decodeKey("slug")
        self.name = decoder.decodeKey("name")
        self.caption = decoder.decodeKey("link")
        self.url = decoder.decodeOptionalKey("url")
        self.imageURL = decoder.decodeOptionalKey("imageURL")
        self.categories = nil
        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        let encoder = Coder(coder)
        encoder.encodeObject(slug, forKey: "slug")
        encoder.encodeObject(name, forKey: "name")
        encoder.encodeObject(caption, forKey: "link")
        encoder.encodeObject(url, forKey: "url")
        encoder.encodeObject(imageURL, forKey: "imageURL")
        super.encode(with: coder)
    }

    class func fromJSON(_ data: [String: Any]) -> Badge {
        let json = JSON(data)
        return Badge(
            slug: json["slug"].stringValue,
            name: json["name"].stringValue,
            caption: json["learn_more_caption"].stringValue,
            url: json["learn_more_href"].string.flatMap { URL(string: $0) },
            imageURL: json["image"]["url"].string.flatMap { URL(string: $0) }
            )
    }

}

private var _cachedBadges: [String: Badge]?
private func readBadges() -> [String: Badge] {
    if let _cachedBadges = _cachedBadges { return _cachedBadges }

    guard
        let fileURL = badgesFileURL(),
        let data = (try? Data(contentsOf: fileURL)),
        let badges = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Badge]
    else { return [:] }

    _cachedBadges = badges
    return badges
}

private func saveBadgesData(_ data: Data) {
    guard let fileURL = badgesFileURL() else { return }
    try? data.write(to: fileURL, options: [.atomic])
}

private func badgesFileURL() -> URL? {
    guard let pathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
    return pathURL.appendingPathComponent("badges-v2.data")
}
