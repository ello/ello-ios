////
///  StreamKind.swift
//

import Foundation
import SwiftyUserDefaults

public enum StreamKind {
    case CurrentUserStream
    case MoreCategories
    case AllCategories
    case Discover(type: DiscoverType)
    case Conversations
    case CreateConversation
    case CategoryPosts(slug: String)
    case Following
    case Starred
    case Notifications(category: String?)
    case PostDetail(postParam: String)
    case SimpleStream(endpoint: ElloAPI, title: String)
    case Unknown
    case UserStream(userParam: String)

    public var name: String {
        switch self {
        case .Conversations: return InterfaceString.Conversations.Title
        case .CreateConversation: return InterfaceString.CreateConversation.Title
        case .CurrentUserStream: return InterfaceString.Profile.Title
        case .MoreCategories: return InterfaceString.Discover.MoreCategories
        case .AllCategories: return InterfaceString.Discover.AllCategories
        case .CategoryPosts: return InterfaceString.Discover.MoreCategories
        case .Discover: return InterfaceString.Discover.Title
        case .Following: return InterfaceString.FollowingStream.Title
        case .Starred: return InterfaceString.StarredStream.Title
        case .Notifications: return InterfaceString.Notifications.Title
        case .PostDetail: return ""
        case let .SimpleStream(_, title): return title
        case .Unknown: return ""
        case .UserStream: return ""
        }
    }

    public var cacheKey: String {
        switch self {
        case .Conversations: return "Conversations"
        case .CreateConversation: return "CreateConversation"
        case .CurrentUserStream: return "Profile"
        case .MoreCategories: return "MoreCategories"
        case .AllCategories: return "AllCategories"
        case let .CategoryPosts(slug): return "Category_\(slug)"
        case .Discover: return "Discover"
        case .Following: return "Following"
        case .Starred: return "Starred"
        case .Notifications: return "Notifications"
        case .PostDetail: return "PostDetail"
        case .Unknown: return "unknown"
        case .UserStream:
            return "UserStream"
        case let .SimpleStream(endpoint, title):
            switch endpoint {
            case .SearchForPosts:
                return "SearchForPosts"
            default:
                return "SimpleStream.\(title)"
            }
        }
    }

    public var lastViewedCreatedAtKey: String {
        return self.cacheKey + "_createdAt"
    }

    public var columnSpacing: CGFloat {
        switch self {
        case .AllCategories: return 2
        default: return 12
        }
    }

    public var columnCount: Int {
        return columnCountFor(width: Window.width)
    }

    public func columnCountFor(width width: CGFloat) -> Int {
        let gridColumns: Int
        if Window.isWide(width) {
            gridColumns = 3
        }
        else {
            gridColumns = 2
        }

        if self.isGridView {
            return gridColumns
        }
        else {
            return 1
        }
    }

    public var showsCategory: Bool {
        if case let .Discover(type) = self where type == .Featured {
            return true
        }
        return false
    }

    public var tappingTextOpensDetail: Bool {
        switch self {
        case .Following, .Starred:
            return isGridView
        case .PostDetail, .CurrentUserStream, .UserStream:
            return false
        default:
            return true
        }
    }

    public var endpoint: ElloAPI {
        switch self {
        case .Conversations: return .Conversations
        case .CreateConversation: return .ConversationMemberPicker
        case .CurrentUserStream: return .CurrentUserStream
        case .MoreCategories: return .Categories
        case .AllCategories: return .Categories
        case let .CategoryPosts(slug): return .CategoryPosts(slug: slug)
        case let .Discover(type): return .Discover(type: type)
        case .Following: return .FriendStream
        case .Starred: return .NoiseStream
        case let .Notifications(category): return .NotificationsStream(category: category)
        case let .PostDetail(postParam): return .PostDetail(postParam: postParam, commentCount: 10)
        case let .SimpleStream(endpoint, _): return endpoint
        case .Unknown: return .NotificationsStream(category: nil) // doesn't really get used
        case let .UserStream(userParam): return .UserStream(userParam: userParam)
        }
    }

    public var relationship: RelationshipPriority {
        switch self {
        case .Following: return .Following
        case .Starred: return .Starred
        default: return .Null
        }
    }

    public func filter(jsonables: [JSONAble], viewsAdultContent: Bool) -> [JSONAble] {
        switch self {
        case let .SimpleStream(endpoint, _):
            switch endpoint {
            case .Loves:
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
        case .CategoryPosts, .Conversations, .CreateConversation:
            return jsonables
        case .Discover:
            if let users = jsonables as? [User] {
                return users.reduce([]) { accum, user in
                    if let post = user.mostRecentPost {
                        return accum + [post]
                    }
                    return accum
                }
            }
            else if let comments = jsonables as? [ElloComment]  {
                return comments
            }
            else if let posts = jsonables as? [Post]  {
                return posts
            }
            else {
                return []
            }
        case .Notifications:
            if let activities = jsonables as? [Activity] {
                let notifications: [Notification] = activities.map { return Notification(activity: $0) }
                return notifications.filter { return $0.isValidKind }
            }
            else {
                return []
            }
        default:
            if let activities = jsonables as? [Activity] {
                return activities.reduce([]) { accum, activity in
                    if let post = activity.subject as? Post {
                        return accum + [post]
                    }
                    return accum
                }
            }
            else if let comments = jsonables as? [ElloComment] {
                return comments
            }
            else if let posts = jsonables as? [Post] {
                return posts
            } else if let users = jsonables as? [User] {
                return users
            }
        }
        return []
    }

    public var gridPreferenceSetOffset: CGPoint {
        switch self {
        case .Discover, .CategoryPosts: return CGPoint(x: 0, y: -80)
        default: return CGPoint(x: 0, y: -20)
        }
    }

    public var avatarHeight: CGFloat {
        return self.isGridView ? 30 : 40
    }

    public func contentForPost(post: Post) -> [Regionable]? {
        return self.isGridView ? post.summary : post.content
    }

    public var gridViewPreferenceSet: Bool {
        switch self {
        case .Notifications: return false
        default:
            let prefSet = GroupDefaults["\(self.cacheKey)GridViewPreferenceSet"].bool
            return prefSet != nil
        }
    }

    public func setIsGridView(isGridView: Bool) {
        GroupDefaults["\(cacheKey)GridViewPreferenceSet"] = true
        GroupDefaults["\(cacheKey)IsGridView"] = isGridView
    }

    public var isGridView: Bool {
        var defaultGrid: Bool
        switch self {
        case .AllCategories: defaultGrid = true
        case .MoreCategories: defaultGrid = false
        default: defaultGrid = false
        }
        return GroupDefaults["\(cacheKey)IsGridView"].bool ?? defaultGrid
    }

    public func clientSidePostInsertIndexPath(currentUserId: String?) -> NSIndexPath? {
        switch self {
        case .Following:
            return NSIndexPath(forItem: 1, inSection: 0)
        case .CurrentUserStream:
            return NSIndexPath(forItem: 4, inSection: 0)
        case let .UserStream(userParam):
            if currentUserId == userParam {
                return NSIndexPath(forItem: 4, inSection: 0)
            }
        default: return nil
        }
        return nil
    }

    public var clientSideLoveInsertIndexPath: NSIndexPath? {
        switch self {
        case let .SimpleStream(endpoint, _):
            switch endpoint {
            case .Loves: return NSIndexPath(forItem: 1, inSection: 0)
            default: return nil
            }
        default: return nil
        }
    }

    public var hasGridViewToggle: Bool {
        switch self {
        case .Following, .Starred, .Discover, .CategoryPosts: return true
        case let .SimpleStream(endpoint, _):
            switch endpoint {
            case .SearchForPosts, .Loves:
                return true
            default:
                return false
            }
        default: return false
        }
    }

    public var showStarButton: Bool {
        switch self {
        case .Notifications:
            return false
        case let .SimpleStream(endpoint, _):
            switch endpoint {
            case .AwesomePeopleStream, .CommunitiesStream:
                return false
            default:
                break
            }
        default:
            break
        }
        return true
    }

    public var isDetail: Bool {
        switch self {
        case .PostDetail: return true
        default: return false
        }
    }

    public var supportsLargeImages: Bool {
        switch self {
        case .PostDetail: return true
        default: return false
        }
    }
}
