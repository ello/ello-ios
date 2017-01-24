////
///  RelationshipPriority.swift
//


enum RelationshipPriority: String {
    case following = "friend"
    case starred = "noise"
    case block = "block"
    case mute = "mute"
    case inactive = "inactive"
    case none = "none"
    case null = "null"
    case me = "self"

    static let all = [following, starred, block, mute, inactive, none, null, me]

    init(stringValue: String) {
        self = RelationshipPriority(rawValue: stringValue) ?? .none
    }

    var buttonName: String {
        switch self {
        case .following: return "following"
        case .starred: return "starred"
        default: return self.rawValue
        }
    }

    var isMutedOrBlocked: Bool {
        switch self {
        case .mute, .block: return true
        default: return false
        }
    }
}
