////
///  MappingType.swift
//

import Foundation

public enum MappingType: String {
    // these keys define the place in the JSON response where the ElloProvider
    // should look for the response data.
    case ActivitiesType = "activities"
    case AmazonCredentialsType = "credentials"
    case AssetsType = "assets"
    case AutoCompleteResultType = "autocomplete_results"
    case AvailabilityType = "availability"
    case CategoriesType = "categories"
    case CommentsType = "comments"
    case DynamicSettingsType = "settings"
    case ErrorType = "error"
    case ErrorsType = "errors"
    case LovesType = "loves"
    case NoContentType = "204"
    case PostsType = "posts"
    case RelationshipsType = "relationships"
    case UsersType = "users"
    case UsernamesType = "usernames"
    case WatchesType = "watches"

    var fromJSON: FromJSONClosure {
        switch self {
        case ActivitiesType:
            return Activity.fromJSON
        case AmazonCredentialsType:
            return AmazonCredentials.fromJSON
        case AssetsType:
            return Asset.fromJSON
        case AutoCompleteResultType:
            return AutoCompleteResult.fromJSON
        case AvailabilityType:
            return Availability.fromJSON
        case CategoriesType:
            return Category.fromJSON
        case CommentsType:
            return ElloComment.fromJSON
        case DynamicSettingsType:
            return DynamicSettingCategory.fromJSON
        case ErrorType:
            return ElloNetworkError.fromJSON
        case ErrorsType:
            return ElloNetworkError.fromJSON
        case LovesType:
            return Love.fromJSON
        case PostsType:
            return Post.fromJSON
        case RelationshipsType:
            return Relationship.fromJSON
        case UsersType:
            return User.fromJSON
        case UsernamesType:
            return Username.fromJSON
        case NoContentType:
            return UnknownJSONAble.fromJSON
        case WatchesType:
            return Watch.fromJSON
        }
    }

    var isOrdered: Bool {
        switch self {
        case AssetsType: return false
        default: return true
        }
    }

}

let UnknownJSONAbleVersion = 1

@objc(UnknownJSONAble)
public class UnknownJSONAble: JSONAble {
    public convenience init() {
        self.init(version: UnknownJSONAbleVersion)
    }

    override class public func fromJSON(data: [String : AnyObject], fromLinked: Bool = false) -> JSONAble {
        return UnknownJSONAble()
    }
}
