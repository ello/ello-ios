////
///  UserParser.swift
//

import SwiftyJSON


class UserParser: IdParser {

    init() {
        super.init(table: .usersType)
        linkObject(.profilesType, "profile")
        linkArray(.categoriesType)
    }

    override func parse(json: JSON) -> User {
        let relationshipPriority = RelationshipPriority(stringValue: json["currentUserState"]["relationshipPriority"].stringValue)
        let user = User(
            id: json["id"].stringValue,
            username: json["username"].stringValue,
            name: json["name"].stringValue,
            relationshipPriority: relationshipPriority,
            postsAdultContent: json["settings"]["postsAdultContent"].boolValue,
            viewsAdultContent: json["settings"]["viewsAdultContent"].boolValue,
            hasCommentingEnabled: json["settings"]["hasCommentingEnabled"].boolValue,
            hasSharingEnabled: json["settings"]["hasSharingEnabled"].boolValue,
            hasRepostingEnabled: json["settings"]["hasRepostingEnabled"].boolValue,
            hasLovesEnabled: json["settings"]["hasLovesEnabled"].boolValue,
            isCollaborateable: json["settings"]["isCollaborateable"].boolValue,
            isHireable: json["settings"]["isHireable"].boolValue
        )

        user.avatar = Asset.parseAsset("user_avatar_\(user.id)", node: json["avatar"].dictionaryObject)
        user.coverImage = Asset.parseAsset("user_cover_image_\(user.id)", node: json["coverImage"].dictionaryObject)

        // user.experimentalFeatures = json["experimental_features"].bool
        // user.identifiableBy = json["identifiable_by"].string
        user.formattedShortBio = json["formattedShortBio"].string
        // user.onboardingVersion = json["web_onboarding_version"].string.flatMap { Int($0) }
        user.totalViewsCount = json["stats"]["totalViewsCount"].int
        user.location = json["location"].string

        if let links = json["externalLinksList"].array {
            let externalLinks = links.flatMap { $0.dictionaryObject as? [String: String] }
            user.externalLinksList = externalLinks.flatMap { ExternalLink.fromDict($0) }
        }

        if let badgeNames: [String] = json["badges"].array?.flatMap({ $0.string }) {
            user.badges = badgeNames
                .flatMap { Badge.lookup(slug: $0) }
        }

        if relationshipPriority == .me, json["profile"].exists() {
            user.profile = ProfileParser().parse(json: json["profile"]) as? Profile
        }

        user.postsCount = json["userStats"]["postsCount"].int
        user.lovesCount = json["userStats"]["lovesCount"].int
        user.followersCount = json["userStats"]["followersCount"].string
        user.followingCount = json["userStats"]["followingCount"].int

        user.links = json["links"].dictionaryObject

        return user
    }
}
