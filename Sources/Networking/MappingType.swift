////
///  MappingType.swift
//

typealias FromJSONClosure = ([String: Any]) -> Model

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
    case categoryPostsType = "category_posts"
    case categoryUsersType = "category_users"
    case commentsType = "comments"
    case dynamicSettingsType = "settings"
    case editorials = "editorials"
    case errorsType = "errors"
    case errorType = "error"
    case lovesType = "loves"
    case noContentType = "204"
    case pageHeadersType = "page_headers"
    case postsType = "posts"
    case profilesType = "profiles"
    case relationshipsType = "relationships"
    case usernamesType = "usernames"
    case usersType = "users"
    case watchesType = "watches"

    var pluralKey: String {
        switch self {
        case .artistInvitesType:           return "artistInvites"
        case .artistInviteSubmissionsType: return "artistInviteSubmissions"
        case .autoCompleteResultType:      return "autocompleteResults"
        case .availabilityType:            return "availabilities"
        case .categoryPostsType:           return "categoryPosts"
        case .categoryUsersType:           return "categoryUsers"
        case .errorType:                   return "errors"
        case .pageHeadersType:             return "pageHeaders"
        default: return rawValue
        }
    }

    var singularKey: String {
        switch self {
        case .activitiesType:              return "activity"
        case .amazonCredentialsType:       return "credentials"
        case .announcementsType:           return "announcement"
        case .artistInvitesType:           return "artistInvite"
        case .artistInviteSubmissionsType: return "artistInviteSubmission"
        case .assetsType:                  return "asset"
        case .autoCompleteResultType:      return "autocompleteResult"
        case .availabilityType:            return "availability"
        case .categoriesType:              return "category"
        case .categoryPostsType:           return "categoryPost"
        case .categoryUsersType:           return "categoryUser"
        case .commentsType:                return "comment"
        case .dynamicSettingsType:         return "setting"
        case .editorials:                  return "editorial"
        case .errorsType, .errorType:      return "error"
        case .lovesType:                   return "love"
        case .noContentType:               return "204"
        case .pageHeadersType:             return "pageHeader"
        case .postsType:                   return "post"
        case .profilesType:                return "profile"
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
        case .categoryPostsType:           return CategoryPost.fromJSON
        case .categoryUsersType:           return CategoryUser.fromJSON
        case .commentsType:                return ElloComment.fromJSON
        case .dynamicSettingsType:         return DynamicSettingCategory.fromJSON
        case .editorials:                  return Editorial.fromJSON
        case .errorsType, .errorType:      return ElloNetworkError.fromJSON
        case .lovesType:                   return Love.fromJSON
        case .noContentType:               return nil
        case .pageHeadersType:             return nil
        case .postsType:                   return Post.fromJSON
        case .profilesType:                return Profile.fromJSON
        case .relationshipsType:           return Relationship.fromJSON
        case .usernamesType:               return Username.fromJSON
        case .usersType:                   return User.fromJSON
        case .watchesType:                 return Watch.fromJSON
        }
    }
}

extension MappingType {
    var parser: Parser? {
        switch self {
        // case .artistInvitesType:           return ArtistInviteParser()
        // case .artistInviteSubmissionsType: return ArtistInviteSubmissionParser()
        // case .lovesType:                   return LoveParser()
        // case .profilesType:                return ProfileParser()
        // case .watchesType:                 return WatchParser()
        case .assetsType:                  return AssetParser()
        case .categoriesType:              return CategoryParser()
        case .categoryPostsType:           return CategoryPostParser()
        case .categoryUsersType:           return CategoryUserParser()
        case .commentsType:                return CommentParser()
        case .postsType:                   return PostParser()
        case .usersType:                   return UserParser()
        default:
            return nil
        }
    }
}

let UnknownModelVersion = 1

@objc(UnknownModel)
class UnknownModel: Model {
    convenience init() {
        self.init(version: UnknownModelVersion)
    }

    class func fromJSON(_ data: [String: Any]) -> UnknownModel {
        return UnknownModel()
    }
}
