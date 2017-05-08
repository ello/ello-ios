////
///  StreamKind.swift
//

import SwiftyUserDefaults


enum StreamKind {
    case currentUserStream
    case allCategories
    case announcements
    case discover(type: DiscoverType)
    case editorials
    case following
    case notifications(category: String?)
    case postDetail(postParam: String)
    case simpleStream(endpoint: ElloAPI, title: String)
    case unknown
    case userStream(userParam: String)
    case category(slug: String)

    var name: String {
        switch self {
        case .currentUserStream: return InterfaceString.Profile.Title
        case .allCategories: return InterfaceString.Discover.AllCategories
        case .announcements: return ""
        case .discover: return InterfaceString.Discover.Title
        case .editorials: return InterfaceString.Editorials.Title
        case .following: return InterfaceString.FollowingStream.Title
        case .notifications: return InterfaceString.Notifications.Title
        case .category: return ""
        case .postDetail: return ""
        case let .simpleStream(_, title): return title
        case .unknown: return ""
        case .userStream: return ""
        }
    }

    var cacheKey: String {
        switch self {
        case .currentUserStream: return "Profile"
        case .allCategories: return "AllCategories"
        case .announcements: return "Announcements"
        case .discover, .category: return "CategoryPosts"
        case .editorials: return "Editorials"
        case .following: return "Following"
        case .notifications: return "Notifications"
        case .postDetail: return "PostDetail"
        case .unknown: return "unknown"
        case .userStream:
            return "UserStream"
        case let .simpleStream(endpoint, title):
            switch endpoint {
            case .searchForPosts:
                return "SearchForPosts"
            default:
                return "SimpleStream.\(title)"
            }
        }
    }

    var lastViewedCreatedAtKey: String? {
        switch self {
        case .announcements: return "Announcements_createdAt"
        case .editorials: return "Editorials_createdAt"
        case let .discover(type): return "Discover_\(type)_createdAt"
        case let .category(slug): return "Category_\(slug)_createdAt"
        case .following: return "Following_createdAt"
        case .notifications: return "Notifications_createdAt"
        default:
            return nil
        }
    }

    var columnSpacing: CGFloat {
        switch self {
        case .allCategories: return 2
        default: return 12
        }
    }

    var showsCategory: Bool {
        if case let .discover(type) = self, type == .featured {
            return true
        }
        return false
    }

    var isProfileStream: Bool {
        switch self {
        case .currentUserStream, .userStream: return true
        default: return false
        }
    }

    var endpoint: ElloAPI {
        switch self {
        case .currentUserStream: return .currentUserStream
        case .allCategories: return .categories
        case .announcements: return .announcements
        case let .category(slug): return .category(slug: slug)
        case let .discover(type): return .discover(type: type)
        case .editorials: return .editorials
        case .following: return .following
        case let .notifications(category): return .notificationsStream(category: category)
        case let .postDetail(postParam): return .postDetail(postParam: postParam, commentCount: 10)
        case let .simpleStream(endpoint, _): return endpoint
        case .unknown: return .notificationsStream(category: nil) // doesn't really get used
        case let .userStream(userParam): return .userStream(userParam: userParam)
        }
    }

    var relationship: RelationshipPriority {
        switch self {
        case .following: return .following
        default: return .null
        }
    }

    func filter(_ jsonables: [JSONAble], viewsAdultContent: Bool) -> [JSONAble] {
        switch self {
        case let .simpleStream(endpoint, _):
            switch endpoint {
            case .loves:
                if let loves = jsonables as? [Love] {
                    return loves.reduce([]) { accum, love in
                        if let post = love.post {
                            return accum + [post]
                        }
                        return accum
                    }
                }
                else {
                    return []
                }
            default:
                return jsonables
            }
        case .announcements, .editorials:
            return jsonables
        case .discover, .category:
            if let comments = jsonables as? [ElloComment]  {
                return comments
            }
            else if let posts = jsonables as? [Post]  {
                return posts
            }
            else {
                return []
            }
        case .notifications:
            if let activities = jsonables as? [Activity] {
                let notifications: [Notification] = activities.map { return Notification(activity: $0) }
                return notifications.filter { return $0.isValidKind }
            }
            else {
                return []
            }
        default:
            if let jsonables = jsonables as? [ElloComment] {
                return jsonables
            }
            else if let jsonables = jsonables as? [Post] {
                return jsonables
            }
            else if let jsonables = jsonables as? [User] {
                return jsonables
            }
        }
        return []
    }

    func setIsGridView(_ isGridView: Bool) {
        GroupDefaults["\(cacheKey)GridViewPreferenceSet"] = true
        GroupDefaults["\(cacheKey)IsGridView"] = isGridView
    }

    var isGridView: Bool {
        var defaultGrid: Bool
        switch self {
        case .allCategories: defaultGrid = true
        default: defaultGrid = false
        }
        return GroupDefaults["\(cacheKey)IsGridView"].bool ?? defaultGrid
    }

    var hasGridViewToggle: Bool {
        switch self {
        case .following, .discover, .category: return true
        case let .simpleStream(endpoint, _):
            switch endpoint {
            case .searchForPosts, .loves, .categoryPosts:
                return true
            default:
                return false
            }
        default: return false
        }
    }

    func isDetail(post: Post) -> Bool {
        switch self {
        case let .postDetail(postParam): return postParam == post.id || postParam == post.token
        default: return false
        }
    }

    var supportsLargeImages: Bool {
        switch self {
        case .postDetail: return true
        default: return false
        }
    }
}
