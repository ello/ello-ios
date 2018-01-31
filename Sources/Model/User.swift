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

    let id: String
    let username: String
    let name: String
    var experimentalFeatures: Bool?
    var relationshipPriority: RelationshipPriority
    @objc var postsAdultContent: Bool
    @objc var viewsAdultContent: Bool
    @objc var hasCommentingEnabled: Bool
    @objc var hasSharingEnabled: Bool
    @objc var hasRepostingEnabled: Bool
    @objc var hasLovesEnabled: Bool
    @objc var isCollaborateable: Bool
    @objc var isHireable: Bool

    var avatar: Asset?
    var identifiableBy: String?
    var postsCount: Int?
    var lovesCount: Int?
    var followersCount: String? // string due to this returning "∞" for the ello user
    var followingCount: Int?
    var formattedShortBio: String?
    var externalLinksList: [ExternalLink]?
    var externalLinksString: String? {
        guard let externalLinksList = externalLinksList else { return nil }

        let urls = externalLinksList.map { $0.url.absoluteString }
        return urls.joined(separator: ", ")
    }
    var coverImage: Asset?
    var onboardingVersion: Int?
    var totalViewsCount: Int?
    var location: String?

    var categories: [Category]? { return getLinkArray("categories") as? [Category] }
    private var _badges: [Badge]?
    var badges: [Badge] {
        get { return _badges ?? [] }
        set { _badges = newValue }
    }
    var profile: Profile?

    // computed
    var isCurrentUser: Bool { return self.profile != nil }
    var atName: String { return "@\(username)"}
    var displayName: String {
        if name.isEmpty {
            return atName
        }
        return name
    }
    var shareLink: String {
        return "\(ElloURI.baseURL)/\(username)"
    }
    var isFeatured: Bool {
        return (categories?.count ?? 0) > 0
    }
    var formattedTotalCount: String? {
        guard let count = totalViewsCount else { return nil }

        if count < 1000 {
            return "<1K"
        }
        return count.numberToHuman(rounding: 1, showZero: true)
    }

    init(id: String,
        username: String,
        name: String,
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
        self.username = username
        self.name = name
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
        self.id = decoder.decodeKey("id")
        self.username = decoder.decodeKey("username")
        self.name = decoder.decodeKey("name")
        self.experimentalFeatures = decoder.decodeOptionalKey("experimentalFeatures")
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
            username: "",
            name: "",
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

        encoder.encodeObject(id, forKey: "id")
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
        encoder.encodeObject(avatar, forKey: "avatar")
        encoder.encodeObject(identifiableBy, forKey: "identifiableBy")
        encoder.encodeObject(postsCount, forKey: "postsCount")
        encoder.encodeObject(lovesCount, forKey: "lovesCount")
        encoder.encodeObject(followingCount, forKey: "followingCount")
        encoder.encodeObject(followersCount, forKey: "followersCount")
        encoder.encodeObject(formattedShortBio, forKey: "formattedShortBio")
        encoder.encodeObject(externalLinksList?.map { $0.toDict() }, forKey: "externalLinksList")
        encoder.encodeObject(coverImage, forKey: "coverImage")
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

    class func fromJSON(_ data: [String: Any]) -> User {
        let json = JSON(data)

        let user = User(
            id: json["id"].stringValue,
            username: json["username"].stringValue,
            name: json["name"].stringValue,
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

        user.avatar = Asset.parseAsset("user_avatar_\(user.id)", node: data["avatar"] as? [String: Any])
        user.coverImage = Asset.parseAsset("user_cover_image_\(user.id)", node: data["cover_image"] as? [String: Any])

        user.experimentalFeatures = json["experimental_features"].bool
        user.identifiableBy = json["identifiable_by"].string
        user.postsCount = json["posts_count"].int
        user.lovesCount = json["loves_count"].int
        if let count = json["followers_count"].string {
            user.followersCount = count
        }
        else {
            user.followersCount = json["followers_count"].int.map { "\($0)" }
        }
        user.followingCount = json["following_count"].int
        user.formattedShortBio = json["formatted_short_bio"].string
        user.onboardingVersion = json["web_onboarding_version"].string.flatMap { Int($0) }
        user.totalViewsCount = json["total_views_count"].int
        user.location = json["location"].string

        if let links = json["external_links_list"].array {
            let externalLinks = links.flatMap { $0.dictionaryObject as? [String: String] }
            user.externalLinksList = externalLinks.flatMap { ExternalLink.fromDict($0) }
        }

        if let badgeNames: [String] = json["badges"].array?.flatMap({ $0.string }) {
            user.badges = badgeNames
                .flatMap { Badge.lookup(slug: $0) }
        }

        user.links = data["links"] as? [String: Any]

        if json["relationship_priority"].string == "self" {
            user.profile = Profile.fromJSON(data)
        }

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
    func isAuthorOf(post: Post) -> Bool {
        return id == post.authorId
    }

    func isAuthorOf(comment: ElloComment) -> Bool {
        return id == comment.authorId
    }

    func isAuthorOfParentPost(comment: ElloComment) -> Bool {
        if let repostAuthor = comment.loadedFromPost?.repostAuthor {
            return id == repostAuthor.id
        }
        return id == comment.loadedFromPost?.authorId
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
            return coverImage?.original?.url
        }
        return coverImage?.oneColumnAttachment?.url
    }

    func avatarURL(viewsAdultContent: Bool? = false, animated: Bool = false) -> URL? {
        if animated && (!postsAdultContent || viewsAdultContent == true) && avatar?.original?.url.absoluteString.hasSuffix(".gif") == true {
            return avatar?.original?.url
        }
        return avatar?.largeOrBest?.url
    }
}

extension User: JSONSaveable {
    var uniqueId: String? { return User.uniqueId(id) }
    var tableId: String? { return id }

    class func uniqueId(_ id: String) -> String { return "User-\(id)" }
}
