////
///  User.swift
//

import Crashlytics
import SwiftyJSON

// version 1: initial
// version 2: added isHireable
// version 3: added notifyOfWatchesViaPush, notifyOfWatchesViaEmail
// version 4: added notifyOfCommentsOnPostWatchViaPush, notifyOfCommentsOnPostWatchViaEmail
let UserVersion: Int = 4

@objc(User)
public final class User: JSONAble {

    // active record
    public let id: String
    // required
    public let href: String
    public let username: String
    public let name: String
    public var displayName: String {
        if name.isEmpty {
            return atName
        }
        return name
    }
    public let experimentalFeatures: Bool
    public var relationshipPriority: RelationshipPriority
    public let postsAdultContent: Bool
    public let viewsAdultContent: Bool
    public var hasCommentingEnabled: Bool
    public var hasSharingEnabled: Bool
    public var hasRepostingEnabled: Bool
    public var hasLovesEnabled: Bool
    public var notifyOfWatchesViaPush: Bool
    public var notifyOfWatchesViaEmail: Bool
    public var notifyOfCommentsOnPostWatchViaPush: Bool
    public var notifyOfCommentsOnPostWatchViaEmail: Bool
    public var isHireable: Bool
    // optional
    public var avatar: Asset? // required, but kinda optional due to it being nested in json
    public var identifiableBy: String?
    public var postsCount: Int?
    public var lovesCount: Int?
    public var followersCount: String? // string due to this returning "∞" for the ello user
    public var followingCount: Int?
    public var formattedShortBio: String?
    public var externalLinksList: [[String: String]]?
    public var coverImage: Asset?
    public var backgroundPosition: String?
    public var onboardingVersion: Int?
    // links
    public var posts: [Post]? { return getLinkArray("posts") as? [Post] }
    public var mostRecentPost: Post? { return getLinkObject("most_recent_post") as? Post }
    // computed
    public var atName: String { return "@\(username)"}
    public var isCurrentUser: Bool { return self.profile != nil }
    public var headerHTMLContent: String {
        var htmlContent = formattedShortBio ?? ""
        if let links = externalLinksList {
            htmlContent += "<p class='user-links'>"
            for link in links {
                if let url = link["url"], text = link["text"] {
                    htmlContent += "<a href='\(url)'>\(text)</a> "
                }
            }
            htmlContent += "</p>"
        }
        return htmlContent
    }
    // profile
    public var profile: Profile?

    public var shareLink: String? {
        get {
            return "\(ElloURI.baseURL)/\(username)"
        }
    }

    public init(id: String,
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
        notifyOfWatchesViaPush: Bool,
        notifyOfWatchesViaEmail: Bool,
        notifyOfCommentsOnPostWatchViaPush: Bool,
        notifyOfCommentsOnPostWatchViaEmail: Bool,
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
        self.isHireable = isHireable
        self.notifyOfWatchesViaPush = notifyOfWatchesViaPush
        self.notifyOfWatchesViaEmail = notifyOfWatchesViaEmail
        self.notifyOfCommentsOnPostWatchViaPush = notifyOfCommentsOnPostWatchViaPush
        self.notifyOfCommentsOnPostWatchViaEmail = notifyOfCommentsOnPostWatchViaEmail
        super.init(version: UserVersion)
    }

// MARK: NSCoding

    public required init(coder aDecoder: NSCoder) {
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
        if version == 1 {
            self.isHireable = false
            self.notifyOfWatchesViaPush = true
            self.notifyOfWatchesViaEmail = true
            self.notifyOfCommentsOnPostWatchViaPush = true
            self.notifyOfCommentsOnPostWatchViaEmail = true
        }
        else if version == 2 {
            self.isHireable = decoder.decodeKey("isHireable")
            self.notifyOfWatchesViaPush = true
            self.notifyOfWatchesViaEmail = true
            self.notifyOfCommentsOnPostWatchViaPush = true
            self.notifyOfCommentsOnPostWatchViaEmail = true
        }
        else if version == 3 {
            self.isHireable = decoder.decodeKey("isHireable")
            self.notifyOfWatchesViaPush = decoder.decodeKey("notifyOfWatchesViaPush")
            self.notifyOfWatchesViaEmail = decoder.decodeKey("notifyOfWatchesViaEmail")
            self.notifyOfCommentsOnPostWatchViaPush = true
            self.notifyOfCommentsOnPostWatchViaEmail = true
        }
        else {
            self.isHireable = decoder.decodeKey("isHireable")
            self.notifyOfWatchesViaPush = decoder.decodeKey("notifyOfWatchesViaPush")
            self.notifyOfWatchesViaEmail = decoder.decodeKey("notifyOfWatchesViaEmail")
            self.notifyOfCommentsOnPostWatchViaPush = decoder.decodeKey("notifyOfCommentsOnPostWatchViaPush")
            self.notifyOfCommentsOnPostWatchViaEmail = decoder.decodeKey("notifyOfCommentsOnPostWatchViaEmail")
        }
        // optional
        self.avatar = decoder.decodeOptionalKey("avatar")
        self.identifiableBy = decoder.decodeOptionalKey("identifiableBy")
        self.postsCount = decoder.decodeOptionalKey("postsCount")
        self.lovesCount = decoder.decodeOptionalKey("lovesCount")
        self.followersCount = decoder.decodeOptionalKey("followersCount")
        self.followingCount = decoder.decodeOptionalKey("followingCount")
        self.formattedShortBio = decoder.decodeOptionalKey("formattedShortBio")
        self.externalLinksList = decoder.decodeOptionalKey("externalLinksList")
        self.coverImage = decoder.decodeOptionalKey("coverImage")
        self.backgroundPosition = decoder.decodeOptionalKey("backgroundPosition")
        self.onboardingVersion = decoder.decodeOptionalKey("onboardingVersion")
        // profile
        self.profile = decoder.decodeOptionalKey("profile")
        super.init(coder: decoder.coder)
    }

    class func empty(id id: String = NSUUID().UUIDString) -> User {
        return User(
            id: id,
            href: "",
            username: "",
            name: "",
            experimentalFeatures: false,
            relationshipPriority: RelationshipPriority.None,
            postsAdultContent: false,
            viewsAdultContent: false,
            hasCommentingEnabled: true,
            hasSharingEnabled: true,
            hasRepostingEnabled: true,
            hasLovesEnabled: true,
            notifyOfWatchesViaPush: true,
            notifyOfWatchesViaEmail: true,
            notifyOfCommentsOnPostWatchViaPush: true,
            notifyOfCommentsOnPostWatchViaEmail: true,
            isHireable: false)
    }

    public override func encodeWithCoder(encoder: NSCoder) {
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
        coder.encodeObject(notifyOfWatchesViaPush, forKey: "notifyOfWatchesViaPush")
        coder.encodeObject(notifyOfWatchesViaEmail, forKey: "notifyOfWatchesViaEmail")
        coder.encodeObject(notifyOfCommentsOnPostWatchViaPush, forKey: "notifyOfCommentsOnPostWatchViaPush")
        coder.encodeObject(notifyOfCommentsOnPostWatchViaEmail, forKey: "notifyOfCommentsOnPostWatchViaEmail")
        coder.encodeObject(isHireable, forKey: "isHireable")
        // optional
        coder.encodeObject(avatar, forKey: "avatar")
        coder.encodeObject(identifiableBy, forKey: "identifiableBy")
        coder.encodeObject(postsCount, forKey: "postsCount")
        coder.encodeObject(lovesCount, forKey: "lovesCount")
        coder.encodeObject(followingCount, forKey: "followingCount")
        coder.encodeObject(followersCount, forKey: "followersCount")
        coder.encodeObject(formattedShortBio, forKey: "formattedShortBio")
        coder.encodeObject(externalLinksList, forKey: "externalLinksList")
        coder.encodeObject(coverImage, forKey: "coverImage")
        coder.encodeObject(backgroundPosition, forKey: "backgroundPosition")
        coder.encodeObject(onboardingVersion, forKey: "onboardingVersion")
        // profile
        coder.encodeObject(profile, forKey: "profile")
        super.encodeWithCoder(coder.coder)
    }

// MARK: JSONAble

    public override func merge(other: JSONAble) -> JSONAble {
        if let otherUser = other as? User {
            if (otherUser.formattedShortBio ?? "").characters.count == 0 {
                otherUser.formattedShortBio = formattedShortBio
                otherUser.externalLinksList = externalLinksList
            }
            return otherUser
        }
        return other
    }

    override public class func fromJSON(data: [String: AnyObject], fromLinked: Bool = false) -> JSONAble {
        let json = JSON(data)
        Crashlytics.sharedInstance().setObjectValue(json.rawString(), forKey: CrashlyticsKey.UserFromJSON.rawValue)
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
            notifyOfWatchesViaPush: json["notify_of_watches_via_push"].boolOr(true),
            notifyOfWatchesViaEmail: json["notify_of_watches_via_email"].boolOr(true),
            notifyOfCommentsOnPostWatchViaPush: json["notify_of_comments_on_post_watch_via_push"].boolOr(true),
            notifyOfCommentsOnPostWatchViaEmail: json["notify_of_comments_on_post_watch_via_email"].boolOr(true),
            isHireable: json["is_hireable"].boolValue
        )

        // optional
        user.avatar = Asset.parseAsset("user_avatar_\(user.id)", node: data["avatar"] as? [String: AnyObject])
        user.identifiableBy = json["identifiable_by"].stringValue
        user.postsCount = json["posts_count"].int
        user.lovesCount = json["loves_count"].int
        user.followersCount = json["followers_count"].stringValue
        user.followingCount = json["following_count"].int
        user.formattedShortBio = json["formatted_short_bio"].stringValue
        // grab links
        user.externalLinksList = json["external_links_list"].arrayValue.map { ["text": $0["text"].stringValue, "url": $0["url"].stringValue] }
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
        // store self in collection
        if !fromLinked {
            ElloLinkedStore.sharedInstance.setObject(user, forKey: user.id, inCollection: MappingType.UsersType.rawValue)
        }
        return user
    }
}

extension User {

    func hasProperty(key: String) -> Bool {
        if respondsToSelector(Selector(key.camelCase)) {
            return true
        } else if profile?.respondsToSelector(Selector(key.camelCase)) == true {
            return true
        }
        return false
    }

    func propertyForSettingsKey(key: String) -> Bool {
        let kvo = key.camelCase
        let selector = Selector(kvo)
        let value: Bool?
        if profile?.respondsToSelector(selector) == true {
            value = profile?.valueForKey(kvo) as? Bool
        } else if respondsToSelector(selector) {
            value = valueForKey(kvo) as? Bool
        }
        else {
            value = false
        }
        return value ?? false
    }

    func setPropertyForSettingsKey(key: String, value: Bool) {
        let kvo = key.camelCase
        let selector = Selector(kvo)
        if profile?.respondsToSelector(selector) == true {
            profile?.setValue(value, forKey: kvo)
        } else if respondsToSelector(selector) {
            setValue(value, forKey: kvo)
        }
    }
}

extension User {
    func isOwnPost(post: Post) -> Bool {
        return id == post.authorId
    }

    func isOwnComment(comment: ElloComment) -> Bool {
        return id == comment.authorId
    }

    func isOwnParentPost(comment: ElloComment) -> Bool {
        return id == comment.loadedFromPost?.authorId || id == comment.loadedFromPost?.repostAuthor?.id
    }
}

extension User {
    public func coverImageURL(viewsAdultContent viewsAdultContent: Bool? = false, animated: Bool = false) -> NSURL? {
        if animated && (!postsAdultContent || viewsAdultContent == true) && coverImage?.original?.url.absoluteString?.endsWith(".gif") == true {
            return coverImage?.original?.url
        }
        return coverImage?.xhdpi?.url
    }

    public func avatarURL(viewsAdultContent viewsAdultContent: Bool? = false, animated: Bool = false) -> NSURL? {
        if animated && (!postsAdultContent || viewsAdultContent == true) && avatar?.original?.url.absoluteString?.endsWith(".gif") == true {
            return avatar?.original?.url
        }
        return avatar?.largeOrBest?.url
    }
}
