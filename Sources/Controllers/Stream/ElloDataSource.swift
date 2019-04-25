////
///  ElloDataSource.swift
//

class ElloDataSource: NSObject {
    // In StreamDataSource, visibleCellItems can be modified based on a stream
    // filter.  In CollectionViewDataSource, there is only the one list.
    var visibleCellItems: [StreamCellItem] = []
    var streamKind: StreamKind { didSet { didSetStreamKind() }}
    var currentUser: User?

    init(streamKind: StreamKind) {
        self.streamKind = streamKind
        super.init()
    }

    func didSetStreamKind() {}

    func isValidIndexPath(_ indexPath: IndexPath) -> Bool {
        return indexPath.section == 0 && indexPath.item >= 0 && indexPath.item < visibleCellItems.count
    }

    func streamCellItem(where filter: (StreamCellItem) -> Bool) -> StreamCellItem? {
        return visibleCellItems.find(filter)
    }

    func indexPath(where filter: (StreamCellItem) -> Bool) -> IndexPath? {
        guard let index = visibleCellItems.firstIndex(where: filter) else { return nil }
        return IndexPath(item: index, section: 0)
    }

    func indexPath(forItem item: StreamCellItem) -> IndexPath? {
        return indexPath(where: { $0 == item })
    }

    func indexPaths(forPlaceholderType placeholderType: StreamCellType.PlaceholderType) -> [IndexPath] {
        return (0 ..< visibleCellItems.count).compactMap { index in
            guard visibleCellItems[index].placeholderType == placeholderType else { return nil }
            return IndexPath(item: index, section: 0)
        }
    }

    func firstIndexPath(forPlaceholderType placeholderType: StreamCellType.PlaceholderType) -> IndexPath? {
        if let index = self.visibleCellItems.firstIndex(where: { $0.placeholderType == placeholderType }) {
            return IndexPath(item: index, section: 0)
        }
        return nil
    }

    func footerIndexPath(forPost searchPost: Post) -> IndexPath? {
        for (index, value) in visibleCellItems.enumerated() {
            if value.type == .streamFooter,
               let post = value.jsonable as? Post,
               post.id == searchPost.id
            {
                return IndexPath(item: index, section: 0)
            }
        }
        return nil
    }

    func streamCellItem(at indexPath: IndexPath) -> StreamCellItem? {
        guard isValidIndexPath(indexPath) else { return nil}
        return visibleCellItems[indexPath.item]
    }

    func jsonable(at indexPath: IndexPath) -> Model? {
        let item = streamCellItem(at: indexPath)
        return item?.jsonable
    }

    func post(at indexPath: IndexPath) -> Post? {
        guard let item = streamCellItem(at: indexPath) else { return nil }

        if let notification = item.jsonable as? Notification {
            if let comment = notification.activity.subject as? ElloComment {
                return comment.loadedFromPost
            }
            return notification.activity.subject as? Post
        }

        if let editorial = item.jsonable as? Editorial {
            return editorial.post
        }

        return item.jsonable as? Post
    }

    func comment(at indexPath: IndexPath) -> ElloComment? {
        return jsonable(at: indexPath) as? ElloComment
    }

    func user(at indexPath: IndexPath) -> User? {
        guard let item = streamCellItem(at: indexPath) else { return nil }

        if case .streamHeader = item.type,
            let repostAuthor = (item.jsonable as? Post)?.repostAuthor
        {
            return repostAuthor
        }

        if let user = (item.jsonable as? PageHeader)?.user {
            return user
        }

        if let authorable = item.jsonable as? Authorable {
            return authorable.author
        }

        return item.jsonable as? User
    }

    func reposter(at indexPath: IndexPath) -> User? {
        guard let item = streamCellItem(at: indexPath) else { return nil }

        if let authorable = item.jsonable as? Authorable {
            return authorable.author
        }
        return item.jsonable as? User
    }

    func imageRegion(at indexPath: IndexPath) -> ImageRegion? {
        let item = streamCellItem(at: indexPath)
        return item?.type.data as? ImageRegion
    }

    func imageAsset(at indexPath: IndexPath) -> Asset? {
        return imageRegion(at: indexPath)?.asset
    }

}
