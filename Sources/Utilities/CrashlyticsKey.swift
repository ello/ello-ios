////
///  CrashlyticsKey.swift
//

import Foundation

enum CrashlyticsKey: String {
    case alertPresenter = "alert presenting controller"
    case requestPath = "most recent request path"
    case responseHeaders = "most recent response headers"
    case responseJSON = "most recent response json"
    case responseStatusCode = "most recent response status code"
    case streamName = "current stream name"
    // model fromJSON chunks
    case activityFromJSON = "activity from json"
    case amazonCredentialsFromJSON = "amazon credentials from json"
    case assetFromJSON = "asset from json"
    case attachmentFromJSON = "attachment from json"
    case autoCompleteResultFromJSON = "auto complete result from json"
    case availabilityFromJSON = "availability from json"
    case commentFromJSON = "comment from json"
    case dynamicSettingFromJSON = "dynamic setting from json"
    case dynamicSettingCategoryFromJSON = "dynamic setting category from json"
    case elloNetworkErrorFromJSON = "ello network error from json"
    case embedRegionFromJSON = "embed region from json"
    case imageRegionFromJSON = "image region from json"
    case loveFromJSON = "love from json"
    case postFromJSON = "post from json"
    case profileFromJSON = "profile from json"
    case relationshipFromJSON = "relationship from json"
    case textRegionFromJSON = "text region from json"
    case userFromJSON = "user from json"
    case watchFromJSON = "watch from json"
}
