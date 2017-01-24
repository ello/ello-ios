////
///  MappingType.swift
//

import Foundation

enum MappingType: String {
    // these keys define the place in the JSON response where the ElloProvider
    // should look for the response data.
    case announcementsType = "announcements"
    case activitiesType = "activities"
    case amazonCredentialsType = "credentials"
    case assetsType = "assets"
    case autoCompleteResultType = "autocomplete_results"
    case availabilityType = "availability"
    case categoriesType = "categories"
    case commentsType = "comments"
    case dynamicSettingsType = "settings"
    case errorType = "error"
    case errorsType = "errors"
    case lovesType = "loves"
    case noContentType = "204"
    case postsType = "posts"
    case promotionalsType = "promotionals"
    case pagePromotionalsType = "page_promotionals"
    case relationshipsType = "relationships"
    case usersType = "users"
    case usernamesType = "usernames"
    case watchesType = "watches"

    var fromJSON: FromJSONClosure {
        switch self {
        case .announcementsType:
            return Announcement.fromJSON
        case .activitiesType:
            return Activity.fromJSON
        case .amazonCredentialsType:
            return AmazonCredentials.fromJSON
        case .assetsType:
            return Asset.fromJSON
        case .autoCompleteResultType:
            return AutoCompleteResult.fromJSON
        case .availabilityType:
            return Availability.fromJSON
        case .categoriesType:
            return Category.fromJSON
        case .commentsType:
            return ElloComment.fromJSON
        case .dynamicSettingsType:
            return DynamicSettingCategory.fromJSON
        case .errorType:
            return ElloNetworkError.fromJSON
        case .errorsType:
            return ElloNetworkError.fromJSON
        case .lovesType:
            return Love.fromJSON
        case .postsType:
            return Post.fromJSON
        case .pagePromotionalsType:
            return PagePromotional.fromJSON
        case .promotionalsType:
            return Promotional.fromJSON
        case .relationshipsType:
            return Relationship.fromJSON
        case .usersType:
            return User.fromJSON
        case .usernamesType:
            return Username.fromJSON
        case .noContentType:
            return UnknownJSONAble.fromJSON
        case .watchesType:
            return Watch.fromJSON
        }
    }

    var isOrdered: Bool {
        switch self {
        case .assetsType: return false
        default: return true
        }
    }

}

let UnknownJSONAbleVersion = 1

@objc(UnknownJSONAble)
class UnknownJSONAble: JSONAble {
    convenience init() {
        self.init(version: UnknownJSONAbleVersion)
    }

    override class func fromJSON(_ data: [String : AnyObject]) -> JSONAble {
        return UnknownJSONAble()
    }
}
