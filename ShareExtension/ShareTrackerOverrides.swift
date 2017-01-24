////
///  ShareTrackerOverrides.swift
//

import Foundation

enum ContentType: String {
    case post = "Post"
    case comment = "Comment"
    case user = "User"
}

func logPresentingAlert(_ name: String) {}

class Tracker {
    static let shared = Tracker()

    init() {}

    static func trackRequest(headers: String, statusCode: Int, responseJSON: String) {}

    func contentFlagged(_ type: ContentType, flag: ContentFlagger.AlertOption, contentId: String) {}
    func contentFlaggingFailed(_ type: ContentType, message: String, contentId: String) {}
    func contentFlaggingCanceled(_ type: ContentType, contentId: String) {}
    func encounteredNetworkError(_ path: String, error: NSError, statusCode: Int?) {}
}

class Window {
    static func isWide(_ width: Float) -> Bool { return false }
    static var width: Float { return 0 }
}
