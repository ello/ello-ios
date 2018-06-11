////
///  RelationshipPriority.swift
//

class RelationshipPriorityWrapper: NSObject {
    let priority: RelationshipPriority
    init(priority: RelationshipPriority) {
        self.priority = priority
    }
}

enum RelationshipPriority: String {
    case following = "friend"
    case block = "block"
    case mute = "mute"
    case inactive = "inactive"
    case none = "none"
    case null = "null"
    case me = "self"

    static let all = [following, block, mute, inactive, none, null, me]

    init(stringValue: String?) {
        if stringValue == "noise" {
            self = .following
        }
        else if let stringValue = stringValue {
            self = RelationshipPriority(rawValue: stringValue) ?? .none
        }
        else {
            self = .null
        }
    }

    var buttonName: String {
        switch self {
        case .following: return "following"
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
