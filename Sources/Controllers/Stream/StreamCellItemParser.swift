////
///  StreamCellItemParser.swift
//

struct StreamCellItemParser {

    init(){}

    func parse(_ items: [JSONAble], streamKind: StreamKind, forceGrid: Bool = false, currentUser: User? = nil) -> [StreamCellItem] {
        let viewsAdultContent = currentUser?.viewsAdultContent ?? false
        let filteredItems = streamKind.filter(items, viewsAdultContent: viewsAdultContent)
        let streamItems: [StreamCellItem]
        if let posts = filteredItems as? [Post] {
            streamItems = postCellItems(posts, streamKind: streamKind, forceGrid: forceGrid)
        }
        else if let comments = filteredItems as? [ElloComment] {
            streamItems = commentCellItems(comments)
        }
        else if let notifications = filteredItems as? [Notification] {
            streamItems = typicalCellItems(notifications, type: .notification)
        }
        else if let announcements = filteredItems as? [Announcement] {
            streamItems = typicalCellItems(announcements, type: .announcement)
        }
        else if let users = filteredItems as? [User] {
            streamItems = typicalCellItems(users, type: .userListItem)
        }
        else if let editorials = filteredItems as? [Editorial] {
            streamItems = editorialCellItems(editorials)
        }
        else {
            streamItems = []
        }
        _ = streamItems.map { $0.forceGrid = forceGrid }
        return streamItems
    }

// MARK: - Private

    fileprivate func typicalCellItems(_ jsonables: [JSONAble], type: StreamCellType) -> [StreamCellItem] {
        return jsonables.map { jsonable in
            return StreamCellItem(jsonable: jsonable, type: type)
        }
    }

    fileprivate func editorialCellItems(_ editorials: [Editorial]) -> [StreamCellItem] {
        return editorials.map { editorial in
            return StreamCellItem(jsonable: editorial, type: .editorial(editorial.kind))
        }
    }

    fileprivate func postCellItems(_ posts: [Post], streamKind: StreamKind, forceGrid: Bool) -> [StreamCellItem] {
        var cellItems: [StreamCellItem] = []
        let isGridView = streamKind.isGridView || forceGrid
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
                if isGridView {
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
                if let content = post.contentFor(gridView: isGridView) {
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
            for type in types where type != .unknown {
                let item: StreamCellItem = StreamCellItem(jsonable: jsonable, type: type)
                cellArray.append(item)
            }
        }
        return cellArray
    }

    fileprivate func footerStreamCellItems(_ post: Post) -> [StreamCellItem] {
        return [StreamCellItem(jsonable: post, type: .footer)]
    }
}


// MARK: For Testing
extension StreamCellItemParser {
    func testingTypicalCellItems(_ jsonables: [JSONAble], type: StreamCellType) -> [StreamCellItem] {
        return typicalCellItems(jsonables, type: type)
    }
    func testingPostCellItems(_ posts: [Post], streamKind: StreamKind, forceGrid: Bool) -> [StreamCellItem] {
        return postCellItems(posts, streamKind: streamKind, forceGrid: forceGrid)
    }
    func testingCommentCellItems(_ comments: [ElloComment]) -> [StreamCellItem] {
        return commentCellItems(comments)
    }
}
