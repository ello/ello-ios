////
///  ElloAPI.swift
//

import Moya
import Result


typealias MoyaResult = Result<Moya.Response, Moya.Error>

enum ElloAPI {
    case amazonCredentials
    case announcements
    case announcementsNewContent(createdAt: Date?)
    case markAnnouncementAsRead
    case anonymousCredentials
    case auth(email: String, password: String)
    case availability(content: [String: String])
    case categories
    case category(slug: String)
    case categoryPosts(slug: String)
    case commentDetail(postId: String, commentId: String)
    case createComment(parentPostId: String, body: [String: AnyObject])
    case createLove(postId: String)
    case createPost(body: [String: AnyObject])
    case createWatchPost(postId: String)
    case deleteComment(postId: String, commentId: String)
    case deleteLove(postId: String)
    case deletePost(postId: String)
    case deleteSubscriptions(token: Data)
    case deleteWatchPost(postId: String)
    case discover(type: DiscoverType)
    case emojiAutoComplete(terms: String)
    case findFriends(contacts: [String: [String]])
    case flagComment(postId: String, commentId: String, kind: String)
    case flagPost(postId: String, kind: String)
    case flagUser(userId: String, kind: String)
    case friendStream
    case friendNewContent(createdAt: Date?)
    case hire(userId: String, body: String)
    case collaborate(userId: String, body: String)
    case infiniteScroll(queryItems: [AnyObject], elloApi: () -> ElloAPI)
    case inviteFriends(contact: String)
    case join(email: String, username: String, password: String, invitationCode: String?)
    case loves(userId: String)
    case locationAutoComplete(terms: String)
    case noiseStream
    case noiseNewContent(createdAt: Date?)
    case notificationsNewContent(createdAt: Date?)
    case notificationsStream(category: String?)
    case pagePromotionals
    case postComments(postId: String)
    case postDetail(postParam: String, commentCount: Int)
    case postLovers(postId: String)
    case postReplyAll(postId: String)
    case postReposters(postId: String)
    case currentUserBlockedList
    case currentUserMutedList
    case currentUserProfile
    case currentUserStream
    case profileDelete
    case profileToggles
    case profileUpdate(body: [String: AnyObject])
    case pushSubscriptions(token: Data)
    case reAuth(token: String)
    case rePost(postId: String)
    case relationship(userId: String, relationship: String)
    case relationshipBatch(userIds: [String], relationship: String)
    case searchForUsers(terms: String)
    case searchForPosts(terms: String)
    case updatePost(postId: String, body: [String: AnyObject])
    case updateComment(postId: String, commentId: String, body: [String: AnyObject])
    case userCategories(categoryIds: [String])
    case userStream(userParam: String)
    case userStreamFollowers(userId: String)
    case userStreamFollowing(userId: String)
    case userStreamPosts(userId: String)
    case userNameAutoComplete(terms: String)

    static let apiVersion = "v2"

    var pagingPath: String? {
        switch self {
        case .postDetail:
            return "\(path)/comments"
        case .currentUserStream,
             .userStream:
            return "\(path)/posts"
        case .category:
            return "\(path)/posts/recent"
        default:
            return nil
        }
    }

    var pagingMappingType: MappingType? {
        switch self {
        case .postDetail:
            return .commentsType
        case .currentUserStream,
             .userStream,
             .category:
            return .postsType
        default:
            return nil
        }
    }

    var mappingType: MappingType {
        switch self {
        case .anonymousCredentials,
             .auth,
             .reAuth:
            return .noContentType  // We do not current have a "Credentials" model, we interact directly with the keychain
        case .announcements:
            return .announcementsType
        case .amazonCredentials:
            return .amazonCredentialsType
        case .availability:
            return .availabilityType
        case .categories,
             .category:
            return .categoriesType
        case .pagePromotionals:
            return .pagePromotionalsType
        case .postReplyAll:
            return .usernamesType
        case .currentUserBlockedList,
             .currentUserMutedList,
             .currentUserProfile,
             .currentUserStream,
             .findFriends,
             .join,
             .postLovers,
             .postReposters,
             .profileUpdate,
             .searchForUsers,
             .userStream,
             .userStreamFollowers,
             .userStreamFollowing:
            return .usersType
        case let .discover(type):
            switch type {
            case .trending:
                return .usersType
            default:
                return .postsType
            }
        case .commentDetail,
             .createComment,
             .postComments,
             .updateComment:
            return .commentsType
        case .createLove,
             .loves:
            return .lovesType
        case .categoryPosts,
             .createPost,
             .postDetail,
             .rePost,
             .searchForPosts,
             .updatePost,
             .userStreamPosts:
            return .postsType
        case .createWatchPost,
             .deleteWatchPost:
            return .watchesType
        case .emojiAutoComplete,
             .userNameAutoComplete,
             .locationAutoComplete:
            return .autoCompleteResultType
        case .announcementsNewContent,
             .collaborate,
             .deleteComment,
             .deleteLove,
             .deletePost,
             .deleteSubscriptions,
             .flagComment,
             .flagPost,
             .flagUser,
             .friendNewContent,
             .hire,
             .inviteFriends,
             .markAnnouncementAsRead,
             .noiseNewContent,
             .notificationsNewContent,
             .profileDelete,
             .pushSubscriptions,
             .relationshipBatch,
             .userCategories:
            return .noContentType
        case .friendStream,
             .noiseStream,
             .notificationsStream:
            return .activitiesType
        case let .infiniteScroll(_, elloApi):
            let api = elloApi()
            if let pagingMappingType = api.pagingMappingType {
                return pagingMappingType
            }
            return api.mappingType
        case .profileToggles:
            return .dynamicSettingsType
        case .relationship:
            return .relationshipsType
        }
    }
}

extension ElloAPI {
    var supportsAnonymousToken: Bool {
        switch self {
        case .availability,
             .join, .deleteSubscriptions:
            return true
        default:
            return false
        }
    }

    var requiresAnyToken: Bool {
        switch self {
        case .anonymousCredentials,
             .auth,
             .reAuth:
            return false
        default:
            return true
        }
    }
}

protocol ElloTarget: Moya.TargetType {
    var sampleResponse: HTTPURLResponse { get }
}

extension ElloAPI: Moya.TargetType {
    var baseURL: URL { return URL(string: ElloURI.baseURL)! }
    var method: Moya.Method {
        switch self {
        case .anonymousCredentials,
             .auth,
             .availability,
             .createComment,
             .createLove,
             .createPost,
             .findFriends,
             .flagComment,
             .flagPost,
             .flagUser,
             .hire,
             .collaborate,
             .inviteFriends,
             .join,
             .pushSubscriptions,
             .reAuth,
             .relationship,
             .relationshipBatch,
             .rePost,
             .createWatchPost:
            return .post
        case .userCategories:
            return .put
        case .deleteComment,
             .deleteLove,
             .deletePost,
             .deleteSubscriptions,
             .profileDelete,
             .deleteWatchPost:
            return .delete
        case .friendNewContent,
             .noiseNewContent,
             .announcementsNewContent,
             .notificationsNewContent:
            return .head
        case .markAnnouncementAsRead,
             .profileUpdate,
             .updateComment,
             .updatePost:
            return .patch
        case let .infiniteScroll(_, elloApi):
            return elloApi().method
        default:
            return .get
        }
    }

    var path: String {
        switch self {
        case .amazonCredentials:
            return "/api/\(ElloAPI.apiVersion)/assets/credentials"
        case .announcements,
             .announcementsNewContent:
            return "/api/\(ElloAPI.apiVersion)/most_recent_announcements"
        case .markAnnouncementAsRead:
            return "\(ElloAPI.announcements.path)/mark_last_read_announcement"
        case .anonymousCredentials,
             .auth,
             .reAuth:
            return "/api/oauth/token"
        case .availability:
            return "/api/\(ElloAPI.apiVersion)/availability"
        case let .commentDetail(postId, commentId):
            return "/api/\(ElloAPI.apiVersion)/posts/\(postId)/comments/\(commentId)"
        case .categories:
            return "/api/\(ElloAPI.apiVersion)/categories"
        case let .category(slug):
            return "/api/\(ElloAPI.apiVersion)/categories/\(slug)"
        case let .categoryPosts(slug):
            return "/api/\(ElloAPI.apiVersion)/categories/\(slug)/posts/recent"
        case let .createComment(parentPostId, _):
            return "/api/\(ElloAPI.apiVersion)/posts/\(parentPostId)/comments"
        case let .createLove(postId):
            return "/api/\(ElloAPI.apiVersion)/posts/\(postId)/loves"
        case .createPost,
             .rePost:
            return "/api/\(ElloAPI.apiVersion)/posts"
        case let .createWatchPost(postId):
            return "/api/\(ElloAPI.apiVersion)/posts/\(postId)/watches"
        case let .deleteComment(postId, commentId):
            return "/api/\(ElloAPI.apiVersion)/posts/\(postId)/comments/\(commentId)"
        case let .deleteLove(postId):
            return "/api/\(ElloAPI.apiVersion)/posts/\(postId)/love"
        case let .deletePost(postId):
            return "/api/\(ElloAPI.apiVersion)/posts/\(postId)"
        case let .deleteSubscriptions(tokenData):
            return "\(ElloAPI.currentUserStream.path)/push_subscriptions/apns/\(tokenStringFromData(tokenData))"
        case let .deleteWatchPost(postId):
            return "/api/\(ElloAPI.apiVersion)/posts/\(postId)/watch"
        case let .discover(type):
            switch type {
            case .trending:
                return "/api/\(ElloAPI.apiVersion)/discover/users/trending"
            case .featured:
                return "/api/\(ElloAPI.apiVersion)/categories/posts/recent"
            default:
                return "/api/\(ElloAPI.apiVersion)/discover/posts/\(type.slug)"
            }
        case .emojiAutoComplete(_):
            return "/api/\(ElloAPI.apiVersion)/emoji/autocomplete"
        case .findFriends:
            return "/api/\(ElloAPI.apiVersion)/profile/find_friends"
        case let .flagComment(postId, commentId, kind):
            return "/api/\(ElloAPI.apiVersion)/posts/\(postId)/comments/\(commentId)/flag/\(kind)"
        case let .flagPost(postId, kind):
            return "/api/\(ElloAPI.apiVersion)/posts/\(postId)/flag/\(kind)"
        case let .flagUser(userId, kind):
            return "/api/\(ElloAPI.apiVersion)/users/\(userId)/flag/\(kind)"
        case .friendNewContent,
             .friendStream:
            return "/api/\(ElloAPI.apiVersion)/streams/friend"
        case let .hire(userId, _):
            return "/api/\(ElloAPI.apiVersion)/users/\(userId)/hire_me"
        case let .collaborate(userId, _):
            return "/api/\(ElloAPI.apiVersion)/users/\(userId)/collaborate"
        case let .infiniteScroll(_, elloApi):
            let api = elloApi()
            if let pagingPath = api.pagingPath {
                return pagingPath
            }
            return api.path
        case .inviteFriends:
            return "/api/\(ElloAPI.apiVersion)/invitations"
        case .join:
            return "/api/\(ElloAPI.apiVersion)/join"
        case let .loves(userId):
            return "/api/\(ElloAPI.apiVersion)/users/\(userId)/loves"
        case .locationAutoComplete(_):
            return "/api/\(ElloAPI.apiVersion)/profile/location_autocomplete"
        case .noiseNewContent,
             .noiseStream:
            return "/api/\(ElloAPI.apiVersion)/streams/noise"
        case .notificationsNewContent,
             .notificationsStream:
            return "/api/\(ElloAPI.apiVersion)/notifications"
        case .pagePromotionals:
            return "/api/\(ElloAPI.apiVersion)/page_promotionals"
        case let .postComments(postId):
            return "/api/\(ElloAPI.apiVersion)/posts/\(postId)/comments"
        case let .postDetail(postParam, _):
            return "/api/\(ElloAPI.apiVersion)/posts/\(postParam)"
        case let .postLovers(postId):
            return "/api/\(ElloAPI.apiVersion)/posts/\(postId)/lovers"
        case let .postReplyAll(postId):
            return "/api/\(ElloAPI.apiVersion)/posts/\(postId)/commenters_usernames"
        case let .postReposters(postId):
            return "/api/\(ElloAPI.apiVersion)/posts/\(postId)/reposters"
        case .currentUserProfile,
             .currentUserStream,
             .profileUpdate,
             .profileDelete:
            return "/api/\(ElloAPI.apiVersion)/profile"
        case .currentUserBlockedList:
            return "/api/\(ElloAPI.apiVersion)/profile/blocked"
        case .currentUserMutedList:
            return "/api/\(ElloAPI.apiVersion)/profile/muted"
        case .profileToggles:
            return "\(ElloAPI.currentUserStream.path)/settings"
        case let .pushSubscriptions(tokenData):
            return "\(ElloAPI.currentUserStream.path)/push_subscriptions/apns/\(tokenStringFromData(tokenData))"
        case let .relationship(userId, relationship):
            return "/api/\(ElloAPI.apiVersion)/users/\(userId)/add/\(relationship)"
        case .relationshipBatch(_, _):
            return "/api/\(ElloAPI.apiVersion)/relationships/batches"
        case .searchForPosts:
            return "/api/\(ElloAPI.apiVersion)/posts"
        case .searchForUsers:
            return "/api/\(ElloAPI.apiVersion)/users"
        case let .updatePost(postId, _):
            return "/api/\(ElloAPI.apiVersion)/posts/\(postId)"
        case let .updateComment(postId, commentId, _):
            return "/api/\(ElloAPI.apiVersion)/posts/\(postId)/comments/\(commentId)"
        case .userCategories:
            return "\(ElloAPI.currentUserStream.path)/followed_categories"
        case let .userStream(userParam):
            return "/api/\(ElloAPI.apiVersion)/users/\(userParam)"
        case let .userStreamFollowers(userId):
            return "\(ElloAPI.userStream(userParam: userId).path)/followers"
        case let .userStreamFollowing(userId):
            return "\(ElloAPI.userStream(userParam: userId).path)/following"
        case let .userStreamPosts(userId):
            return "\(ElloAPI.userStream(userParam: userId).path)/posts"
        case .userNameAutoComplete(_):
            return "/api/\(ElloAPI.apiVersion)/users/autocomplete"
        }
    }

    var sampleData: Data {
        switch self {
        case .announcements:
            return stubbedData("announcements")
        case .amazonCredentials:
            return stubbedData("amazon-credentials")
        case .anonymousCredentials,
             .auth,
             .reAuth:
            return stubbedData("auth")
        case .availability:
            return stubbedData("availability")
        case .createComment, .commentDetail:
            return stubbedData("create-comment")
        case .createLove:
            return stubbedData("loves_creating_a_love")
        case .createPost,
             .rePost:
            return stubbedData("create-post")
        case .createWatchPost:
            return stubbedData("watches_creating_a_watch")
        case .categories:
            return stubbedData("categories")
        case .category:
            return stubbedData("category")
        case .announcementsNewContent,
             .markAnnouncementAsRead,
             .deleteComment,
             .deleteLove,
             .deletePost,
             .deleteSubscriptions,
             .deleteWatchPost,
             .friendNewContent,
             .hire,
             .collaborate,
             .inviteFriends,
             .noiseNewContent,
             .notificationsNewContent,
             .profileDelete,
             .pushSubscriptions,
             .flagComment,
             .flagPost,
             .flagUser,
             .userCategories:
            return stubbedData("empty")
        case .categoryPosts:
            return stubbedData("users_posts")
        case .discover:
            return stubbedData("posts_searching_for_posts")
        case .emojiAutoComplete:
            return stubbedData("users_getting_a_list_for_autocompleted_usernames")
        case .findFriends:
            return stubbedData("find-friends")
        case .friendStream,
             .infiniteScroll:
            return stubbedData("activity_streams_friend_stream")
        case .join:
            return stubbedData("users_registering_an_account")
        case .loves:
            return stubbedData("loves_listing_loves_for_a_user")
        case .locationAutoComplete:
            return stubbedData("users_getting_a_list_for_autocompleted_locations")
        case .noiseStream:
            return stubbedData("activity_streams_noise_stream")
        case .notificationsStream:
            return stubbedData("activity_streams_notifications")
        case .pagePromotionals:
            return stubbedData("page_promotionals")
        case .postComments:
            return stubbedData("posts_loading_more_post_comments")
        case .postDetail,
            .updatePost:
            return stubbedData("posts_post_details")
        case .updateComment:
            return stubbedData("create-comment")
        case .searchForUsers,
             .userStream,
             .userStreamFollowers,
             .userStreamFollowing:
            return stubbedData("users_user_details")
        case .postLovers:
            return stubbedData("posts_listing_users_who_have_loved_a_post")
        case .postReposters:
            return stubbedData("posts_listing_users_who_have_reposted_a_post")
        case .postReplyAll:
            return stubbedData("usernames")
        case .currentUserBlockedList:
            return stubbedData("profile_listing_blocked_users")
        case .currentUserMutedList:
            return stubbedData("profile_listing_muted_users")
        case .currentUserProfile,
             .currentUserStream:
            return stubbedData("profile")
        case .profileToggles:
            return stubbedData("profile_available_user_profile_toggles")
        case .profileUpdate:
            return stubbedData("profile_updating_user_profile_and_settings")
        case let .relationship(_, relationship):
            switch RelationshipPriority(rawValue: relationship)! {
            case .following:
                return stubbedData("relationship_following")
            case .starred:
                return stubbedData("relationship_starred")
            default:
                return stubbedData("relationship_inactive")
            }
        case .relationshipBatch:
            return stubbedData("relationship_batches")
        case .searchForPosts:
            return stubbedData("posts_searching_for_posts")
        case .userNameAutoComplete:
            return stubbedData("users_getting_a_list_for_autocompleted_usernames")
        case .userStreamPosts:
            //TODO: get post data to test
            return stubbedData("users_posts")
        }
    }

    var multipartBody: [Moya.MultipartFormData]? {
        return nil
    }

    var parameterEncoding: Moya.ParameterEncoding {
        if self.method == .get || self.method == .head {
            return URLEncoding.default
        }
        else {
            return JSONEncoding.default
        }
    }

    var validate: Bool {
        return false
    }

    var task: Task {
        return .request
    }

    func headers() -> [String: String] {
        var assigned: [String: String] = [
            "Accept": "application/json",
            "Accept-Language": "",
            "Content-Type": "application/json",
        ]

        if let info = Bundle.main.infoDictionary,
            let buildNumber = info[kCFBundleVersionKey as String] as? String
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

        let createdAtHeader: String?
        switch self {
        case let .announcementsNewContent(createdAt):
            createdAtHeader = createdAt?.toHTTPDateString()
        case let .friendNewContent(createdAt):
            createdAtHeader = createdAt?.toHTTPDateString()
        case let .noiseNewContent(createdAt):
            createdAtHeader = createdAt?.toHTTPDateString()
        case let .notificationsNewContent(createdAt):
            createdAtHeader = createdAt?.toHTTPDateString()
        default:
            createdAtHeader = nil
        }

        if let createdAtHeader = createdAtHeader {
            assigned += [
                "If-Modified-Since": createdAtHeader
            ]
        }
        return assigned
    }

    var parameters: [String: Any]? {
        switch self {
        case .anonymousCredentials:
            return [
                "client_id": APIKeys.sharedKeys.key as AnyObject,
                "client_secret": APIKeys.sharedKeys.secret as AnyObject,
                "grant_type": "client_credentials" as AnyObject
            ]
        case let .auth(email, password):
            return [
                "client_id": APIKeys.sharedKeys.key as AnyObject,
                "client_secret": APIKeys.sharedKeys.secret as AnyObject,
                "email": email as AnyObject,
                "password":  password as AnyObject,
                "grant_type": "password" as AnyObject
            ]
        case let .availability(content):
            return content as [String : AnyObject]?
        case .currentUserProfile:
            return [
                "post_count": 0 as AnyObject
            ]
        case let .createComment(_, body):
            return body
        case let .createPost(body):
            return body
        case .categories:
            return [
                "meta": true as AnyObject,
            ]
        case .categoryPosts:
            return [
                "per_page": 10 as AnyObject,
            ]
        case .discover:
            return [
                "per_page": 10 as AnyObject,
                "include_recent_posts": true as AnyObject,
                "seed": ElloAPI.generateSeed() as AnyObject
            ]
        case let .findFriends(contacts):
            var hashedContacts = [String: [String]]()
            for (key, emails) in contacts {
                hashedContacts[key] = emails.map { $0.saltedSHA1String }.reduce([String]()) { (accum, hash) in
                    if let hash = hash, let accum = accum {
                        return accum + [hash]
                    }
                    return accum
                }
            }
            return ["contacts": hashedContacts as AnyObject]
        case .friendStream:
            return [
                "per_page": 10 as AnyObject
            ]
        case let .hire(_, body):
            return [
                "body": body as AnyObject
            ]
        case let .collaborate(_, body):
            return [
                "body": body as AnyObject
            ]
        case let .infiniteScroll(queryItems, elloApi):
            var queryDict = [String: AnyObject]()
            for item in queryItems {
                if let item = item as? URLQueryItem {
                    queryDict[item.name] = item.value as AnyObject?
                }
            }
            var origDict = elloApi().parameters ?? [String:AnyObject]()
            origDict.merge(queryDict)
            return origDict
        case let .inviteFriends(contact):
            return ["email": contact as AnyObject]
        case let .join(email, username, password, invitationCode):
            var params = [
                "email": email,
                "username": username,
                "password": password,
                "password_confirmation":  password
            ]
            if let invitationCode = invitationCode {
                params["invitation_code"] = invitationCode
            }
            return params as [String : AnyObject]?
        case let .locationAutoComplete(terms):
            return [
                "location": terms as AnyObject
            ]
        case .noiseStream:
            return [
                "per_page": 10 as AnyObject
            ]
        case let .notificationsStream(category):
            var params: [String: AnyObject] = ["per_page": 10 as AnyObject]
            if let category = category {
                params["category"] = category as AnyObject?
            }
            return params
        case .postComments:
            return [
                "per_page": 10 as AnyObject
            ]
        case let .postDetail(_, commentCount):
            return [
                "comment_count": commentCount as AnyObject
            ]
        case .currentUserStream:
            return [
                "post_count": 10 as AnyObject
            ]
        case let .profileUpdate(body):
            return body
        case .pushSubscriptions,
             .deleteSubscriptions:
            var bundleIdentifier = "co.ello.ElloDev"
            var bundleShortVersionString = "unknown"
            var bundleVersion = "unknown"

            if let bundleId = Bundle.main.bundleIdentifier {
                bundleIdentifier = bundleId
            }

            if let shortVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                bundleShortVersionString = shortVersionString
            }

            if let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                bundleVersion = version
            }

            return [
                "bundle_identifier": bundleIdentifier as AnyObject,
                "marketing_version": bundleShortVersionString as AnyObject,
                "build_version": bundleVersion as AnyObject
            ]
        case let .reAuth(refreshToken):
            return [
                "client_id": APIKeys.sharedKeys.key as AnyObject,
                "client_secret": APIKeys.sharedKeys.secret as AnyObject,
                "grant_type": "refresh_token" as AnyObject,
                "refresh_token": refreshToken as AnyObject
            ]
        case let .relationshipBatch(userIds, relationship):
            return [
                "user_ids": userIds as AnyObject,
                "priority": relationship as AnyObject
            ]
        case let .rePost(postId):
            return [ "repost_id": Int(postId) as AnyObject? ?? -1 as AnyObject ]
        case let .searchForPosts(terms):
            return [
                "terms": terms as AnyObject,
                "per_page": 10 as AnyObject
            ]
        case let .searchForUsers(terms):
            return [
                "terms": terms as AnyObject,
                "per_page": 10 as AnyObject
            ]
        case let .updatePost(_, body):
            return body
        case let .updateComment(_, _, body):
            return body
        case let .userCategories(categoryIds):
            return [
                "followed_category_ids": categoryIds as AnyObject,
            ]
        case let .userNameAutoComplete(terms):
            return [
                "terms": terms as AnyObject
            ]
        case .userStream:
            return [
                "post_count": "false" as AnyObject
            ]
        case .userStreamPosts:
            return [
                "per_page": 10 as AnyObject
            ]
        default:
            return nil
        }
    }
}

func stubbedData(_ filename: String) -> Data {
    let bundle = Bundle.main
    let path = bundle.path(forResource: filename, ofType: "json")
    return (try! Data(contentsOf: URL(fileURLWithPath: path!)))
}

func url(_ route: Moya.TargetType) -> String {
    return route.baseURL.appendingPathComponent(route.path).absoluteString
}

private func tokenStringFromData(_ data: Data) -> String {
    return String((data as NSData).description.characters.filter { !"<> ".characters.contains($0) })
}

extension ElloAPI {
    static func generateSeed() -> Int { return Int(Date().timeIntervalSince1970) }
}

func += <KeyType, ValueType> (left: inout Dictionary<KeyType, ValueType>, right: Dictionary<KeyType, ValueType>) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}

//extension Moya.ParameterEncoding: Equatable {}
//
//func == (lhs: Moya.ParameterEncoding, rhs: Moya.ParameterEncoding) -> Bool {
//    switch (lhs, rhs) {
//    case (.url, .url),
//         (.json, .json),
//         (.PropertyList, .PropertyList),
//         (.Custom, .Custom):
//        return true
//    default:
//        return false
//    }
//}
