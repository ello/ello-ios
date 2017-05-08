////
///  User.swift
//

import SwiftyJSON


// version 1: initial
// version 2: added isHireable
// version 3: added notifyOfWatchesViaPush, notifyOfWatchesViaEmail
// version 4: added notifyOfCommentsOnPostWatchViaPush, notifyOfCommentsOnPostWatchViaEmail
// version 5: added isCollaborateable, moved notifyOf* into Profile
// version 6: added categories, totalViewCount
// version 7: added location
// version 8: added badges
let UserVersion: Int = 8

@objc(User)
final class User: JSONAble {

    // active record
    let id: String
    // required
    let href: String
    let username: String
    let name: String
    var displayName: String {
        if name.isEmpty {
            return atName
        }
        return name
    }
    let experimentalFeatures: Bool
    var relationshipPriority: RelationshipPriority
    let postsAdultContent: Bool
    let viewsAdultContent: Bool
    var hasCommentingEnabled: Bool
    var hasSharingEnabled: Bool
    var hasRepostingEnabled: Bool
    var hasLovesEnabled: Bool
    var isCollaborateable: Bool
    var isHireable: Bool
    var isFeatured: Bool {
        return (categories?.count ?? 0) > 0
    }
    // optional
    var avatar: Asset? // required, but kinda optional due to it being nested in json
    var identifiableBy: String?
    var postsCount: Int?
    var lovesCount: Int?
    var followersCount: String? // string due to this returning "∞" for the ello user
    var followingCount: Int?
    var formattedShortBio: String?
    var externalLinksList: [ExternalLink]?
    var coverImage: Asset?
    var backgroundPosition: String?
    var onboardingVersion: Int?
    var totalViewsCount: Int?
    var formattedTotalCount: String? {
        guard let count = totalViewsCount else { return nil }

        if count < 1000 {
            return "<1K"
        }
        return count.numberToHuman(rounding: 1, showZero: true)
    }
    var location: String?

    // links
    var posts: [Post]? { return getLinkArray("posts") as? [Post] }
    var categories: [Category]? { return getLinkArray("categories") as? [Category] }
    private var _badges: [Badge]?
    var badges: [Badge] {
        get {
            guard let badges = _badges, badges.count > 0 else {
                if let count = categories?.count, count > 0,
                    let badge = Badge.lookup(slug: "featured")
                {
                    return [badge]
                }
                return []
            }
            return badges
        }
        set { _badges = newValue }
    }

    // computed
    var atName: String { return "@\(username)"}
    var isCurrentUser: Bool { return self.profile != nil }
    // profile
    var profile: Profile?

    var shareLink: String {
        return "\(ElloURI.baseURL)/\(username)"
    }

    init(id: String,
        href: String,
        username: String,
        name: String,
        experimentalFeatures: Bool,
        relationshipPriority: RelationshipPriority,
        postsAdultContent: Bool,
        viewsAdultContent: Bool,
        hasCommentingEnabled: Bool,
        hasSharingEnabled: Bool,
        hasRepostingEnabled: Bool,
        hasLovesEnabled: Bool,
        isCollaborateable: Bool,
        isHireable: Bool)
    {
        self.id = id
        self.href = href
        self.username = username
        self.name = name
        self.experimentalFeatures = experimentalFeatures
        self.relationshipPriority = relationshipPriority
        self.postsAdultContent = postsAdultContent
        self.viewsAdultContent = viewsAdultContent
        self.hasCommentingEnabled = hasCommentingEnabled
        self.hasSharingEnabled = hasSharingEnabled
        self.hasRepostingEnabled = hasRepostingEnabled
        self.hasLovesEnabled = hasLovesEnabled
        self.isCollaborateable = isCollaborateable
        self.isHireable = isHireable
        super.init(version: UserVersion)
    }

// MARK: NSCoding

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        // active record
        self.id = decoder.decodeKey("id")
        // required
        self.href = decoder.decodeKey("href")
        self.username = decoder.decodeKey("username")
        self.name = decoder.decodeKey("name")
        self.experimentalFeatures = decoder.decodeKey("experimentalFeatures")
        let relationshipPriorityRaw: String = decoder.decodeKey("relationshipPriorityRaw")
        self.relationshipPriority = RelationshipPriority(stringValue: relationshipPriorityRaw)
        self.postsAdultContent = decoder.decodeKey("postsAdultContent")
        self.viewsAdultContent = decoder.decodeKey("viewsAdultContent")
        self.hasCommentingEnabled = decoder.decodeKey("hasCommentingEnabled")
        self.hasSharingEnabled = decoder.decodeKey("hasSharingEnabled")
        self.hasRepostingEnabled = decoder.decodeKey("hasRepostingEnabled")
        self.hasLovesEnabled = decoder.decodeKey("hasLovesEnabled")
        // added
        let version: Int = decoder.decodeKey("version")
        if version < 2 {
            self.isHireable = false
        }
        else {
            self.isHireable = decoder.decodeKey("isHireable")
        }

        // versions 3 and 4 removed

        if version < 5 {
            self.isCollaborateable = false
        }
        else {
            self.isCollaborateable = decoder.decodeKey("isCollaborateable")
        }

        if let badgeNames: [String] = decoder.decodeOptionalKey("badges") {
            self._badges = badgeNames.flatMap { Badge.lookup(slug: $0) }
        }

        // optional
        self.avatar = decoder.decodeOptionalKey("avatar")
        self.identifiableBy = decoder.decodeOptionalKey("identifiableBy")
        self.postsCount = decoder.decodeOptionalKey("postsCount")
        self.lovesCount = decoder.decodeOptionalKey("lovesCount")
        self.followersCount = decoder.decodeOptionalKey("followersCount")
        self.followingCount = decoder.decodeOptionalKey("followingCount")
        self.formattedShortBio = decoder.decodeOptionalKey("formattedShortBio")
        if let externalLinksList: [[String: String]] = decoder.decodeOptionalKey("externalLinksList") {
            self.externalLinksList = externalLinksList.flatMap { ExternalLink.fromDict($0) }
        }
        self.coverImage = decoder.decodeOptionalKey("coverImage")
        self.backgroundPosition = decoder.decodeOptionalKey("backgroundPosition")
        self.onboardingVersion = decoder.decodeOptionalKey("onboardingVersion")
        self.totalViewsCount = decoder.decodeOptionalKey("totalViewsCount")
        self.location = decoder.decodeOptionalKey("location")

        // profile
        self.profile = decoder.decodeOptionalKey("profile")
        super.init(coder: coder)
    }

    class func empty(id: String = UUID().uuidString) -> User {
        return User(
            id: id,
            href: "",
            username: "",
            name: "",
            experimentalFeatures: false,
            relationshipPriority: RelationshipPriority.none,
            postsAdultContent: false,
            viewsAdultContent: false,
            hasCommentingEnabled: true,
            hasSharingEnabled: true,
            hasRepostingEnabled: true,
            hasLovesEnabled: true,
            isCollaborateable: false,
            isHireable: false)
    }

    override func encode(with coder: NSCoder) {
        let encoder = Coder(coder)

        // active record
        encoder.encodeObject(id, forKey: "id")

        // required
        encoder.encodeObject(href, forKey: "href")
        encoder.encodeObject(username, forKey: "username")
        encoder.encodeObject(name, forKey: "name")
        encoder.encodeObject(experimentalFeatures, forKey: "experimentalFeatures")
        encoder.encodeObject(relationshipPriority.rawValue, forKey: "relationshipPriorityRaw")
        encoder.encodeObject(postsAdultContent, forKey: "postsAdultContent")
        encoder.encodeObject(viewsAdultContent, forKey: "viewsAdultContent")
        encoder.encodeObject(hasCommentingEnabled, forKey: "hasCommentingEnabled")
        encoder.encodeObject(hasSharingEnabled, forKey: "hasSharingEnabled")
        encoder.encodeObject(hasRepostingEnabled, forKey: "hasRepostingEnabled")
        encoder.encodeObject(hasLovesEnabled, forKey: "hasLovesEnabled")
        encoder.encodeObject(isCollaborateable, forKey: "isCollaborateable")
        encoder.encodeObject(isHireable, forKey: "isHireable")

        // optional
        encoder.encodeObject(avatar, forKey: "avatar")
        encoder.encodeObject(identifiableBy, forKey: "identifiableBy")
        encoder.encodeObject(postsCount, forKey: "postsCount")
        encoder.encodeObject(lovesCount, forKey: "lovesCount")
        encoder.encodeObject(followingCount, forKey: "followingCount")
        encoder.encodeObject(followersCount, forKey: "followersCount")
        encoder.encodeObject(formattedShortBio, forKey: "formattedShortBio")
        encoder.encodeObject(externalLinksList?.map { $0.toDict() }, forKey: "externalLinksList")
        encoder.encodeObject(coverImage, forKey: "coverImage")
        encoder.encodeObject(backgroundPosition, forKey: "backgroundPosition")
        encoder.encodeObject(onboardingVersion, forKey: "onboardingVersion")
        encoder.encodeObject(totalViewsCount, forKey: "totalViewsCount")
        encoder.encodeObject(location, forKey: "location")
        encoder.encodeObject(badges.map { $0.slug }, forKey: "badges")

        // profile
        encoder.encodeObject(profile, forKey: "profile")
        super.encode(with: coder)
    }

// MARK: JSONAble

    override func merge(_ other: JSONAble) -> JSONAble {
        if let otherUser = other as? User {
            if otherUser.formattedShortBio == nil {
                otherUser.formattedShortBio = formattedShortBio
            }
            if otherUser.externalLinksList == nil {
                otherUser.externalLinksList = externalLinksList
            }
            return otherUser
        }
        return other
    }

    override class func fromJSON(_ data: [String: Any]) -> JSONAble {
        let json = JSON(data)
        // create user
        let user = User(
            id: json["id"].stringValue,
            href: json["href"].stringValue,
            username: json["username"].stringValue,
            name: json["name"].stringValue,
            experimentalFeatures: json["experimental_features"].boolValue,
            relationshipPriority: RelationshipPriority(stringValue: json["relationship_priority"].stringValue),
            postsAdultContent: json["posts_adult_content"].boolValue,
            viewsAdultContent: json["views_adult_content"].boolValue,
            hasCommentingEnabled: json["has_commenting_enabled"].boolValue,
            hasSharingEnabled: json["has_sharing_enabled"].boolValue,
            hasRepostingEnabled: json["has_reposting_enabled"].boolValue,
            hasLovesEnabled: json["has_loves_enabled"].boolValue,
            isCollaborateable: json["is_collaborateable"].boolValue,
            isHireable: json["is_hireable"].boolValue
        )

        // optional
        user.avatar = Asset.parseAsset("user_avatar_\(user.id)", node: data["avatar"] as? [String: Any])
        user.identifiableBy = json["identifiable_by"].stringValue
        user.postsCount = json["posts_count"].int
        user.lovesCount = json["loves_count"].int
        user.followersCount = json["followers_count"].stringValue
        user.followingCount = json["following_count"].int
        user.formattedShortBio = json["formatted_short_bio"].string
        // grab links
        if let links = json["external_links_list"].array {
            let externalLinks = links.flatMap { $0.dictionaryObject as? [String: String] }
            user.externalLinksList = externalLinks.flatMap { ExternalLink.fromDict($0) }
        }
        user.coverImage = Asset.parseAsset("user_cover_image_\(user.id)", node: data["cover_image"] as? [String: Any])
        user.backgroundPosition = json["background_positiion"].stringValue
        if let webOnboardingVersion = json["web_onboarding_version"].string {
            user.onboardingVersion = Int(webOnboardingVersion)
        }
        // links
        user.links = data["links"] as? [String: Any]
        // profile
        if (json["created_at"].stringValue).characters.count > 0 {
            user.profile = Profile.fromJSON(data) as? Profile
        }

        if let badgeNames: [String] = json["badges"].array?.flatMap({ $0.string }) {
            user.badges = badgeNames
                .flatMap { Badge.lookup(slug: $0) }
        }

        user.totalViewsCount = json["total_views_count"].int
        user.location = json["location"].string

        return user
    }
}

extension User {

    func hasProperty(key: String) -> Bool {
        if responds(to: Selector(key.camelCase)) {
            return true
        } else if profile?.responds(to: Selector(key.camelCase)) == true {
            return true
        }
        return false
    }

    func propertyForSettingsKey(key: String) -> Bool {
        let kvo = key.camelCase
        let selector = Selector(kvo)
        let value: Bool?
        if profile?.responds(to: selector) == true {
            value = profile?.value(forKey: kvo) as? Bool
        } else if responds(to: selector) {
            value = self.value(forKey: kvo) as? Bool
        }
        else {
            value = false
        }
        return value ?? false
    }

    func setPropertyForSettingsKey(key: String, value: Bool) {
        let kvo = key.camelCase
        let selector = Selector(kvo)
        if profile?.responds(to: selector) == true {
            profile?.setValue(value, forKey: kvo)
        } else if responds(to: selector) {
            setValue(value, forKey: kvo)
        }
    }
}

extension User {
    func isOwn(post: Post) -> Bool {
        return id == post.authorId
    }

    func isOwn(comment: ElloComment) -> Bool {
        return id == comment.authorId
    }

    func isOwnParentPost(comment: ElloComment) -> Bool {
        return id == comment.loadedFromPost?.authorId || id == comment.loadedFromPost?.repostAuthor?.id
    }
}

extension User {
    func updateDefaultImages(avatarURL: URL?, coverImageURL: URL?) {
        if let avatarURL = avatarURL {
            if let avatar = avatar {
                let replacement = Attachment(url: avatarURL)
                for (type, attachment) in avatar.allAttachments {
                    if attachment.url.absoluteString.contains("/ello-default-") {
                        avatar.replace(attachmentType: type, with: replacement)
                    }
                }
            }
            else {
                avatar = Asset(url: avatarURL)
            }
        }

        if let coverImageURL = coverImageURL {
            if let coverImage = coverImage {
                let replacement = Attachment(url: coverImageURL)
                for (type, attachment) in coverImage.allAttachments {
                    if attachment.url.absoluteString.contains("/ello-default-") {
                        coverImage.replace(attachmentType: type, with: replacement)
                    }
                }
            }
            else {
                coverImage = Asset(url: coverImageURL)
            }
        }
    }
}

extension User {
    func coverImageURL(viewsAdultContent: Bool? = false, animated: Bool = false) -> URL? {
        if animated && (!postsAdultContent || viewsAdultContent == true) && coverImage?.original?.url.absoluteString.hasSuffix(".gif") == true {
            return coverImage?.original?.url as URL?
        }
        return coverImage?.oneColumnAttachment?.url as URL?
    }

    func avatarURL(viewsAdultContent: Bool? = false, animated: Bool = false) -> URL? {
        if animated && (!postsAdultContent || viewsAdultContent == true) && avatar?.original?.url.absoluteString.hasSuffix(".gif") == true {
            return avatar?.original?.url as URL?
        }
        return avatar?.largeOrBest?.url as URL?
    }
}

extension User: JSONSaveable {
    var uniqueId: String? { return "User-\(id)" }
    var tableId: String? { return id }

}
