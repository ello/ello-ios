////
///  ElloAPI.swift
//

import Moya
import Result


typealias MoyaResult = Result<Moya.Response, Moya.MoyaError>

// We want the responder chain and we want to pass ElloAPI arguments. So we box
// it.
class BoxedElloAPI: NSObject {
    let endpoint: ElloAPI
    init(endpoint: ElloAPI) { self.endpoint = endpoint }
}

indirect enum ElloAPI {
    case amazonCredentials
    case amazonLoggingCredentials
    case announcements
    case announcementsNewContent(createdAt: Date?)
    case artistInvites
    case artistInviteDetail(id: String)
    case artistInviteSubmissions
    case markAnnouncementAsRead
    case anonymousCredentials
    case auth(email: String, password: String)
    case availability(content: [String: String])
    case categories
    case category(slug: String)
    case categoryPosts(slug: String)
    case categoryPostActions
    case commentDetail(postId: String, commentId: String)
    case createCategoryUser(categoryId: String, userId: String, role: String)
    case createComment(parentPostId: String, body: [String: Any])
    case createLove(postId: String)
    case createPost(body: [String: Any])
    case createWatchPost(postId: String)
    case custom(url: URL, mimics: ElloAPI)
    case customRequest(ElloRequest, mimics: ElloAPI)
    case deleteCategoryUser(String)
    case deleteComment(postId: String, commentId: String)
    case deleteLove(postId: String)
    case deletePost(postId: String)
    case deleteSubscriptions(token: Data)
    case deleteWatchPost(postId: String)
    case editCategoryUser(categoryId: String, userId: String, role: String)
    case editorials
    case emojiAutoComplete(terms: String)
    case findFriends(contacts: [String: [String]])
    case flagComment(postId: String, commentId: String, kind: String)
    case flagPost(postId: String, kind: String)
    case flagUser(userId: String, kind: String)
    case following
    case followingNewContent(createdAt: Date?)
    case hire(userId: String, body: String)
    case collaborate(userId: String, body: String)
    case infiniteScroll(query: URLComponents, api: ElloAPI)
    case invitations(emails: [String])
    case inviteFriends(email: String)
    case join(email: String, username: String, password: String, invitationCode: String?)
    case locationAutoComplete(terms: String)
    case notificationsNewContent(createdAt: Date?)
    case postComments(postId: String)
    case postDetail(postParam: String)
    case postViews(streamId: String?, streamKind: String, postIds: Set<String>, currentUserId: String?)
    case promotionalViews(tokens: Set<String>)
    case postLovers(postId: String)
    case postReplyAll(postId: String)
    case postRelatedPosts(postId: String)
    case postReposters(postId: String)
    case currentUserBlockedList
    case currentUserMutedList
    case currentUserProfile
    case profileDelete
    case profileToggles
    case profileUpdate(body: [String: Any])
    case pushSubscriptions(token: Data)
    case reAuth(token: String)
    case rePost(postId: String)
    case relationship(userId: String, relationship: String)
    case relationshipBatch(userIds: [String], relationship: String)
    case resetPassword(password: String, authToken: String)
    case requestPasswordReset(email: String)
    case searchForUsers(terms: String)
    case searchForPosts(terms: String)
    case updatePost(postId: String, body: [String: Any])
    case updateComment(postId: String, commentId: String, body: [String: Any])
    case userCategories(categoryIds: Set<String>, onboarding: Bool)
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
        case .userStream:
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
        case .userStream,
             .category:
            return .postsType
        case let .custom(_, api):
            return api.pagingMappingType
        case let .customRequest(_, api):
            return api.pagingMappingType
        default:
            return nil
        }
    }

    var mappingType: MappingType {
        switch self {
        case .anonymousCredentials,
             .auth,
             .reAuth,
             .requestPasswordReset:
            return .noContentType  // We do not current have a "Credentials" model, we interact directly with the keychain
        case .editCategoryUser,
             .createCategoryUser:
            return .categoryUsersType
        case .announcements:
            return .announcementsType
        case .amazonCredentials, .amazonLoggingCredentials:
            return .amazonCredentialsType
        case .availability:
            return .availabilityType
        case .categories,
             .category:
            return .categoriesType
        case .categoryPostActions:
            return .categoryPostsType
        case .artistInvites, .artistInviteDetail:
            return .artistInvitesType
        case .artistInviteSubmissions:
            return .artistInviteSubmissionsType
        case .editorials:
            return .editorials
        case .postReplyAll:
            return .usernamesType
        case .currentUserBlockedList,
             .currentUserMutedList,
             .currentUserProfile,
             .findFriends,
             .join,
             .postLovers,
             .postReposters,
             .profileUpdate,
             .resetPassword,
             .searchForUsers,
             .userStream,
             .userStreamFollowers,
             .userStreamFollowing:
            return .usersType
        case let .custom(_, api):
            return api.mappingType
        case let .customRequest(_, api):
            return api.mappingType
        case .commentDetail,
             .createComment,
             .postComments,
             .updateComment:
            return .commentsType
        case .createLove:
            return .lovesType
        case .categoryPosts,
             .createPost,
             .following,
             .postDetail,
             .postRelatedPosts,
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
             .deleteCategoryUser,
             .deleteComment,
             .deleteLove,
             .deletePost,
             .deleteSubscriptions,
             .flagComment,
             .flagPost,
             .flagUser,
             .followingNewContent,
             .hire,
             .invitations,
             .inviteFriends,
             .markAnnouncementAsRead,
             .notificationsNewContent,
             .postViews,
             .profileDelete,
             .promotionalViews,
             .pushSubscriptions,
             .relationshipBatch,
             .userCategories:
            return .noContentType
        case let .infiniteScroll(_, api):
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

extension ElloAPI: AuthenticationEndpoint {
    var supportsAnonymousToken: Bool {
        switch self {
        case .artistInvites,
             .artistInviteDetail,
             .artistInviteSubmissions,
             .availability,
             .categories,
             .category,
             .categoryPosts,
             .categoryPostActions,
             .deleteSubscriptions,
             .editorials,
             .join,
             .postComments,
             .postDetail,
             .postLovers,
             .postRelatedPosts,
             .postReposters,
             .postViews,
             .promotionalViews,
             .requestPasswordReset,
             .resetPassword,
             .searchForPosts,
             .searchForUsers,
             .userStream,
             .userStreamFollowers,
             .userStreamFollowing,
             .userStreamPosts:
            return true
        case let .custom(_, api):
            return api.supportsAnonymousToken
        case let .customRequest(_, api):
            return api.supportsAnonymousToken
        case let .infiniteScroll(_, api):
            return api.supportsAnonymousToken
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

extension ElloAPI: Moya.TargetType {
    var baseURL: URL { return URL(string: ElloURI.baseURL)! }
    var method: Moya.Method {
        switch self {
        case .anonymousCredentials,
             .auth,
             .availability,
             .createCategoryUser,
             .createComment,
             .createLove,
             .createPost,
             .editCategoryUser,
             .findFriends,
             .flagComment,
             .flagPost,
             .flagUser,
             .hire,
             .collaborate,
             .invitations,
             .inviteFriends,
             .join,
             .pushSubscriptions,
             .reAuth,
             .relationship,
             .relationshipBatch,
             .rePost,
             .requestPasswordReset,
             .createWatchPost:
            return .post
        case .resetPassword,
             .userCategories:
            return .put
        case .deleteCategoryUser,
             .deleteComment,
             .deleteLove,
             .deletePost,
             .deleteSubscriptions,
             .deleteWatchPost,
             .profileDelete:
            return .delete
        case .followingNewContent,
             .announcementsNewContent,
             .notificationsNewContent:
            return .head
        case .markAnnouncementAsRead,
             .profileUpdate,
             .updateComment,
             .updatePost:
            return .patch
        case let .custom(_, api):
            return api.method
        case let .customRequest(request, _):
            return request.method
        case let .infiniteScroll(_, api):
            return api.method
        default:
            return .get
        }
    }

    var defaultPrefix: String {
        return "/api/v2"
    }

    var path: String {
        switch self {
        case .amazonCredentials:
            return "\(defaultPrefix)/assets/credentials"
        case .amazonLoggingCredentials:
            return "\(defaultPrefix)/assets/logging"
        case .announcements,
             .announcementsNewContent:
            return "\(defaultPrefix)/most_recent_announcements"
        case .artistInvites, .artistInviteSubmissions:
            return "\(defaultPrefix)/artist_invites"
        case let .artistInviteDetail(id):
            return "\(defaultPrefix)/artist_invites/\(id)"
        case .markAnnouncementAsRead:
            return "\(ElloAPI.announcements.path)/mark_last_read_announcement"
        case .anonymousCredentials,
             .auth,
             .reAuth:
            return "/api/oauth/token"
        case let .custom(url, _):
            return url.path
        case let .customRequest(request, _):
            return request.url.path
        case .editorials:
            return "\(defaultPrefix)/editorials"
        case .resetPassword:
            return "\(defaultPrefix)/reset_password"
        case .requestPasswordReset:
            return "\(defaultPrefix)/forgot-password"
        case .availability:
            return "\(defaultPrefix)/availability"
        case let .commentDetail(postId, commentId):
            return "\(defaultPrefix)/posts/\(postId)/comments/\(commentId)"
        case .categories:
            return "\(defaultPrefix)/categories"
        case .categoryPostActions:
            return "\(defaultPrefix)/category_posts"
        case let .category(slug):
            return "\(defaultPrefix)/categories/\(slug)"
        case let .categoryPosts(slug):
            return "\(defaultPrefix)/categories/\(slug)/posts/recent"
        case .createCategoryUser:
            return "\(defaultPrefix)/category_users"
        case let .createComment(parentPostId, _):
            return "\(defaultPrefix)/posts/\(parentPostId)/comments"
        case let .createLove(postId):
            return "\(defaultPrefix)/posts/\(postId)/loves"
        case .createPost,
             .rePost:
            return "\(defaultPrefix)/posts"
        case let .createWatchPost(postId):
            return "\(defaultPrefix)/posts/\(postId)/watches"
        case let .deleteCategoryUser(id):
            return "\(defaultPrefix)/category_users/\(id)"
        case let .deleteComment(postId, commentId):
            return "\(defaultPrefix)/posts/\(postId)/comments/\(commentId)"
        case let .deleteLove(postId):
            return "\(defaultPrefix)/posts/\(postId)/love"
        case let .deletePost(postId):
            return "\(defaultPrefix)/posts/\(postId)"
        case let .deleteSubscriptions(tokenData):
            return "\(ElloAPI.currentUserProfile.path)/push_subscriptions/apns/\(tokenStringFromData(tokenData))"
        case let .deleteWatchPost(postId):
            return "\(defaultPrefix)/posts/\(postId)/watch"
        case .editCategoryUser:
            return "\(defaultPrefix)/category_users/"
        case .emojiAutoComplete:
            return "\(defaultPrefix)/emoji/autocomplete"
        case .findFriends:
            return "\(defaultPrefix)/profile/find_friends"
        case let .flagComment(postId, commentId, kind):
            return "\(defaultPrefix)/posts/\(postId)/comments/\(commentId)/flag/\(kind)"
        case let .flagPost(postId, kind):
            return "\(defaultPrefix)/posts/\(postId)/flag/\(kind)"
        case let .flagUser(userId, kind):
            return "\(defaultPrefix)/users/\(userId)/flag/\(kind)"
        case .followingNewContent,
             .following:
            return "\(defaultPrefix)/following/posts/recent"
        case let .hire(userId, _):
            return "\(defaultPrefix)/users/\(userId)/hire_me"
        case let .collaborate(userId, _):
            return "\(defaultPrefix)/users/\(userId)/collaborate"
        case let .infiniteScroll(query, api):
            return api.pagingPath ?? query.path
        case .invitations,
             .inviteFriends:
            return "\(defaultPrefix)/invitations"
        case .join:
            return "\(defaultPrefix)/join"
        case .locationAutoComplete:
            return "\(defaultPrefix)/profile/location_autocomplete"
        case .notificationsNewContent:
            return "\(defaultPrefix)/notifications"
        case let .postComments(postId):
            return "\(defaultPrefix)/posts/\(postId)/comments"
        case let .postDetail(postParam):
            return "\(defaultPrefix)/posts/\(postParam)"
        case .postViews, .promotionalViews:
            return "\(defaultPrefix)/post_views"
        case let .postLovers(postId):
            return "\(defaultPrefix)/posts/\(postId)/lovers"
        case let .postReplyAll(postId):
            return "\(defaultPrefix)/posts/\(postId)/commenters_usernames"
        case let .postRelatedPosts(postId):
            return "\(defaultPrefix)/posts/\(postId)/related"
        case let .postReposters(postId):
            return "\(defaultPrefix)/posts/\(postId)/reposters"
        case .currentUserProfile,
             .profileUpdate,
             .profileDelete:
            return "\(defaultPrefix)/profile"
        case .currentUserBlockedList:
            return "\(defaultPrefix)/profile/blocked"
        case .currentUserMutedList:
            return "\(defaultPrefix)/profile/muted"
        case .profileToggles:
            return "\(ElloAPI.currentUserProfile.path)/settings"
        case let .pushSubscriptions(tokenData):
            return "\(ElloAPI.currentUserProfile.path)/push_subscriptions/apns/\(tokenStringFromData(tokenData))"
        case let .relationship(userId, relationship):
            return "\(defaultPrefix)/users/\(userId)/add/\(relationship)"
        case .relationshipBatch:
            return "\(defaultPrefix)/relationships/batches"
        case .searchForPosts:
            return "\(defaultPrefix)/posts"
        case .searchForUsers:
            return "\(defaultPrefix)/users"
        case let .updatePost(postId, _):
            return "\(defaultPrefix)/posts/\(postId)"
        case let .updateComment(postId, commentId, _):
            return "\(defaultPrefix)/posts/\(postId)/comments/\(commentId)"
        case .userCategories:
            return "\(ElloAPI.currentUserProfile.path)/followed_categories"
        case let .userStream(userParam):
            return "\(defaultPrefix)/users/\(userParam)"
        case let .userStreamFollowers(userId):
            return "\(ElloAPI.userStream(userParam: userId).path)/followers"
        case let .userStreamFollowing(userId):
            return "\(ElloAPI.userStream(userParam: userId).path)/following"
        case let .userStreamPosts(userId):
            return "\(ElloAPI.userStream(userParam: userId).path)/posts"
        case .userNameAutoComplete:
            return "\(defaultPrefix)/users/autocomplete"
        }
    }

    var stubbedNetworkResponse: EndpointSampleResponse {
        switch self {
        case .postComments:
            let target = URL(string: url(self))!
            let response = HTTPURLResponse(url: target, statusCode: 200, httpVersion: "1.1", headerFields: [
                "Link": "<\(target)?before=2014-06-03T00%3A00%3A00.000000000%2B0000>; rel=\"next\""
                ])!
            return .response(response, sampleData)
        default:
            return .networkResponse(200, sampleData)
        }
    }

    var sampleData: Data {
        switch self {
        case .announcements:
            return stubbedData("announcements")
        case .amazonCredentials, .amazonLoggingCredentials:
            return stubbedData("amazon-credentials")
        case .anonymousCredentials,
             .auth,
             .reAuth:
            return stubbedData("auth")
        case .artistInvites, .artistInviteDetail, .artistInviteSubmissions:
            return stubbedData("artist_invites")
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
        case .categoryPostActions:
            return stubbedData("empty")
        case .announcementsNewContent,
             .markAnnouncementAsRead,
             .createCategoryUser,
             .deleteCategoryUser,
             .deleteComment,
             .deleteLove,
             .deletePost,
             .deleteSubscriptions,
             .deleteWatchPost,
             .editCategoryUser,
             .followingNewContent,
             .hire,
             .collaborate,
             .invitations,
             .inviteFriends,
             .notificationsNewContent,
             .profileDelete,
             .postViews,
             .promotionalViews,
             .pushSubscriptions,
             .flagComment,
             .flagPost,
             .flagUser,
             .userCategories,
             .resetPassword,
             .requestPasswordReset:
            return stubbedData("empty")
        case .categoryPosts:
            return stubbedData("users_posts")
        case .editorials:
            return stubbedData("editorials")
        case .emojiAutoComplete:
            return stubbedData("users_getting_a_list_for_autocompleted_usernames")
        case .findFriends:
            return stubbedData("find-friends")
        case .following:
            return stubbedData("activity_streams_friend_stream")
        case let .custom(_, api):
            return api.sampleData
        case let .customRequest(_, api):
            return api.sampleData
        case let .infiniteScroll(_, api):
            return api.sampleData
        case .join:
            return stubbedData("users_registering_an_account")
        case .locationAutoComplete:
            return stubbedData("users_getting_a_list_for_autocompleted_locations")
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
        case .postRelatedPosts:
            return stubbedData("posts_searching_for_posts")
        case .currentUserBlockedList:
            return stubbedData("profile_listing_blocked_users")
        case .currentUserMutedList:
            return stubbedData("profile_listing_muted_users")
        case .currentUserProfile:
            return stubbedData("profile")
        case .profileToggles:
            return stubbedData("profile_available_user_profile_toggles")
        case .profileUpdate:
            return stubbedData("profile_updating_user_profile_and_settings")
        case let .relationship(_, relationship):
            switch RelationshipPriority(rawValue: relationship)! {
            case .following:
                return stubbedData("relationship_following")
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
        if method == .get || method == .head {
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
        return .requestParameters(parameters: parameters ?? [:], encoding: parameterEncoding)
    }

    var headers: [String: String]? {
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

        if requiresAnyToken, let authToken = AuthToken().tokenWithBearer {
            assigned += [
                "Authorization": authToken,
            ]
        }

        if let extensionHeaders = extensionHeaders {
            assigned += extensionHeaders
        }

        let createdAtHeader: String?
        switch self {
        case let .announcementsNewContent(createdAt):
            createdAtHeader = createdAt?.toHTTPDateString()
        case let .followingNewContent(createdAt):
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
                "client_id": APIKeys.shared.key,
                "client_secret": APIKeys.shared.secret,
                "grant_type": "client_credentials",
            ]
        case let .auth(email, password):
            return [
                "client_id": APIKeys.shared.key,
                "client_secret": APIKeys.shared.secret,
                "email": email,
                "password": password,
                "grant_type": "password",
            ]
        case let .availability(content):
            return content as [String: Any]?
        case let .custom(url, _):
            guard let queryString = url.query else { return nil }
            return convertQueryParams(queryString)
        case let .customRequest(request, _):
            if let parameters = request.parameters {
                return parameters
            }
            else if request.method == .get,
                let queryString = request.url.query
            {
                return convertQueryParams(queryString)
            }
            return nil
        case .currentUserProfile:
            return [
                "post_count": 0
            ]
        case let .createCategoryUser(categoryId, userId, role):
            return [
                "category_id": categoryId,
                "user_id": userId,
                "role": role,
            ]
        case let .createComment(_, body):
            return body
        case let .createPost(body):
            return body
        case .categories:
            return [
                "meta": true,
            ]
        case .categoryPosts,
             .following,
             .postComments,
             .userStreamPosts:
            return [
                "per_page": 10,
            ]
        case let .collaborate(_, body):
            return [
                "body": body
            ]
        case let .editCategoryUser(categoryId, userId, role):
            return [
                "category_id": categoryId,
                "user_id": userId,
                "role": role,
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
            return ["contacts": hashedContacts]
        case let .hire(_, body):
            return [
                "body": body
            ]
        case let .infiniteScroll(query, api):
            guard let queryItems = query.queryItems else { return nil }

            var queryDict = [String: Any]()
            for item in queryItems {
                queryDict[item.name] = item.value
            }
            var origDict = api.parameters ?? [String: Any]()
            origDict.merge(queryDict)
            return origDict
        case let .invitations(emails):
            return ["email": emails]
        case let .inviteFriends(email):
            return ["email": email]
        case let .join(email, username, password, invitationCode):
            var params = [
                "email": email,
                "username": username,
                "password": password,
                "password_confirmation": password
            ]
            if let invitationCode = invitationCode {
                params["invitation_code"] = invitationCode
            }
            return params as [String: Any]?
        case let .locationAutoComplete(terms):
            return [
                "location": terms
            ]
        case .postDetail:
            return [
                "comment_count": 0,
            ]
        case .postRelatedPosts:
            return [
                "per_page": 4,
            ]
        case let .postViews(streamId, streamKind, postIds, userId):
            let streamIdDict: [String: String] = streamId.map { streamId in return ["id": streamId]} ?? [:]
            let userIdDict: [String: String] = userId.map { userId in return ["user_id": userId]} ?? [:]
            return [
                "post_ids": postIds.reduce("") { memo, id in
                    if memo == "" { return id }
                    else { return "\(memo),\(id)" }
                },
                "kind": streamKind,
            ] + streamIdDict + userIdDict
        case let .promotionalViews(tokens):
            return [
                "tokens": tokens.reduce("") { memo, id in
                    if memo == "" { return id }
                    else { return "\(memo),\(id)" }
                },
                "kind": "promo",
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
                "bundle_identifier": bundleIdentifier,
                "marketing_version": bundleShortVersionString,
                "build_version": bundleVersion
            ]
        case let .reAuth(refreshToken):
            return [
                "client_id": APIKeys.shared.key,
                "client_secret": APIKeys.shared.secret,
                "grant_type": "refresh_token",
                "refresh_token": refreshToken
            ]
        case let .relationshipBatch(userIds, relationship):
            return [
                "user_ids": userIds,
                "priority": relationship
            ]
        case let .rePost(postId):
            return [ "repost_id": Int(postId) ?? -1 ]
        case let .resetPassword(password, token):
            return [
                "password": password,
                "reset_password_token": token,
            ]
        case let .requestPasswordReset(email):
            return [ "email": email ]
        case let .searchForPosts(terms):
            return [
                "terms": terms,
                "per_page": 10
            ]
        case let .searchForUsers(terms):
            return [
                "terms": terms,
                "per_page": 10
            ]
        case let .updatePost(_, body):
            return body
        case let .updateComment(_, _, body):
            return body
        case let .userCategories(categoryIds, onboarding):
            return [
                "followed_category_ids": Array(categoryIds),
                "disable_follows": !onboarding,
            ]
        case let .userNameAutoComplete(terms):
            return [
                "terms": terms
            ]
        case .userStream:
            return [
                "post_count": "false"
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
    return String((data as NSData).description.filter { !"<> ".contains($0) })
}

func += <KeyType, ValueType> (left: inout [KeyType: ValueType], right: [KeyType: ValueType]) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}

func convertQueryParams(_ query: String) -> [String: Any] {
    var params: [String: Any] = [:]
    for value in query.split("&") {
        let kv = value.split("=")
        guard kv.count == 2 else { continue }
        let (key, value) = (kv[0].urlDecoded(), kv[1].urlDecoded())

        if key.hasSuffix("[]") {
            let arrayKey = key.replacingOccurrences(of: "[]", with: "")
            let paramsArray: [Any] = params[arrayKey] as? [Any] ?? []
            params[arrayKey] = paramsArray + [value]
        }
        else {
            params[key] = value
        }
    }
    return params
}
