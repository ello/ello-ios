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

    var debugDescription: String {
        switch self {
        case let .announcementsNewContent(createdAt):
            return "AnnouncementsNewContent(createdAt: \(createdAt))"
        case let .commentDetail(postId, commentId):
            return "CommentDetail(postId: \(postId), commentId: \(commentId))"
        case let .createComment(parentPostId, _):
            return "CreateComment(parentPostId: \(parentPostId))"
        case let .createLove(postId):
            return "CreateLove(postId: \(postId))"
        case let .createWatchPost(postId):
            return "CreateWatchPost(postId: \(postId))"
        case let .deleteComment(postId, commentId):
            return "DeleteComment(postId: \(postId), commentId: \(commentId))"
        case let .deleteLove(postId):
            return "DeleteLove(postId: \(postId))"
        case let .deletePost(postId):
            return "DeletePost(postId: \(postId))"
        case let .deleteSubscriptions(tokenData):
            return "DeleteSubscriptions(tokenData: \(tokenData))"
        case let .deleteWatchPost(postId):
            return "DeleteWatchPost(postId: \(postId))"
        case let .discover(type):
            return "Discover(type: \(type))"
        case let .categoryPosts(slug):
            return "CategoryPosts(slug: \(slug))"
        case let .emojiAutoComplete(terms):
            return "EmojiAutoComplete(terms: \(terms))"
        case .flagComment:
            return "FlagComment"
        case let .flagPost(postId, kind):
            return "FlagPost(postId: \(postId), kind: \(kind))"
        case let .flagUser(userId, kind):
            return "FlagUser(userId: \(userId), kind: \(kind))"
        case let .friendNewContent(createdAt):
            return "FriendNewContent(createdAt: \(createdAt))"
        case let .hire(userId, body):
            return "Hire(userId: \(userId), body: \(body.characters.count))"
        case let .collaborate(userId, body):
            return "Collaborate(userId: \(userId), body: \(body.characters.count))"
        case let .infiniteScroll(_, elloApi):
            return "InfiniteScroll(elloApi: \(elloApi()))"
        case let .loves(userId):
            return "Loves(userId: \(userId))"
        case let .locationAutoComplete(terms):
            return "LocationAutoComplete(terms: \(terms))"
        case let .noiseNewContent(createdAt):
            return "NoiseNewContent(createdAt: \(createdAt))"
        case let .notificationsNewContent(createdAt):
            return "NotificationsNewContent(createdAt: \(createdAt))"
        case let .postComments(postId):
            return "PostComments(postId: \(postId))"
        case let .postDetail(postParam, commentCount):
            return "PostDetail(postParam: \(postParam), commentCount: \(commentCount))"
        case let .postLovers(postId):
            return "PostLovers(postId: \(postId))"
        case let .postReplyAll(postId):
            return "PostReplyAll(postId: \(postId))"
        case let .postReposters(postId):
            return "PostReposters(postId: \(postId))"
        case let .pushSubscriptions(tokenData):
            return "PushSubscriptions(tokenData: \(tokenData))"
        case let .relationship(userId, relationship):
            return "Relationship(userId: \(userId), relationship: \(relationship))"
        case let .relationshipBatch(userIds, relationship):
            return "RelationshipBatch(userIds: \(userIds), relationship: \(relationship))"
        case let .updatePost(postId, _):
            return "UpdatePost(postId: \(postId))"
        case let .updateComment(postId, commentId, _):
            return "UpdateComment(postId: \(postId), commentId: \(commentId))"
        case let .userCategories(categoryIds):
            return "UserCategories(categoryIds: \(categoryIds))"
        case let .userStream(userParam):
            return "UserStream(userParam: \(userParam))"
        case let .userStreamFollowers(userId):
            return "UserStreamFollowers(userId: \(userId))"
        case let .userStreamFollowing(userId):
            return "UserStreamFollowing(userId: \(userId))"
        case let .userNameAutoComplete(terms):
            return "UserNameAutoComplete(terms: \(terms))"
        default:
            return description
        }
    }
    var description: String {
        switch self {
        case .announcements:
            return "Announcements"
        case .announcementsNewContent:
            return "AnnouncementsNewContent"
        case .amazonCredentials:
            return "AmazonCredentials"
        case .anonymousCredentials:
            return "AnonymousCredentials"
        case .auth:
            return "Auth"
        case .reAuth:
            return "ReAuth"
        case .availability:
            return "Availability"
        case .categories:
            return "Categories"
        case .commentDetail:
            return "CommentDetail"
        case .createComment:
            return "CreateComment"
        case .createLove:
            return "CreateLove"
        case .createPost:
            return "CreatePost"
        case .createWatchPost:
            return "CreateWatchPost"
        case .currentUserBlockedList:
            return "CurrentUserBlockedList"
        case .currentUserMutedList:
            return "CurrentUserMutedList"
        case .currentUserProfile:
            return "CurrentUserProfile"
        case .currentUserStream:
            return "CurrentUserStream"
        case .rePost:
            return "RePost"
        case .deleteComment:
            return "DeleteComment"
        case .deleteLove:
            return "DeleteLove"
        case .deletePost:
            return "DeletePost"
        case .deleteWatchPost:
            return "DeleteWatchPost"
        case .deleteSubscriptions:
            return "DeleteSubscriptions"
        case .discover:
            return "Discover"
        case .category:
            return "Category"
        case .categoryPosts:
            return "CategoryPosts"
        case .emojiAutoComplete:
            return "EmojiAutoComplete"
        case .findFriends:
            return "FindFriends"
        case .flagComment:
            return "FlagComment"
        case .flagPost:
            return "FlagPost"
        case .flagUser:
            return "FlagUser"
        case .friendNewContent:
            return "FriendNewContent"
        case .friendStream:
            return "FriendStream"
        case .hire:
            return "Hire"
        case .collaborate:
            return "Collaborate"
        case .infiniteScroll:
            return "InfiniteScroll"
        case .inviteFriends:
            return "InviteFriends"
        case .join:
            return "Join"
        case .loves:
            return "Loves"
        case .locationAutoComplete:
            return "LocationAutoComplete"
        case .markAnnouncementAsRead:
            return "MarkAnnouncementAsRead"
        case .noiseNewContent:
            return "NoiseNewContent"
        case .noiseStream:
            return "NoiseStream"
        case .notificationsNewContent:
            return "NotificationsNewContent"
        case .notificationsStream:
            return "NotificationsStream"
        case .pagePromotionals:
            return "PagePromotionals"
        case .postComments:
            return "PostComments"
        case .postDetail:
            return "PostDetail"
        case .postLovers:
            return "PostLovers"
        case .postReplyAll:
            return "PostReplyAll"
        case .postReposters:
            return "PostReposters"
        case .profileUpdate:
            return "ProfileUpdate"
        case .profileDelete:
            return "ProfileDelete"
        case .profileToggles:
            return "ProfileToggles"
        case .pushSubscriptions:
            return "PushSubscriptions"
        case .relationship:
            return "Relationship"
        case .relationshipBatch:
            return "RelationshipBatch"
        case .searchForPosts:
            return "SearchForPosts"
        case .searchForUsers:
            return "SearchForUsers"
        case .updatePost:
            return "UpdatePost"
        case .updateComment:
            return "UpdateComment"
        case .userCategories:
            return "UserCategories"
        case .userStream:
            return "UserStream"
        case .userStreamFollowers:
            return "UserStreamFollowers"
        case .userStreamFollowing:
            return "UserStreamFollowing"
        case .userStreamPosts:
            return "UserStreamPosts"
        case .userNameAutoComplete:
            return "UserNameAutoComplete"
        }
    }
}
