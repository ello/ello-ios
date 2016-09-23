////
///  CrashlyticsKey.swift
//

import Foundation

public enum CrashlyticsKey: String {
    case AlertPresenter = "alert presenting controller"
    case RequestPath = "most recent request path"
    case ResponseHeaders = "most recent response headers"
    case ResponseJSON = "most recent response json"
    case ResponseStatusCode = "most recent response status code"
    case StreamName = "current stream name"
    // model fromJSON chunks
    case ActivityFromJSON = "activity from json"
    case AmazonCredentialsFromJSON = "amazon credentials from json"
    case AssetFromJSON = "asset from json"
    case AttachmentFromJSON = "attachment from json"
    case AutoCompleteResultFromJSON = "auto complete result from json"
    case AvailabilityFromJSON = "availability from json"
    case CommentFromJSON = "comment from json"
    case DynamicSettingFromJSON = "dynamic setting from json"
    case DynamicSettingCategoryFromJSON = "dynamic setting category from json"
    case ElloNetworkErrorFromJSON = "ello network error from json"
    case EmbedRegionFromJSON = "embed region from json"
    case ImageRegionFromJSON = "image region from json"
    case LoveFromJSON = "love from json"
    case PostFromJSON = "post from json"
    case ProfileFromJSON = "profile from json"
    case RelationshipFromJSON = "relationship from json"
    case TextRegionFromJSON = "text region from json"
    case UserFromJSON = "user from json"
    case WatchFromJSON = "watch from json"
}
