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
let UserVersion: Int = 7

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
        return count.numberToHuman(rounding: 2, showZero: true)
    }
    var location: String?

    // links
    var posts: [Post]? { return getLinkArray("posts") as? [Post] }
    var categories: [Category]? { return getLinkArray("categories") as? [Category] }
    var mostRecentPost: Post? { return getLinkObject("most_recent_post") as? Post }

    // computed
    var atName: String { return "@\(username)"}
    var isCurrentUser: Bool { return self.profile != nil }
    // profile
    var profile: Profile?

    var shareLink: String? {
        get {
            return "\(ElloURI.baseURL)/\(username)"
        }
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

    required init(coder aDecoder: NSCoder) {
        let decoder = Coder(aDecoder)
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
        super.init(coder: decoder.coder)
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

    override func encode(with encoder: NSCoder) {
        let coder = Coder(encoder)

        // active record
        coder.encodeObject(id, forKey: "id")

        // required
        coder.encodeObject(href, forKey: "href")
        coder.encodeObject(username, forKey: "username")
        coder.encodeObject(name, forKey: "name")
        coder.encodeObject(experimentalFeatures, forKey: "experimentalFeatures")
        coder.encodeObject(relationshipPriority.rawValue, forKey: "relationshipPriorityRaw")
        coder.encodeObject(postsAdultContent, forKey: "postsAdultContent")
        coder.encodeObject(viewsAdultContent, forKey: "viewsAdultContent")
        coder.encodeObject(hasCommentingEnabled, forKey: "hasCommentingEnabled")
        coder.encodeObject(hasSharingEnabled, forKey: "hasSharingEnabled")
        coder.encodeObject(hasRepostingEnabled, forKey: "hasRepostingEnabled")
        coder.encodeObject(hasLovesEnabled, forKey: "hasLovesEnabled")
        coder.encodeObject(isCollaborateable, forKey: "isCollaborateable")
        coder.encodeObject(isHireable, forKey: "isHireable")

        // optional
        coder.encodeObject(avatar, forKey: "avatar")
        coder.encodeObject(identifiableBy, forKey: "identifiableBy")
        coder.encodeObject(postsCount, forKey: "postsCount")
        coder.encodeObject(lovesCount, forKey: "lovesCount")
        coder.encodeObject(followingCount, forKey: "followingCount")
        coder.encodeObject(followersCount, forKey: "followersCount")
        coder.encodeObject(formattedShortBio, forKey: "formattedShortBio")
        coder.encodeObject(externalLinksList?.map { $0.toDict() }, forKey: "externalLinksList")
        coder.encodeObject(coverImage, forKey: "coverImage")
        coder.encodeObject(backgroundPosition, forKey: "backgroundPosition")
        coder.encodeObject(onboardingVersion, forKey: "onboardingVersion")
        coder.encodeObject(totalViewsCount, forKey: "totalViewsCount")
        coder.encodeObject(location, forKey: "location")

        // profile
        coder.encodeObject(profile, forKey: "profile")
        super.encode(with: coder.coder)
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

    override class func fromJSON(_ data: [String: AnyObject]) -> JSONAble {
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
        user.avatar = Asset.parseAsset("user_avatar_\(user.id)", node: data["avatar"] as? [String: AnyObject])
        user.identifiableBy = json["identifiable_by"].stringValue
        user.postsCount = json["posts_count"].int
        user.lovesCount = json["loves_count"].int
        user.followersCount = json["followers_count"].stringValue
        user.followingCount = json["following_count"].int
        user.formattedShortBio = json["formatted_short_bio"].string
        // grab links
        if let links = json["external_links_list"].array {
            let externalLinks = links.flatMap({ $0.dictionaryObject as? [String: String] })
            user.externalLinksList = externalLinks.flatMap { ExternalLink.fromDict($0) }
        }
        user.coverImage = Asset.parseAsset("user_cover_image_\(user.id)", node: data["cover_image"] as? [String: AnyObject])
        user.backgroundPosition = json["background_positiion"].stringValue
        if let webOnboardingVersion = json["web_onboarding_version"].string {
            user.onboardingVersion = Int(webOnboardingVersion)
        }
        // links
        user.links = data["links"] as? [String: AnyObject]
        // profile
        if (json["created_at"].stringValue).characters.count > 0 {
            user.profile = Profile.fromJSON(data) as? Profile
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
        return coverImage?.xhdpi?.url as URL?
    }

    func avatarURL(viewsAdultContent: Bool? = false, animated: Bool = false) -> URL? {
        if animated && (!postsAdultContent || viewsAdultContent == true) && avatar?.original?.url.absoluteString.hasSuffix(".gif") == true {
            return avatar?.original?.url as URL?
        }
        return avatar?.largeOrBest?.url as URL?
    }
}

extension User: JSONSaveable {
    var uniqueId: String? { if let id = tableId { return "User-\(id)" } ; return nil }
    var tableId: String? { return id }

}
