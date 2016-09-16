////
///  ElloAPI.swift
//

import Moya
import Result

public typealias MoyaResult = Result<Moya.Response, Moya.Error>

public enum ElloAPI {
    case AmazonCredentials
    case AnonymousCredentials
    case Auth(email: String, password: String)
    case Availability(content: [String: String])
    case Categories
    case CommentDetail(postId: String, commentId: String)
    case CreateComment(parentPostId: String, body: [String: AnyObject])
    case CreateLove(postId: String)
    case CreatePost(body: [String: AnyObject])
    case DeleteComment(postId: String, commentId: String)
    case DeleteLove(postId: String)
    case DeletePost(postId: String)
    case DeleteSubscriptions(token: NSData)
    case CategoryPosts(slug: String)
    case Discover(type: DiscoverType)
    case EmojiAutoComplete(terms: String)
    case FindFriends(contacts: [String: [String]])
    case FlagComment(postId: String, commentId: String, kind: String)
    case FlagPost(postId: String, kind: String)
    case FlagUser(userId: String, kind: String)
    case FriendStream
    case FriendNewContent(createdAt: NSDate)
    case Hire(userId: String, body: String)
    case InfiniteScroll(queryItems: [AnyObject], elloApi: () -> ElloAPI)
    case InviteFriends(contact: String)
    case Join(email: String, username: String, password: String, invitationCode: String?)
    case Loves(userId: String)
    case NoiseStream
    case NoiseNewContent(createdAt: NSDate)
    case NotificationsNewContent(createdAt: NSDate)
    case NotificationsStream(category: String?)
    case PostComments(postId: String)
    case PostDetail(postParam: String, commentCount: Int)
    case PostLovers(postId: String)
    case PostReplyAll(postId: String)
    case PostReposters(postId: String)
    case CurrentUserBlockedList
    case CurrentUserMutedList
    case CurrentUserProfile
    case CurrentUserStream
    case ProfileDelete
    case ProfileToggles
    case ProfileUpdate(body: [String: AnyObject])
    case PushSubscriptions(token: NSData)
    case ReAuth(token: String)
    case RePost(postId: String)
    case Relationship(userId: String, relationship: String)
    case RelationshipBatch(userIds: [String], relationship: String)
    case SearchForUsers(terms: String)
    case SearchForPosts(terms: String)
    case UpdatePost(postId: String, body: [String: AnyObject])
    case UpdateComment(postId: String, commentId: String, body: [String: AnyObject])
    case UserCategories(categoryIds: [String])
    case UserStream(userParam: String)
    case UserStreamFollowers(userId: String)
    case UserStreamFollowing(userId: String)
    case UserStreamPosts(userId: String)
    case UserNameAutoComplete(terms: String)

    public static let apiVersion = "v2"

    var pagingPath: String? {
        switch self {
        case .PostDetail:
            return "comments"
        case .CurrentUserStream,
             .UserStream:
            return "posts"
        default:
            return nil
        }
    }

    public var mappingType: MappingType {
        switch self {
        case .Categories:
            return .CategoriesType
        case .AmazonCredentials:
            return .AmazonCredentialsType
        case .Availability:
            return .AvailabilityType
        case .PostReplyAll:
            return .UsernamesType
        case .CurrentUserBlockedList,
             .CurrentUserMutedList,
             .CurrentUserProfile,
             .CurrentUserStream,
             .FindFriends,
             .Join,
             .PostLovers,
             .PostReposters,
             .ProfileUpdate,
             .SearchForUsers,
             .UserStream,
             .UserStreamFollowers,
             .UserStreamFollowing:
            return .UsersType
        case let .Discover(type):
            switch type {
            case .Trending:
                return .UsersType
            default:
                return .PostsType
            }
        case .CommentDetail,
             .CreateComment,
             .PostComments,
             .UpdateComment:
            return .CommentsType
        case .CreateLove,
             .Loves:
            return .LovesType
        case .CategoryPosts,
             .CreatePost,
             .PostDetail,
             .RePost,
             .SearchForPosts,
             .UpdatePost,
             .UserStreamPosts:
            return .PostsType
        case .EmojiAutoComplete,
             .UserNameAutoComplete:
            return .AutoCompleteResultType
        case .DeleteLove,
             .DeleteSubscriptions,
             .FlagComment,
             .FlagPost,
             .FlagUser,
             .Hire,
             .InviteFriends,
             .ProfileDelete,
             .PushSubscriptions,
             .RelationshipBatch,
             .UserCategories:
            return .NoContentType
        case .FriendStream,
             .NoiseStream,
             .NotificationsStream:
            return .ActivitiesType
        case let .InfiniteScroll(_, elloApi):
            let api = elloApi()
            if let pagingPath = api.pagingPath,
                mappingType = MappingType(rawValue: pagingPath) {
                return mappingType
            }
            return api.mappingType
        case .ProfileToggles:
            return .DynamicSettingsType
        case .Relationship:
            return .RelationshipsType
        default:
            return .ErrorType
        }
    }
}

extension ElloAPI {
    public var supportsAnonymousToken: Bool {
        switch self {
        case .Availability,
             .Join, .DeleteSubscriptions:
            return true
        default:
            return false
        }
    }

    public var requiresAnyToken: Bool {
        switch self {
        case .AnonymousCredentials,
             .Auth,
             .ReAuth:
            return false
        default:
            return true
        }
    }
}

public protocol ElloTarget: Moya.TargetType {
    var sampleResponse: NSHTTPURLResponse { get }
}

extension ElloAPI: Moya.TargetType {
    public var baseURL: NSURL { return NSURL(string: ElloURI.baseURL)! }
    public var method: Moya.Method {
        switch self {
        case .AnonymousCredentials,
             .Auth,
             .Availability,
             .CreateComment,
             .CreateLove,
             .CreatePost,
             .FindFriends,
             .FlagComment,
             .FlagPost,
             .FlagUser,
             .Hire,
             .InviteFriends,
             .Join,
             .PushSubscriptions,
             .ReAuth,
             .Relationship,
             .RelationshipBatch,
             .RePost:
            return .POST
        case .UserCategories:
            return .PUT
        case .DeleteComment,
             .DeleteLove,
             .DeletePost,
             .DeleteSubscriptions,
             .ProfileDelete:
            return .DELETE
        case .FriendNewContent,
             .NoiseNewContent,
             .NotificationsNewContent:
            return .HEAD
        case .ProfileUpdate,
             .UpdateComment,
             .UpdatePost:
            return .PATCH
        case let .InfiniteScroll(_, elloApi):
            return elloApi().method
        default:
            return .GET
        }
    }

    public var path: String {
        switch self {
        case .AmazonCredentials:
            return "/api/\(ElloAPI.apiVersion)/assets/credentials"
        case .AnonymousCredentials,
             .Auth,
             .ReAuth:
            return "/api/oauth/token"
        case .Availability:
            return "/api/\(ElloAPI.apiVersion)/availability"
        case let .CommentDetail(postId, commentId):
            return "/api/\(ElloAPI.apiVersion)/posts/\(postId)/comments/\(commentId)"
        case .Categories:
            return "/api/\(ElloAPI.apiVersion)/categories"
        case let .CreateComment(parentPostId, _):
            return "/api/\(ElloAPI.apiVersion)/posts/\(parentPostId)/comments"
        case let .CreateLove(postId):
            return "/api/\(ElloAPI.apiVersion)/posts/\(postId)/loves"
        case .CreatePost,
             .RePost:
            return "/api/\(ElloAPI.apiVersion)/posts"
        case let .DeleteComment(postId, commentId):
            return "/api/\(ElloAPI.apiVersion)/posts/\(postId)/comments/\(commentId)"
        case let .DeleteLove(postId):
            return "/api/\(ElloAPI.apiVersion)/posts/\(postId)/love"
        case let .DeletePost(postId):
            return "/api/\(ElloAPI.apiVersion)/posts/\(postId)"
        case let .DeleteSubscriptions(tokenData):
            return "\(ElloAPI.CurrentUserStream.path)/push_subscriptions/apns/\(tokenStringFromData(tokenData))"
        case let .CategoryPosts(slug):
            return "/api/\(ElloAPI.apiVersion)/categories/\(slug)/posts/recent"
        case let .Discover(type):
            switch type {
            case .Trending:
                return "/api/\(ElloAPI.apiVersion)/discover/users/trending"
            case .Featured:
                return "/api/\(ElloAPI.apiVersion)/categories/posts/recent"
            default:
                return "/api/\(ElloAPI.apiVersion)/discover/posts/\(type.slug)"
            }
        case .EmojiAutoComplete(_):
            return "/api/\(ElloAPI.apiVersion)/emoji/autocomplete"
        case .FindFriends:
            return "/api/\(ElloAPI.apiVersion)/profile/find_friends"
        case let .FlagComment(postId, commentId, kind):
            return "/api/\(ElloAPI.apiVersion)/posts/\(postId)/comments/\(commentId)/flag/\(kind)"
        case let .FlagPost(postId, kind):
            return "/api/\(ElloAPI.apiVersion)/posts/\(postId)/flag/\(kind)"
        case let .FlagUser(userId, kind):
            return "/api/\(ElloAPI.apiVersion)/users/\(userId)/flag/\(kind)"
        case .FriendNewContent,
             .FriendStream:
            return "/api/\(ElloAPI.apiVersion)/streams/friend"
        case let .Hire(userId, _):
            return "/api/\(ElloAPI.apiVersion)/users/\(userId)/hire_me"
        case let .InfiniteScroll(_, elloApi):
            let api = elloApi()
            if let pagingPath = api.pagingPath {
                return "\(api.path)/\(pagingPath)"
            }
            return api.path
        case .InviteFriends:
            return "/api/\(ElloAPI.apiVersion)/invitations"
        case .Join:
            return "/api/\(ElloAPI.apiVersion)/join"
        case let .Loves(userId):
            return "/api/\(ElloAPI.apiVersion)/users/\(userId)/loves"
        case .NoiseNewContent,
             .NoiseStream:
            return "/api/\(ElloAPI.apiVersion)/streams/noise"
        case .NotificationsNewContent,
             .NotificationsStream:
            return "/api/\(ElloAPI.apiVersion)/notifications"
        case let .PostComments(postId):
            return "/api/\(ElloAPI.apiVersion)/posts/\(postId)/comments"
        case let .PostDetail(postParam, _):
            return "/api/\(ElloAPI.apiVersion)/posts/\(postParam)"
        case let .PostLovers(postId):
            return "/api/\(ElloAPI.apiVersion)/posts/\(postId)/lovers"
        case let .PostReplyAll(postId):
            return "/api/\(ElloAPI.apiVersion)/posts/\(postId)/commenters_usernames"
        case let .PostReposters(postId):
            return "/api/\(ElloAPI.apiVersion)/posts/\(postId)/reposters"
        case .CurrentUserProfile,
             .CurrentUserStream,
             .ProfileUpdate,
             .ProfileDelete:
            return "/api/\(ElloAPI.apiVersion)/profile"
        case .CurrentUserBlockedList:
            return "/api/\(ElloAPI.apiVersion)/profile/blocked"
        case .CurrentUserMutedList:
            return "/api/\(ElloAPI.apiVersion)/profile/muted"
        case .ProfileToggles:
            return "\(ElloAPI.CurrentUserStream.path)/settings"
        case let .PushSubscriptions(tokenData):
            return "\(ElloAPI.CurrentUserStream.path)/push_subscriptions/apns/\(tokenStringFromData(tokenData))"
        case let .Relationship(userId, relationship):
            return "/api/\(ElloAPI.apiVersion)/users/\(userId)/add/\(relationship)"
        case .RelationshipBatch(_, _):
            return "/api/\(ElloAPI.apiVersion)/relationships/batches"
        case .SearchForPosts:
            return "/api/\(ElloAPI.apiVersion)/posts"
        case .SearchForUsers:
            return "/api/\(ElloAPI.apiVersion)/users"
        case let .UpdatePost(postId, _):
            return "/api/\(ElloAPI.apiVersion)/posts/\(postId)"
        case let .UpdateComment(postId, commentId, _):
            return "/api/\(ElloAPI.apiVersion)/posts/\(postId)/comments/\(commentId)"
        case .UserCategories:
            return "\(ElloAPI.CurrentUserStream.path)/followed_categories"
        case let .UserStream(userParam):
            return "/api/\(ElloAPI.apiVersion)/users/\(userParam)"
        case let .UserStreamFollowers(userId):
            return "\(ElloAPI.UserStream(userParam: userId).path)/followers"
        case let .UserStreamFollowing(userId):
            return "\(ElloAPI.UserStream(userParam: userId).path)/following"
        case let .UserStreamPosts(userId):
            return "\(ElloAPI.UserStream(userParam: userId).path)/posts"
        case .UserNameAutoComplete(_):
            return "/api/\(ElloAPI.apiVersion)/users/autocomplete"
        }
    }

    public var sampleData: NSData {
        switch self {
        case .AmazonCredentials:
            return stubbedData("amazon-credentials")
        case .AnonymousCredentials,
             .Auth,
             .ReAuth:
            return stubbedData("auth")
        case .Availability:
            return stubbedData("availability")
        case .CreateComment, .CommentDetail:
            return stubbedData("create-comment")
        case .CreateLove:
            return stubbedData("loves_creating_a_love")
        case .CreatePost,
             .RePost:
            return stubbedData("create-post")
        case .Categories:
            return stubbedData("categories")
        case .DeleteComment,
             .DeleteLove,
             .DeletePost,
             .DeleteSubscriptions,
             .FriendNewContent,
             .Hire,
             .InviteFriends,
             .NoiseNewContent,
             .NotificationsNewContent,
             .ProfileDelete,
             .PushSubscriptions,
             .FlagComment,
             .FlagPost,
             .FlagUser,
             .UserCategories:
            return stubbedData("empty")
        case .CategoryPosts:
            return stubbedData("posts")
        case .Discover:
            return stubbedData("posts_searching_for_posts")
        case .EmojiAutoComplete:
            return stubbedData("users_getting_a_list_for_autocompleted_usernames")
        case .FindFriends:
            return stubbedData("find-friends")
        case .FriendStream,
             .InfiniteScroll:
            return stubbedData("activity_streams_friend_stream")
        case .Join:
            return stubbedData("users_registering_an_account")
        case .Loves:
            return stubbedData("loves_listing_loves_for_a_user")
        case .NoiseStream:
            return stubbedData("activity_streams_noise_stream")
        case .NotificationsStream:
            return stubbedData("activity_streams_notifications")
        case .PostComments:
            return stubbedData("posts_loading_more_post_comments")
        case .PostDetail,
            .UpdatePost:
            return stubbedData("posts_post_details")
        case .UpdateComment:
            return stubbedData("create-comment")
        case .SearchForUsers,
             .UserStream,
             .UserStreamFollowers,
             .UserStreamFollowing:
            return stubbedData("users_user_details")
        case .PostLovers:
            return stubbedData("posts_listing_users_who_have_loved_a_post")
        case .PostReposters:
            return stubbedData("posts_listing_users_who_have_reposted_a_post")
        case .PostReplyAll:
            return stubbedData("usernames")
        case .CurrentUserBlockedList:
            return stubbedData("profile_listing_blocked_users")
        case .CurrentUserMutedList:
            return stubbedData("profile_listing_muted_users")
        case .CurrentUserProfile,
             .CurrentUserStream:
            return stubbedData("profile")
        case .ProfileToggles:
            return stubbedData("profile_available_user_profile_toggles")
        case .ProfileUpdate:
            return stubbedData("profile_updating_user_profile_and_settings")
        case let .Relationship(_, relationship):
            switch RelationshipPriority(rawValue: relationship)! {
            case .Following:
                return stubbedData("relationship_following")
            case .Starred:
                return stubbedData("relationship_starred")
            default:
                return stubbedData("relationship_inactive")
            }
        case .RelationshipBatch:
            return stubbedData("relationship_batches")
        case .SearchForPosts:
            return stubbedData("posts_searching_for_posts")
        case .UserNameAutoComplete:
            return stubbedData("users_getting_a_list_for_autocompleted_usernames")
        case .UserStreamPosts:
            //TODO: get post data to test
            return stubbedData("users_posts")
        }
    }

    public var multipartBody: [MultipartFormData]? {
        return nil
    }

    public var encoding: Moya.ParameterEncoding {
        if self.method == .GET || self.method == .HEAD {
            return Moya.ParameterEncoding.URL
        }
        else {
            return Moya.ParameterEncoding.JSON
        }
    }

    public func headers() -> [String: String] {
        var assigned: [String: String] = [
            "Accept": "application/json",
            "Accept-Language": "",
            "Content-Type": "application/json",
        ]

        if let info = NSBundle.mainBundle().infoDictionary,
            buildNumber = info[kCFBundleVersionKey as String] as? String
        {
            assigned["X-iOS-Build-Number"] = buildNumber
        }

        if self.requiresAnyToken {
            assigned += [
                "Authorization": AuthToken().tokenWithBearer ?? "",
            ]
        }

        if let sharingHeaders = self.sharingHeaders {
            assigned += sharingHeaders
        }

        switch self {
        case let .FriendNewContent(createdAt):
            assigned += [
                "If-Modified-Since": createdAt.toHTTPDateString()
            ]
        case let .NoiseNewContent(createdAt):
            assigned += [
                "If-Modified-Since": createdAt.toHTTPDateString()
            ]
        case let .NotificationsNewContent(createdAt):
            assigned += [
                "If-Modified-Since": createdAt.toHTTPDateString()
            ]
        default: break
        }
        return assigned
    }

    public var parameters: [String: AnyObject]? {

        switch self {
        case .AnonymousCredentials:
            return [
                "client_id": APIKeys.sharedKeys.key,
                "client_secret": APIKeys.sharedKeys.secret,
                "grant_type": "client_credentials"
            ]
        case let .Auth(email, password):
            return [
                "client_id": APIKeys.sharedKeys.key,
                "client_secret": APIKeys.sharedKeys.secret,
                "email": email,
                "password":  password,
                "grant_type": "password"
            ]
        case let .Availability(content):
            return content
        case .CurrentUserProfile:
            return [
                "post_count": 0
            ]
        case let .CreateComment(_, body):
            return body
        case let .CreatePost(body):
            return body
        case .CategoryPosts:
            return [
                "per_page": 10,
            ]
        case .Discover:
            return [
                "per_page": 10,
                "include_recent_posts": true,
                "seed": ElloAPI.generateSeed()
            ]
        case let .FindFriends(contacts):
            var hashedContacts = [String: [String]]()
            for (key, emails) in contacts {
                hashedContacts[key] = emails.map { $0.saltedSHA1String }.reduce([String]()) { (accum, hash) in
                    if let hash = hash, accum = accum {
                        return accum + [hash]
                    }
                    return accum
                }
            }
            return ["contacts": hashedContacts]
        case .FriendStream:
            return [
                "per_page": 10
            ]
        case let .Hire(_, body):
            return [
                "body": body
            ]
        case let .InfiniteScroll(queryItems, elloApi):
            var queryDict = [String: AnyObject]()
            for item in queryItems {
                if let item = item as? NSURLQueryItem {
                    queryDict[item.name] = item.value
                }
            }
            var origDict = elloApi().parameters ?? [String:AnyObject]()
            origDict.merge(queryDict)
            return origDict
        case let .InviteFriends(contact):
            return ["email": contact]
        case let .Join(email, username, password, invitationCode):
            var params = [
                "email": email,
                "username": username,
                "password": password,
                "password_confirmation":  password
            ]
            if let invitationCode = invitationCode {
                params["invitation_code"] = invitationCode
            }
            return params
        case .NoiseStream:
            return [
                "per_page": 10
            ]
        case let .NotificationsStream(category):
            var params: [String: AnyObject] = ["per_page": 10]
            if let category = category {
                params["category"] = category
            }
            return params
        case .PostComments:
            return [
                "per_page": 10
            ]
        case let .PostDetail(_, commentCount):
            return [
                "comment_count": commentCount
            ]
        case .CurrentUserStream:
            return [
                "post_count": 10
            ]
        case let .ProfileUpdate(body):
            return body
        case .PushSubscriptions,
             .DeleteSubscriptions:
            var bundleIdentifier = "co.ello.ElloDev"
            var bundleShortVersionString = "unknown"
            var bundleVersion = "unknown"

            if let bundleId = NSBundle.mainBundle().bundleIdentifier {
                bundleIdentifier = bundleId
            }

            if let shortVersionString = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
                bundleShortVersionString = shortVersionString
            }

            if let version = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
                bundleVersion = version
            }

            return [
                "bundle_identifier": bundleIdentifier,
                "marketing_version": bundleShortVersionString,
                "build_version": bundleVersion
            ]
        case let .ReAuth(refreshToken):
            return [
                "client_id": APIKeys.sharedKeys.key,
                "client_secret": APIKeys.sharedKeys.secret,
                "grant_type": "refresh_token",
                "refresh_token": refreshToken
            ]
        case let .RelationshipBatch(userIds, relationship):
            return [
                "user_ids": userIds,
                "priority": relationship
            ]
        case let .RePost(postId):
            return [ "repost_id": Int(postId) ?? -1 ]
        case let .SearchForPosts(terms):
            return [
                "terms": terms,
                "per_page": 10
            ]
        case let .SearchForUsers(terms):
            return [
                "terms": terms,
                "per_page": 10
            ]
        case let .UpdatePost(_, body):
            return body
        case let .UpdateComment(_, _, body):
            return body
        case let .UserCategories(categoryIds):
            return [
                "followed_category_ids": categoryIds,
            ]
        case let .UserNameAutoComplete(terms):
            return [
                "terms": terms
            ]
        case .UserStream:
            return [
                "post_count": "false"
            ]
        case .UserStreamPosts:
            return [
                "per_page": 10
            ]
        default:
            return nil
        }
    }
}

public func stubbedData(filename: String) -> NSData! {
    let bundle = NSBundle.mainBundle()
    let path = bundle.pathForResource(filename, ofType: "json")
    return NSData(contentsOfFile: path!)
}

public func url(route: Moya.TargetType) -> String {
    return route.baseURL.URLByAppendingPathComponent(route.path)?.absoluteString ?? ""
}

private func tokenStringFromData(data: NSData) -> String {
    return String(data.description.characters.filter { !"<> ".characters.contains($0) })
}

public extension ElloAPI {
    static func generateSeed() -> Int { return Int(NSDate().timeIntervalSince1970) }
}

func += <KeyType, ValueType> (inout left: Dictionary<KeyType, ValueType>, right: Dictionary<KeyType, ValueType>) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}

extension Moya.ParameterEncoding: Equatable {}

public func == (lhs: Moya.ParameterEncoding, rhs: Moya.ParameterEncoding) -> Bool {
    switch (lhs, rhs) {
    case (.URL, .URL),
         (.JSON, .JSON),
         (.PropertyList, .PropertyList),
         (.Custom, .Custom):
        return true
    default:
        return false
    }
}
