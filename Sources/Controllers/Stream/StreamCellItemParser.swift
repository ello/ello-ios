////
///  StreamCellItemParser.swift
//

import Foundation

struct StreamCellItemParser {

    init(){}

    func parse(_ items: [JSONAble], streamKind: StreamKind, currentUser: User? = nil) -> [StreamCellItem] {
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
        if let announcements = filteredItems as? [Announcement] {
            return announcementCellItems(announcements)
        }
        if let users = filteredItems as? [User] {
            return userCellItems(users)
        }
        return []
    }

// MARK: - Private

    fileprivate func notificationCellItems(_ notifications: [Notification]) -> [StreamCellItem] {
        return notifications.map { notification in
            return StreamCellItem(jsonable: notification, type: .notification)
        }
    }

    fileprivate func announcementCellItems(_ announcements: [Announcement]) -> [StreamCellItem] {
        return announcements.map { announcement in
            return StreamCellItem(jsonable: announcement, type: .announcement)
        }
    }

    fileprivate func postCellItems(_ posts: [Post], streamKind: StreamKind) -> [StreamCellItem] {
        var cellItems: [StreamCellItem] = []
        for post in posts {
            if !streamKind.isProfileStream || post.isRepost {
                cellItems.append(StreamCellItem(jsonable: post, type: .header))
            }
            else {
                cellItems.append(StreamCellItem(jsonable: post, type: .spacer(height: 30)))
            }
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
            cellItems += [StreamCellItem(jsonable: post, type: .spacer(height: 10))]
        }
        // set initial state on the items, but don't toggle the footer's state, it is used by comment open/closed
        for item in cellItems {
            if let post = item.jsonable as? Post, item.type != StreamCellType.footer {
                item.state = post.collapsed ? .collapsed : .expanded
            }
        }
        return cellItems
    }

    fileprivate func commentCellItems(_ comments: [ElloComment]) -> [StreamCellItem] {
        var cellItems: [StreamCellItem] = []
        for comment in comments {
            cellItems.append(StreamCellItem(jsonable: comment, type: .commentHeader))
            cellItems += regionItems(comment, content: comment.content)
        }
        return cellItems
    }

    fileprivate func postToggleItems(_ post: Post) -> [StreamCellItem] {
        if post.collapsed {
            return [StreamCellItem(jsonable: post, type: .toggle)]
        }
        else {
            return []
        }
    }

    fileprivate func regionItems(_ jsonable: JSONAble, content: [Regionable]) -> [StreamCellItem] {
        var cellArray: [StreamCellItem] = []
        for region in content {
            let kind = RegionKind(rawValue: region.kind) ?? .unknown
            let types = kind.streamCellTypes(region)
            for type in types {
                if type != .unknown {
                    let item: StreamCellItem = StreamCellItem(jsonable: jsonable, type: type)
                    cellArray.append(item)
                }
            }
        }
        return cellArray
    }

    fileprivate func userCellItems(_ users: [User]) -> [StreamCellItem] {
        return users.map { user in
            return StreamCellItem(jsonable: user, type: .userListItem)
        }
    }

    fileprivate func footerStreamCellItems(_ post: Post) -> [StreamCellItem] {
        return [StreamCellItem(jsonable: post, type: .footer)]
    }
}


// MARK: For Testing
extension StreamCellItemParser {
    func testingNotificationCellItems(_ notifications: [Notification]) -> [StreamCellItem] {
        return notificationCellItems(notifications)
    }
    func testingPostCellItems(_ posts: [Post], streamKind: StreamKind) -> [StreamCellItem] {
        return postCellItems(posts, streamKind: streamKind)
    }
    func testingCommentCellItems(_ comments: [ElloComment]) -> [StreamCellItem] {
        return commentCellItems(comments)
    }
    func testingPostToggleItems(_ post: Post) -> [StreamCellItem] {
        return postToggleItems(post)
    }
    func testingRegionItems(_ jsonable: JSONAble, content: [Regionable]) -> [StreamCellItem] {
        return regionItems(jsonable, content: content)
    }
    func testingUserCellItems(_ users: [User]) -> [StreamCellItem] {
        return userCellItems(users)
    }
    func testingFooterStreamCellItems(_ post: Post) -> [StreamCellItem] {
        return footerStreamCellItems(post)
    }
}
