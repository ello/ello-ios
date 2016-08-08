////
///  ElloAPI.swift
//

extension ElloAPI: CustomStringConvertible, CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .CommentDetail(postId, commentId):
            return "CommentDetail(postId: \(postId), commentId: \(commentId))"
        case let .CreateComment(parentPostId, _):
            return "CreateComment(parentPostId: \(parentPostId))"
        case let .CreateLove(postId):
            return "CreateLove(postId: \(postId))"
        case let .DeleteComment(postId, commentId):
            return "DeleteComment(postId: \(postId), commentId: \(commentId))"
        case let .DeleteLove(postId):
            return "DeleteLove(postId: \(postId))"
        case let .DeletePost(postId):
            return "DeletePost(postId: \(postId))"
        case let .DeleteSubscriptions(tokenData):
            return "DeleteSubscriptions(tokenData: \(tokenData))"
        case let .Discover(type):
            return "Discover(type: \(type))"
        case let .CategoryPosts(slug):
            return "CategoryPosts(slug: \(slug))"
        case let .EmojiAutoComplete(terms):
            return "EmojiAutoComplete(terms: \(terms))"
        case .FlagComment(_, _, _):
            return "FlagComment"
        case let .FlagPost(postId, kind):
            return "FlagPost(postId: \(postId), kind: \(kind))"
        case let .FlagUser(userId, kind):
            return "FlagUser(userId: \(userId), kind: \(kind))"
        case let .InfiniteScroll(_, elloApi):
            return "InfiniteScroll(elloApi: \(elloApi()))"
        case let .Loves(userId):
            return "Loves(userId: \(userId))"
        case let .PostComments(postId):
            return "PostComments(postId: \(postId))"
        case let .PostDetail(postParam, commentCount):
            return "PostDetail(postParam: \(postParam), commentCount: \(commentCount))"
        case let .PostLovers(postId):
            return "PostLovers(postId: \(postId))"
        case let .PostReplyAll(postId):
            return "PostReplyAll(postId: \(postId))"
        case let .PostReposters(postId):
            return "PostReposters(postId: \(postId))"
        case let .PushSubscriptions(tokenData):
            return "PushSubscriptions(tokenData: \(tokenData))"
        case let .Relationship(userId, relationship):
            return "Relationship(userId: \(userId), relationship: \(relationship))"
        case let .RelationshipBatch(userIds, relationship):
            return "RelationshipBatch(userIds: \(userIds), relationship: \(relationship))"
        case let .UpdatePost(postId, _):
            return "UpdatePost(postId: \(postId))"
        case let .UpdateComment(postId, commentId, _):
            return "UpdateComment(postId: \(postId), commentId: \(commentId))"
        case let .UserStream(userParam):
            return "UserStream(userParam: \(userParam))"
        case let .UserStreamFollowers(userId):
            return "UserStreamFollowers(userId: \(userId))"
        case let .UserStreamFollowing(userId):
            return "UserStreamFollowing(userId: \(userId))"
        case let .UserNameAutoComplete(terms):
            return "UserNameAutoComplete(terms: \(terms))"
        default:
            return description
        }
    }
    public var description: String {
        switch self {
        case .AmazonCredentials:
            return "AmazonCredentials"
        case .AnonymousCredentials:
            return "AnonymousCredentials"
        case .Auth:
            return "Auth"
        case .ReAuth:
            return "ReAuth"
        case .Availability:
            return "Availability"
        case .AwesomePeopleStream:
            return "AwesomePeopleStream"
        case .Categories:
            return "Categories"
        case .CommentDetail:
            return "CommentDetail"
        case .CommunitiesStream:
            return "CommunitiesStream"
        case .CreateComment:
            return "CreateComment"
        case .CreateLove:
            return "CreateLove"
        case .CreatePost:
            return "CreatePost"
        case .CurrentUserBlockedList:
            return "CurrentUserBlockedList"
        case .CurrentUserMutedList:
            return "CurrentUserMutedList"
        case .CurrentUserProfile:
            return "CurrentUserProfile"
        case .CurrentUserStream:
            return "CurrentUserStream"
        case .RePost:
            return "RePost"
        case .DeleteComment:
            return "DeleteComment"
        case .DeleteLove:
            return "DeleteLove"
        case .DeletePost:
            return "DeletePost"
        case .DeleteSubscriptions:
            return "DeleteSubscriptions"
        case .Discover:
            return "Discover"
        case .CategoryPosts:
            return "CategoryPosts"
        case .Conversations:
            return "Conversations"
        case .CreateConversation:
            return "CreateConversation"
        case .ConversationMemberPicker:
            return "ConversationMemberPicker"
        case .EmojiAutoComplete:
            return "EmojiAutoComplete"
        case .FindFriends:
            return "FindFriends"
        case .FlagComment:
            return "FlagComment"
        case .FlagPost:
            return "FlagPost"
        case .FlagUser:
            return "FlagUser"
        case .FriendNewContent:
            return "FriendNewContent"
        case .FriendStream:
            return "FriendStream"
        case .InfiniteScroll:
            return "InfiniteScroll"
        case .InviteFriends:
            return "InviteFriends"
        case .Join:
            return "Join"
        case .Loves:
            return "Loves"
        case .NoiseNewContent:
            return "NoiseNewContent"
        case .NoiseStream:
            return "NoiseStream"
        case .NotificationsNewContent:
            return "NotificationsNewContent"
        case .NotificationsStream:
            return "NotificationsStream"
        case .PostComments:
            return "PostComments"
        case .PostDetail:
            return "PostDetail"
        case .PostLovers:
            return "PostLovers"
        case .PostReplyAll:
            return "PostReplyAll"
        case .PostReposters:
            return "PostReposters"
        case .ProfileUpdate:
            return "ProfileUpdate"
        case .ProfileDelete:
            return "ProfileDelete"
        case .ProfileToggles:
            return "ProfileToggles"
        case .PushSubscriptions:
            return "PushSubscriptions"
        case .Relationship:
            return "Relationship"
        case .RelationshipBatch:
            return "RelationshipBatch"
        case .SearchForPosts:
            return "SearchForPosts"
        case .SearchForUsers:
            return "SearchForUsers"
        case .UpdatePost:
            return "UpdatePost"
        case .UpdateComment:
            return "UpdateComment"
        case .UserStream:
            return "UserStream"
        case .UserStreamFollowers:
            return "UserStreamFollowers"
        case .UserStreamFollowing:
            return "UserStreamFollowing"
        case .UserStreamPosts:
            return "UserStreamPosts"
        case .UserNameAutoComplete:
            return "UserNameAutoComplete"
        }
    }
}
