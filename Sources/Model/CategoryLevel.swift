////
///  CategoryLevel.swift
//

enum CategoryLevel: String, Equatable {
    case meta = "meta"
    case primary = "primary"
    case secondary = "secondary"
    case tertiary = "tertiary"
    case unknown = ""

    var order: Int {
        switch self {
        case .meta: return 0
        case .primary: return 1
        case .secondary: return 2
        case .tertiary: return 3
        case .unknown: return 1_048_576
        }
    }
}

func == (lhs: CategoryLevel, rhs: CategoryLevel) -> Bool {
    return lhs.rawValue == rhs.rawValue
}
