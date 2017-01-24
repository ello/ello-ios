////
///  DiscoverType.swift
//

enum DiscoverType: String {
    case featured = "recommended"
    case trending = "trending"
    case recent = "recent"

    static func fromURL(_ slug: String) -> DiscoverType? {
        switch slug {
        case "featured", "recommended", "":
            return .featured
        case "trending":
            return .trending
        case "recent":
            return .recent
        default:
            return nil
        }
    }

    var slug: String { return rawValue }
    var name: String {
        switch self {
        case .featured: return InterfaceString.Discover.Featured
        case .trending: return InterfaceString.Discover.Trending
        case .recent: return InterfaceString.Discover.Recent
        }
    }
}
