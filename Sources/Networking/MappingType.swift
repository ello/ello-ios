////
///  MappingType.swift
//

typealias FromJSONClosure = ([String: Any]) -> JSONAble

enum MappingType: String {
    // these keys define the place in the JSON response where the ElloProvider
    // should look for the response data.
    case activitiesType = "activities"
    case amazonCredentialsType = "credentials"
    case announcementsType = "announcements"
    case artistInvitesType = "artist_invites"
    case artistInviteSubmissionsType = "artist_invite_submissions"
    case assetsType = "assets"
    case autoCompleteResultType = "autocomplete_results"
    case availabilityType = "availability"
    case categoriesType = "categories"
    case commentsType = "comments"
    case dynamicSettingsType = "settings"
    case editorials = "editorials"
    case errorsType = "errors"
    case errorType = "error"
    case lovesType = "loves"
    case noContentType = "204"
    case pagePromotionalsType = "page_promotionals"
    case postsType = "posts"
    case profilesType = "profiles"
    case promotionalsType = "promotionals"
    case relationshipsType = "relationships"
    case usernamesType = "usernames"
    case usersType = "users"
    case watchesType = "watches"

    var pluralKey: String {
        switch self {
        case .availabilityType: return "availabilities"
        case .errorType: return "errors"
        default: return rawValue
        }
    }

    var singularKey: String {
        switch self {
        case .activitiesType:              return "activity"
        case .amazonCredentialsType:       return "credentials"
        case .announcementsType:           return "announcement"
        case .artistInvitesType:           return "artist_invite"
        case .artistInviteSubmissionsType: return "artist_invite_submission"
        case .assetsType:                  return "asset"
        case .autoCompleteResultType:      return "autocomplete_result"
        case .availabilityType:            return "availability"
        case .categoriesType:              return "category"
        case .commentsType:                return "comment"
        case .dynamicSettingsType:         return "setting"
        case .editorials:                  return "editorial"
        case .errorsType, .errorType:      return "error"
        case .lovesType:                   return "love"
        case .noContentType:               return "204"
        case .pagePromotionalsType:        return "page_promotional"
        case .postsType:                   return "post"
        case .profilesType:                return "profile"
        case .promotionalsType:            return "promotional"
        case .relationshipsType:           return "relationship"
        case .usernamesType:               return "username"
        case .usersType:                   return "user"
        case .watchesType:                 return "watch"
        }
    }

    var fromJSON: FromJSONClosure? {
        switch self {
        case .activitiesType:              return Activity.fromJSON
        case .amazonCredentialsType:       return AmazonCredentials.fromJSON
        case .announcementsType:           return Announcement.fromJSON
        case .artistInvitesType:           return ArtistInvite.fromJSON
        case .artistInviteSubmissionsType: return ArtistInviteSubmission.fromJSON
        case .assetsType:                  return Asset.fromJSON
        case .autoCompleteResultType:      return AutoCompleteResult.fromJSON
        case .availabilityType:            return Availability.fromJSON
        case .categoriesType:              return Category.fromJSON
        case .commentsType:                return ElloComment.fromJSON
        case .dynamicSettingsType:         return DynamicSettingCategory.fromJSON
        case .editorials:                  return Editorial.fromJSON
        case .errorsType, .errorType:      return ElloNetworkError.fromJSON
        case .lovesType:                   return Love.fromJSON
        case .noContentType:               return nil
        case .pagePromotionalsType:        return PagePromotional.fromJSON
        case .postsType:                   return Post.fromJSON
        case .profilesType:                return Profile.fromJSON
        case .promotionalsType:            return Promotional.fromJSON
        case .relationshipsType:           return Relationship.fromJSON
        case .usernamesType:               return Username.fromJSON
        case .usersType:                   return User.fromJSON
        case .watchesType:                 return Watch.fromJSON
        }
    }
}

extension MappingType {
    func parser() -> Parser? {
        switch self {
        case .assetsType:                  return AssetParser()
        case .artistInvitesType:           return ArtistInviteParser()
        case .artistInviteSubmissionsType: return ArtistInviteSubmissionParser()
        case .categoriesType:              return CategoryParser()
        case .commentsType:                return CommentParser()
        case .lovesType:                   return LoveParser()
        case .postsType:                   return PostParser()
        case .profilesType:                return ProfileParser()
        case .usersType:                   return UserParser()
        case .watchesType:                 return WatchParser()
        default:
            return nil
        }
    }
}

let UnknownJSONAbleVersion = 1

@objc(UnknownJSONAble)
class UnknownJSONAble: JSONAble {
    convenience init() {
        self.init(version: UnknownJSONAbleVersion)
    }

    class func fromJSON(_ data: [String: Any]) -> UnknownJSONAble {
        return UnknownJSONAble()
    }
}
