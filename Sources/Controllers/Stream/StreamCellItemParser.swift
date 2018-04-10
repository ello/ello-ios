////
///  StreamCellItemParser.swift
//

struct StreamCellItemParser {

    func parse(_ items: [JSONAble], streamKind: StreamKind, forceGrid: Bool = false, currentUser: User? = nil) -> [StreamCellItem] {
        let viewsAdultContent = currentUser?.viewsAdultContent ?? false
        let isGridView = forceGrid || streamKind.isGridView
        let filteredItems = streamKind.filter(items, viewsAdultContent: viewsAdultContent)
        var streamItems: [StreamCellItem] = []
        for item in filteredItems {
            if let post = item as? Post {
                streamItems += postCellItems(post, streamKind: streamKind, isGridView: isGridView, currentUser: currentUser)
            }
            else if let submission = item as? ArtistInviteSubmission {
                streamItems += submissionCellItems(submission, streamKind: streamKind, isGridView: isGridView, currentUser: currentUser)
            }
            else if let comment = item as? ElloComment {
                streamItems += commentCellItems(comment)
            }
            else if let notification = item as? Notification {
                streamItems += typicalCellItems(notification, type: .notification)
            }
            else if let announcement = item as? Announcement {
                streamItems += typicalCellItems(announcement, type: .announcement)
            }
            else if let user = item as? User {
                streamItems += typicalCellItems(user, type: .userListItem)
            }
            else if let editorial = item as? Editorial {
                streamItems += editorialCellItems(editorial)
            }
            else if let category = item as? Category, case .manageCategories = streamKind {
                streamItems += typicalCellItems(category, type: .categorySubscribeCard)
            }
            else if let artistInvite = item as? ArtistInvite {
                if case .artistInvites = streamKind {
                    streamItems += typicalCellItems(artistInvite, type: .artistInviteBubble)
                }
                else {
                    streamItems += artistInviteDetailItems(artistInvite)
                }
            }
        }
        _ = streamItems.map { $0.forceGrid = forceGrid }
        return streamItems
    }

    private func typicalCellItems(_ jsonable: JSONAble, type: StreamCellType) -> [StreamCellItem] {
        return [StreamCellItem(jsonable: jsonable, type: type)]
    }

    private func editorialCellItems(_ editorial: Editorial) -> [StreamCellItem] {
        return [StreamCellItem(jsonable: editorial, type: .editorial(editorial.kind))]
    }

    private func artistInviteDetailItems(_ artistInvite: ArtistInvite) -> [StreamCellItem] {
        return [
            StreamCellItem(jsonable: artistInvite, type: .artistInviteHeader, placeholderType: .artistInvites),
            // <-- the ↓submissions button goes here, so to separate these items we tag the placeholderType
            // the submissions button isn't inserted until the submission posts are loaded
            StreamCellItem(jsonable: artistInvite, type: .artistInviteControls, placeholderType: .artistInviteDetails),
        ] + artistInvite.guide.map({ StreamCellItem(jsonable: artistInvite, type: .artistInviteGuide($0), placeholderType: .artistInviteDetails) })
        + [StreamCellItem(jsonable: artistInvite, type: .spacer(height: 30), placeholderType: .artistInviteDetails)]
    }

    private func submissionCellItems(_ submission: ArtistInviteSubmission, streamKind: StreamKind, isGridView: Bool, currentUser: User?) -> [StreamCellItem] {
        guard let post = submission.post else { return [] }

        return postCellItems(post, streamKind: streamKind, isGridView: isGridView, currentUser: currentUser, submission: submission)
    }

    private func postCellItems(_ post: Post, streamKind: StreamKind, isGridView: Bool, currentUser: User?, submission: ArtistInviteSubmission? = nil) -> [StreamCellItem] {
        var cellItems: [StreamCellItem] = []

        if !streamKind.isProfileStream || post.isRepost {
            cellItems.append(StreamCellItem(jsonable: post, type: .streamHeader))
        }
        else {
            cellItems.append(StreamCellItem(jsonable: post, type: .spacer(height: 30)))
        }

        if let submission = submission, submission.actions.count > 0 {
            cellItems.append(StreamCellItem(jsonable: submission, type: .artistInviteAdminControls))
        }

        if streamKind.isCategoryStream,
            let category = post.category,
            let currentUser = currentUser,
            currentUser.isCuratorOf(category: category)
        {
            cellItems.append(StreamCellItem(jsonable: post, type: .postFeaturedControl))
        }

        if let featuredBy = post.featuredBy {
            cellItems.append(StreamCellItem(jsonable: post, type: .postFeaturedBy))
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
        else if let content = post.contentFor(gridView: isGridView) {
            cellItems += regionItems(post, content: content)
        }
        cellItems += [StreamCellItem(jsonable: post, type: .streamFooter)]
        cellItems += [StreamCellItem(jsonable: post, type: .spacer(height: 10))]

        // set initial state on the items, but don't toggle the footer's state, it is used by comment open/closed
        for item in cellItems {
            guard let post = item.jsonable as? Post, item.type != .streamFooter else { continue }
            item.state = post.isCollapsed ? .collapsed : .expanded
        }

        return cellItems
    }

    private func commentCellItems(_ comment: ElloComment) -> [StreamCellItem] {
        var cellItems: [StreamCellItem] = [
            StreamCellItem(jsonable: comment, type: .commentHeader)
        ]
        cellItems += regionItems(comment, content: comment.content)
        return cellItems
    }

    private func postToggleItems(_ post: Post) -> [StreamCellItem] {
        if post.isCollapsed {
            return [StreamCellItem(jsonable: post, type: .toggle)]
        }
        else {
            return []
        }
    }

    private func regionItems(_ jsonable: JSONAble, content: [Regionable]) -> [StreamCellItem] {
        return content.flatMap(regionStreamCells).map { StreamCellItem(jsonable: jsonable, type: $0) }
    }

    func regionStreamCells(_ region: Regionable) -> [StreamCellType] {
        switch region.kind {
        case .image:
            return [.image(data: region)]
        case .text:
            guard let textRegion = region as? TextRegion else { return [] }

            let content = textRegion.content

            var paragraphs: [String] = content.components(separatedBy: "</p>")
            if paragraphs.last == "" {
                _ = paragraphs.removeLast()
            }
            let truncatedParagraphs = paragraphs.map { line -> String in
                let max = 7500
                guard line.count < max + 10 else {
                    let startIndex = line.startIndex
                    let endIndex = line.index(line.startIndex, offsetBy: max)
                    return String(line[startIndex ..< endIndex]) + "&hellip;</p>"
                }
                return line + "</p>"
            }

            return truncatedParagraphs.compactMap { (text: String) -> StreamCellType? in
                if text == "" {
                    return nil
                }

                let newRegion = TextRegion(content: text)
                newRegion.isRepost = textRegion.isRepost
                return .text(data: newRegion)
            }
        case .embed:
            return [.embed(data: region)]
        case .unknown:
            return []
        }
    }
}


// MARK: For Testing
extension StreamCellItemParser {
    func testingTypicalCellItems(_ jsonable: JSONAble, type: StreamCellType) -> [StreamCellItem] {
        return typicalCellItems(jsonable, type: type)
    }
    func testingPostCellItems(_ post: Post, streamKind: StreamKind, isGridView: Bool, currentUser: User?) -> [StreamCellItem] {
        return postCellItems(post, streamKind: streamKind, isGridView: isGridView, currentUser: currentUser)
    }
    func testingCommentCellItems(_ comment: ElloComment) -> [StreamCellItem] {
        return commentCellItems(comment)
    }
}
