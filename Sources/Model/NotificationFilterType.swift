////
///  NotificationFilterType.swift
//

enum NotificationFilterType: String {
    case all = "NotificationFilterTypeAll"
    case comments = "NotificationFilterTypeComments"
    case mention = "NotificationFilterTypeMention"
    case heart = "NotificationFilterTypeHeart"
    case repost = "NotificationFilterTypeRepost"
    case relationship = "NotificationFilterTypeRelationship"

    var category: String? {
        switch self {
        case .all: return nil
        case .comments: return "comments"
        case .mention: return "mentions"
        case .heart: return "loves"
        case .repost: return "reposts"
        case .relationship: return "relationships"
        }
    }

    static func fromCategory(_ categoryString: String?) -> NotificationFilterType {
        let category = categoryString ?? ""
        switch category {
        case "comments": return .comments
        case "mentions": return .mention
        case "loves": return .heart
        case "reposts": return .repost
        case "relationships": return .relationship
        default: return .all
        }
    }
}
