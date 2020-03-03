////
///  StreamKind.swift
//

import SwiftyUserDefaults


enum StreamKind {
    case announcements
    case category(Category.Selection, CategoryFilter)
    case onboardingCategories
    case manageCategories
    case chooseCategory
    case editorials
    case following
    case notifications(category: String?)
    case postDetail(postParam: String)
    case simpleStream(endpoint: ElloAPI, title: String)
    case userLoves(username: String)
    case userFollowing(username: String)
    case userFollowers(username: String)
    case userStream(userParam: String)
    case artistInvites
    case artistInviteSubmissions
    case unknown

    var name: String {
        switch self {
        case .announcements: return ""
        case .category: return ""
        case .onboardingCategories, .manageCategories, .chooseCategory:
            return InterfaceString.Discover.Categories
        case .editorials: return InterfaceString.Editorials.Title
        case .following: return InterfaceString.Following.Title
        case .notifications: return InterfaceString.Notifications.Title
        case .artistInvites: return InterfaceString.ArtistInvites.Title
        case .artistInviteSubmissions: return ""
        case .postDetail: return ""
        case let .simpleStream(_, title): return title
        case .userLoves: return InterfaceString.Loves.Title
        case .userFollowing: return InterfaceString.Following.Title
        case .userFollowers: return InterfaceString.Followers.Title
        case .unknown: return ""
        case .userStream: return ""
        }
    }

    var cacheKey: String {
        switch self {
        case .artistInvites: return "ArtistInvites"
        case .artistInviteSubmissions: return "ArtistInviteSubmissions"
        case .category: return "Category"
        case .onboardingCategories: return "AllCategories"
        case .manageCategories: return "ManageCategories"
        case .chooseCategory: return "ChooseCategory"
        case .announcements: return "Announcements"
        case .editorials: return "Editorials"
        case .following: return "Following"
        case .notifications: return "Notifications"
        case .postDetail: return "PostDetail"
        case .unknown: return "unknown"
        case .userLoves: return "UserLoves"
        case .userFollowing: return "UserFollowing"
        case .userFollowers: return "UserFollowers"
        case .userStream: return "UserStream"
        case let .simpleStream(endpoint, title):
            switch endpoint {
            case .searchForPosts:
                return "SearchForPosts"
            case .searchForUsers:
                return "SearchForUsers"
            default:
                return "SimpleStream.\(title)"
            }
        }
    }

    var lastViewedCreatedAtKey: String? {
        switch self {
        case .announcements: return "Announcements_createdAt"
        case .editorials: return "Editorials_createdAt"
        case .following: return "Following_createdAt"
        case .notifications: return "Notifications_createdAt"
        default:
            return nil
        }
    }

    var horizontalColumnSpacing: CGFloat {
        switch self {
        case .onboardingCategories: return CategoryCardCell.Size.smallMargin
        case .manageCategories, .chooseCategory: return CategoryCardCell.Size.cardMargins
        default: return 12
        }
    }

    var layoutInsets: UIEdgeInsets {
        switch self {
        case .manageCategories, .chooseCategory:
            return UIEdgeInsets(sides: CategoryCardCell.Size.cardMargins)
        default: return .zero
        }
    }

    var showsSubmission: Bool {
        switch self {
        case .following, .category: return true
        default: return false
        }
    }
    var showsCategory: Bool {
        switch self {
        case let .category(selection, _):
            switch selection {
            case .all, .subscribed: return true
            case .category: return false
            }
        default:
            return false
        }
    }

    var isProfileStream: Bool {
        switch self {
        case .userStream: return true
        default: return false
        }
    }

    var showsCurationTool: Bool {
        switch self {
        case let .category(selection, _):
            switch selection {
            case .category: return true
            default: return false
            }
        case .postDetail:
            return true
        default: return false
        }
    }

    var endpoint: ElloAPI? {
        switch self {
        case .announcements: return .announcements
        case .category, .onboardingCategories, .manageCategories, .chooseCategory:
            return .categories
        case .editorials: return .editorials
        case .artistInvites: return .artistInvites
        case .artistInviteSubmissions: return .artistInviteSubmissions
        case .following: return .following
        case let .notifications(category): return .notificationsStream(category: category)
        case let .postDetail(postParam): return .postDetail(postParam: postParam)
        case let .simpleStream(endpoint, _): return endpoint
        case let .userStream(userParam): return .userStream(userParam: userParam)
        case .userLoves,
            .userFollowing,
            .userFollowers,
            .unknown:
            return nil
        }
    }

    func filter(_ jsonables: [Model], viewsAdultContent: Bool) -> [Model] {
        switch self {
        case .editorials:
            return jsonables.compactMap { jsonable -> Editorial? in
                guard
                    let editorial = jsonable as? Editorial,
                    editorial.kind != .unknown
                else { return nil }
                return editorial
            }
        case .notifications:
            if let activities = jsonables as? [Activity] {
                let notifications: [Notification] = activities.map {
                    return Notification(activity: $0)
                }
                return notifications.filter { return $0.isValidKind }
            }
            else {
                return []
            }
        default:
            return jsonables
        }
    }

    func setIsGridView(_ isGridView: Bool) {
        GroupDefaults["\(cacheKey)GridViewPreferenceSet"] = true
        GroupDefaults["\(cacheKey)IsGridView"] = isGridView
    }

    var isGridView: Bool {
        var defaultGrid: Bool
        switch self {
        case .category, .onboardingCategories, .manageCategories, .chooseCategory:
            defaultGrid = true
        default: defaultGrid = false
        }
        return GroupDefaults["\(cacheKey)IsGridView"].bool ?? defaultGrid
    }

    var hasGridViewToggle: Bool {
        switch self {
        case .following,
            .category,
            .userLoves:
            return true
        case let .simpleStream(endpoint, _):
            switch endpoint {
            case .searchForPosts, .categoryPosts:
                return true
            default:
                return false
            }
        default: return false
        }
    }

    func isDetail(post: Post) -> Bool {
        switch self {
        case let .postDetail(postParam):
            return postParam == post.id || postParam == "~\(post.token)"
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
