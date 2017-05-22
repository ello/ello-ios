////
///  ElloAPI.swift
//

extension ElloAPI: CustomStringConvertible, CustomDebugStringConvertible {
    var trackerName: String? {
        switch self {
        case .userStreamFollowers:
            return "Followers"
        case .userStreamFollowing:
            return "Following"
        case .loves:
            return "Loves"
        case .currentUserBlockedList:
            return "Blocked"
        case .currentUserMutedList:
            return "Muted"
        case .postLovers:
            return "Post Lovers"
        case .postReposters:
            return "Post Reposters"
        default:
            return nil
        }
    }
    var trackerStreamKind: String? {
        switch self {
        case .loves:
            return "love"
        default:
            return nil
        }
    }
    var trackerStreamId: String? {
        switch self {
        case let .loves(userId):
            return userId
        default:
            return nil
        }
    }

    var debugDescription: String {
        switch self {
        case let .announcementsNewContent(createdAt):
            return "announcementsNewContent(createdAt: \(String(describing: createdAt)))"
        case let .commentDetail(postId, commentId):
            return "commentDetail(postId: \(postId), commentId: \(commentId))"
        case let .createComment(parentPostId, _):
            return "createComment(parentPostId: \(parentPostId))"
        case let .createLove(postId):
            return "createLove(postId: \(postId))"
        case let .createWatchPost(postId):
            return "createWatchPost(postId: \(postId))"
        case let .deleteComment(postId, commentId):
            return "deleteComment(postId: \(postId), commentId: \(commentId))"
        case let .deleteLove(postId):
            return "deleteLove(postId: \(postId))"
        case let .deletePost(postId):
            return "deletePost(postId: \(postId))"
        case let .deleteSubscriptions(tokenData):
            return "deleteSubscriptions(tokenData: \(tokenData))"
        case let .deleteWatchPost(postId):
            return "deleteWatchPost(postId: \(postId))"
        case let .discover(type):
            return "discover(type: \(type))"
        case let .categoryPosts(slug):
            return "categoryPosts(slug: \(slug))"
        case let .emojiAutoComplete(terms):
            return "emojiAutoComplete(terms: \(terms))"
        case .flagComment:
            return "flagComment"
        case let .flagPost(postId, kind):
            return "flagPost(postId: \(postId), kind: \(kind))"
        case let .flagUser(userId, kind):
            return "flagUser(userId: \(userId), kind: \(kind))"
        case let .followingNewContent(createdAt):
            return "followingNewContent(createdAt: \(String(describing: createdAt)))"
        case let .hire(userId, body):
            return "hire(userId: \(userId), body: \(body.characters.count))"
        case let .collaborate(userId, body):
            return "collaborate(userId: \(userId), body: \(body.characters.count))"
        case let .infiniteScroll(_, elloApi):
            return "infiniteScroll(elloApi: \(elloApi()))"
        case let .loves(userId):
            return "loves(userId: \(userId))"
        case let .locationAutoComplete(terms):
            return "locationAutoComplete(terms: \(terms))"
        case let .notificationsNewContent(createdAt):
            return "notificationsNewContent(createdAt: \(String(describing: createdAt)))"
        case let .requestPasswordReset(email):
            return "requestPasswordReset(email: \(email))"
        case let .resetPassword(password, authToken):
            return "resetPassword(password: \(password), authToken: \(authToken))"
        case let .postComments(postId):
            return "postComments(postId: \(postId))"
        case let .postDetail(postParam, commentCount):
            return "postDetail(postParam: \(postParam), commentCount: \(commentCount))"
        case let .postViews(streamId, streamKind, postTokens, currentUserId):
            return "postViews(streamId: \(String(describing: streamId)), streamKind: \(streamKind), postTokens: \(postTokens), currentUserId: \(String(describing: currentUserId)))"
        case let .postLovers(postId):
            return "postLovers(postId: \(postId))"
        case let .postRelatedPosts(postId):
            return "postRelatedPosts(postId: \(postId))"
        case let .postReplyAll(postId):
            return "postReplyAll(postId: \(postId))"
        case let .postReposters(postId):
            return "postReposters(postId: \(postId))"
        case let .pushSubscriptions(tokenData):
            return "pushSubscriptions(tokenData: \(tokenData))"
        case let .relationship(userId, relationship):
            return "relationship(userId: \(userId), relationship: \(relationship))"
        case let .relationshipBatch(userIds, relationship):
            return "relationshipBatch(userIds: \(userIds), relationship: \(relationship))"
        case let .updatePost(postId, _):
            return "updatePost(postId: \(postId))"
        case let .updateComment(postId, commentId, _):
            return "updateComment(postId: \(postId), commentId: \(commentId))"
        case let .userCategories(categoryIds):
            return "userCategories(categoryIds: \(categoryIds))"
        case let .userStream(userParam):
            return "userStream(userParam: \(userParam))"
        case let .userStreamFollowers(userId):
            return "userStreamFollowers(userId: \(userId))"
        case let .userStreamFollowing(userId):
            return "userStreamFollowing(userId: \(userId))"
        case let .userNameAutoComplete(terms):
            return "userNameAutoComplete(terms: \(terms))"
        default:
            return description
        }
    }
    var description: String {
        switch self {
        case .announcements:
            return "announcements"
        case .announcementsNewContent:
            return "announcementsNewContent"
        case .amazonCredentials:
            return "amazonCredentials"
        case .anonymousCredentials:
            return "anonymousCredentials"
        case .auth:
            return "auth"
        case .reAuth:
            return "reAuth"
        case .availability:
            return "availability"
        case .categories:
            return "categories"
        case .commentDetail:
            return "commentDetail"
        case .createComment:
            return "createComment"
        case .createLove:
            return "createLove"
        case .createPost:
            return "createPost"
        case .createWatchPost:
            return "createWatchPost"
        case .currentUserBlockedList:
            return "currentUserBlockedList"
        case .currentUserMutedList:
            return "currentUserMutedList"
        case .currentUserProfile:
            return "currentUserProfile"
        case .currentUserStream:
            return "currentUserStream"
        case .rePost:
            return "rePost"
        case .deleteComment:
            return "deleteComment"
        case .deleteLove:
            return "deleteLove"
        case .deletePost:
            return "deletePost"
        case .deleteWatchPost:
            return "deleteWatchPost"
        case .deleteSubscriptions:
            return "deleteSubscriptions"
        case .discover:
            return "discover"
        case .category:
            return "category"
        case .categoryPosts:
            return "categoryPosts"
        case .editorials:
            return "editorials"
        case .emojiAutoComplete:
            return "emojiAutoComplete"
        case .findFriends:
            return "findFriends"
        case .flagComment:
            return "flagComment"
        case .flagPost:
            return "flagPost"
        case .flagUser:
            return "flagUser"
        case .followingNewContent:
            return "followingNewContent"
        case .following:
            return "following"
        case .hire:
            return "hire"
        case .collaborate:
            return "collaborate"
        case .infiniteScroll:
            return "infiniteScroll"
        case .invitations:
            return "invitations"
        case .inviteFriends:
            return "inviteFriends"
        case .join:
            return "join"
        case .loves:
            return "loves"
        case .locationAutoComplete:
            return "locationAutoComplete"
        case .markAnnouncementAsRead:
            return "markAnnouncementAsRead"
        case .notificationsNewContent:
            return "notificationsNewContent"
        case .notificationsStream:
            return "notificationsStream"
        case .pagePromotionals:
            return "pagePromotionals"
        case .postComments:
            return "postComments"
        case .postDetail:
            return "postDetail"
        case .postLovers:
            return "postLovers"
        case .postRelatedPosts:
            return "postRelatedPosts"
        case .postReplyAll:
            return "postReplyAll"
        case .postReposters:
            return "postReposters"
        case .postViews:
            return "postViews"
        case .profileUpdate:
            return "profileUpdate"
        case .profileDelete:
            return "profileDelete"
        case .profileToggles:
            return "profileToggles"
        case .pushSubscriptions:
            return "pushSubscriptions"
        case .relationship:
            return "relationship"
        case .relationshipBatch:
            return "relationshipBatch"
        case .requestPasswordReset:
            return "requestPasswordReset"
        case .resetPassword:
            return "resetPassword"
        case .searchForPosts:
            return "searchForPosts"
        case .searchForUsers:
            return "searchForUsers"
        case .updatePost:
            return "updatePost"
        case .updateComment:
            return "updateComment"
        case .userCategories:
            return "userCategories"
        case .userStream:
            return "userStream"
        case .userStreamFollowers:
            return "userStreamFollowers"
        case .userStreamFollowing:
            return "userStreamFollowing"
        case .userStreamPosts:
            return "userStreamPosts"
        case .userNameAutoComplete:
            return "userNameAutoComplete"
        }
    }
}
