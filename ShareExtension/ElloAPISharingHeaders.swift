////
///  ElloAPISharingHeaders.swift
//

extension ElloAPI {
    var sharingHeaders: [String: String]? {
        switch self {
        case .createPost:
            return ["X-Segment-Event": "share-event"]
        default:
            return nil
        }
    }
}
