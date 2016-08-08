////
///  StreamCellItemParser.swift
//

import Foundation

public struct StreamCellItemParser {

    public init(){}

    public func parse(items: [JSONAble], streamKind: StreamKind, currentUser: User? = nil) -> [StreamCellItem] {
        let viewsAdultContent = currentUser?.viewsAdultContent ?? false
        let filteredItems = streamKind.filter(items, viewsAdultContent: viewsAdultContent)
        if let posts = filteredItems as? [Post] {
            return postCellItems(posts, streamKind: streamKind)
        }
        if let comments = filteredItems as? [ElloComment] {
            return commentCellItems(comments)
        }
        if let notifications = filteredItems as? [Notification] {
            return notificationCellItems(notifications)
        }
        if let users = filteredItems as? [User] {
            return userCellItems(users, streamkind: streamKind)
        }
        if let conversations = filteredItems as? [Conversation] {
            return conversationCellItems(conversations)
        }
        return []
    }

// MARK: - Private

    private func notificationCellItems(notifications: [Notification]) -> [StreamCellItem] {
        return notifications.map { notification in
            return StreamCellItem(jsonable: notification, type: .Notification)
        }
    }

    private func postCellItems(posts: [Post], streamKind: StreamKind) -> [StreamCellItem] {
        var cellItems: [StreamCellItem] = []
        for post in posts {
            cellItems.append(StreamCellItem(jsonable: post, type: .Header))
            cellItems += postToggleItems(post)
            if post.isRepost {
                // add repost content
                // this is weird, but the post summary is actually the repost summary on reposts
                if streamKind.isGridView {
                    cellItems += regionItems(post, content: post.summary)
                }
                else if let repostContent = post.repostContent {
                    cellItems += regionItems(post, content: repostContent)
                    // add additional content
                    if let content = post.content {
                        cellItems += regionItems(post, content: content)
                    }
                }
            }
            else {
                if let content = streamKind.contentForPost(post) {
                    cellItems += regionItems(post, content: content)
                }
            }
            cellItems += footerStreamCellItems(post)
            cellItems += [StreamCellItem(jsonable: post, type: .Spacer(height: 10.0))]
        }
        // set initial state on the items, but don't toggle the footer's state, it is used by comment open/closed
        for item in cellItems {
            if let post = item.jsonable as? Post where item.type != StreamCellType.Footer {
                item.state = post.collapsed ? .Collapsed : .Expanded
            }
        }
        return cellItems
    }

    private func commentCellItems(comments: [ElloComment]) -> [StreamCellItem] {
        var cellItems: [StreamCellItem] = []
        for comment in comments {
            cellItems.append(StreamCellItem(jsonable: comment, type: .CommentHeader))
            cellItems += regionItems(comment, content: comment.content)
        }
        return cellItems
    }

    private func postToggleItems(post: Post) -> [StreamCellItem] {
        if post.collapsed {
            return [StreamCellItem(jsonable: post, type: .Toggle)]
        }
        else {
            return []
        }
    }

    private func regionItems(jsonable: JSONAble, content: [Regionable]) -> [StreamCellItem] {
        var cellArray: [StreamCellItem] = []
        for region in content {
            let kind = RegionKind(rawValue: region.kind) ?? .Unknown
            let types = kind.streamCellTypes(region)
            for type in types {
                if type != .Unknown {
                    let item: StreamCellItem = StreamCellItem(jsonable: jsonable, type: type)
                    cellArray.append(item)
                }
            }
        }
        return cellArray
    }

    private func userCellItems(users: [User], streamkind: StreamKind) -> [StreamCellItem] {
        let type: StreamCellType
        if case .CreateConversation = streamkind {
            type = .ConversationMemberSelection
        }
        else {
            type = .UserListItem
        }
        return users.map { user in
            return StreamCellItem(jsonable: user, type: type)
        }
    }

    private func conversationCellItems(conversations: [Conversation]) -> [StreamCellItem] {
        return conversations.map { convo in
            return StreamCellItem(jsonable: convo, type: .Conversation)
        }
    }

    private func footerStreamCellItems(post: Post) -> [StreamCellItem] {
        return [StreamCellItem(jsonable: post, type: .Footer)]
    }
}


// MARK: For Testing
public extension StreamCellItemParser {
    public func testingNotificationCellItems(notifications: [Notification]) -> [StreamCellItem] {
        return notificationCellItems(notifications)
    }
    public func testingPostCellItems(posts: [Post], streamKind: StreamKind) -> [StreamCellItem] {
        return postCellItems(posts, streamKind: streamKind)
    }
    public func testingCommentCellItems(comments: [ElloComment]) -> [StreamCellItem] {
        return commentCellItems(comments)
    }
    public func testingPostToggleItems(post: Post) -> [StreamCellItem] {
        return postToggleItems(post)
    }
    public func testingRegionItems(jsonable: JSONAble, content: [Regionable]) -> [StreamCellItem] {
        return regionItems(jsonable, content: content)
    }
    public func testingUserCellItems(users: [User]) -> [StreamCellItem] {
        return userCellItems(users, streamkind: .Unknown)
    }
    public func testingFooterStreamCellItems(post: Post) -> [StreamCellItem] {
        return footerStreamCellItems(post)
    }
}
