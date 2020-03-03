////
///  StreamDataSource.swift
//

import WebKit
import DeltaCalculator


class StreamDataSource: ElloDataSource {

    typealias StreamContentReady = (_ indexPaths: [IndexPath]) -> Void
    typealias StreamFilter = ((StreamCellItem) -> Bool)

    var columnCount = 1

    // these are the items assigned from the parent controller
    var allStreamCellItems: [StreamCellItem] = []

    private var streamFilter: StreamFilter?
    private var streamCollapsedFilter: StreamFilter? = { item in
        guard item.type.isCollapsable, item.jsonable is Post else { return true }
        return item.state != .collapsed
    }

    // MARK: Adding items

    @discardableResult
    func appendStreamCellItems(_ items: [StreamCellItem]) -> [IndexPath] {
        let startIndex = visibleCellItems.count
        self.allStreamCellItems += items
        self.updateFilteredItems()
        let lastIndex = visibleCellItems.count

        return (startIndex..<lastIndex).map { IndexPath(item: $0, section: 0) }
    }

    @discardableResult
    func replacePlaceholder(
        type placeholderType: StreamCellType.PlaceholderType,
        items cellItems: [StreamCellItem]
    )
        -> (deleted: [IndexPath], inserted: [IndexPath])
    {
        guard cellItems.count > 0 else {
            return replacePlaceholder(
                type: placeholderType,
                items: [StreamCellItem(type: .placeholder, placeholderType: placeholderType)]
            )
        }

        for item in cellItems {
            item.placeholderType = placeholderType
        }

        let deletedIndexPaths = indexPaths(forPlaceholderType: placeholderType)
        guard deletedIndexPaths.count > 0 else { return (deleted: [], inserted: []) }

        removeItems(at: deletedIndexPaths)
        let insertedIndexPaths = insertStreamCellItems(
            cellItems,
            startingIndexPath: deletedIndexPaths[0]
        )
        return (deleted: deletedIndexPaths, inserted: insertedIndexPaths)
    }

    @discardableResult
    func insertStreamCellItems(_ cellItems: [StreamCellItem], startingIndexPath: IndexPath)
        -> [IndexPath]
    {
        // startingIndex represents the filtered index,
        // arrayIndex is the allStreamCellItems index
        let startingIndex = startingIndexPath.item
        var arrayIndex = startingIndexPath.item

        if let item = streamCellItem(at: startingIndexPath) {
            if let foundIndex = allStreamCellItems.firstIndex(of: item) {
                arrayIndex = foundIndex
            }
        }
        else if arrayIndex == visibleCellItems.count {
            arrayIndex = allStreamCellItems.count
        }

        for (index, cellItem) in cellItems.enumerated() {

            let atIndex = arrayIndex + index
            if atIndex <= allStreamCellItems.count {
                allStreamCellItems.insert(cellItem, at: atIndex)
            }
            else {
                allStreamCellItems.append(cellItem)
            }
        }

        let initialCount = visibleCellItems.count
        updateFilteredItems()
        let finalCount = visibleCellItems.count - initialCount
        return (0..<finalCount).map { IndexPath(item: startingIndex + $0, section: 0) }
    }

    // MARK: retrieving/searching for items

    func hasCellItems(for placeholderType: StreamCellType.PlaceholderType) -> Bool {
        // don't filter on 'type', because we need to check that the number of
        // items is 1 or 0, and if it's 1, then we need to see if its type is
        // .Placeholder
        let items = allStreamCellItems.filter {
            $0.placeholderType == placeholderType
        }

        if let item = items.first,
            items.count == 1,
            case .placeholder = item.type
        {
            return false
        }

        return items.count > 0
    }

    func cellItems(for post: Post) -> [StreamCellItem] {
        var tmp = [StreamCellItem]()
        temporarilyUnfilter {
            tmp = self.visibleCellItems.reduce([]) { arr, item in
                if let cellPost = item.jsonable as? Post, post.id == cellPost.id {
                    return arr + [item]
                }
                return arr
            }
        }
        return tmp
    }

    // this includes the `createComment` cell, `spacer` cell, and `seeMoreComments` cell since they contain a comment item
    func commentIndexPaths(forPost post: Post) -> [IndexPath] {
        var indexPaths = [IndexPath]()
        for (index, value) in visibleCellItems.enumerated() {
            if let comment = value.jsonable as? ElloComment, comment.loadedFromPostId == post.id {
                indexPaths.append(IndexPath(item: index, section: 0))
            }
        }
        return indexPaths
    }

    func removeAllCellItems() {
        allStreamCellItems = []
        updateFilteredItems()
    }

    func updateFilter(_ filter: StreamFilter?) -> Delta {
        let prevItems = visibleCellItems
        streamFilter = filter
        updateFilteredItems()

        let calculator = DeltaCalculator<StreamCellItem>()
        return calculator.deltaFromOldArray(prevItems, toNewArray: visibleCellItems)
    }

    @discardableResult
    func removeComments(forPost post: Post) -> [IndexPath] {
        let indexPaths = commentIndexPaths(forPost: post)
        temporarilyUnfilter {
            // these paths might be different depending on the filter
            let unfilteredIndexPaths = commentIndexPaths(forPost: post)
            var newItems = [StreamCellItem]()
            for (index, item) in allStreamCellItems.enumerated() {
                let skip = unfilteredIndexPaths.any { $0.item == index }
                if !skip {
                    newItems.append(item)
                }
            }
            allStreamCellItems = newItems
        }
        return indexPaths
    }

    func removeItems(at indexPaths: [IndexPath]) {
        var items: [StreamCellItem] = []
        for indexPath in indexPaths {
            if let itemToRemove = visibleCellItems.safeValue(indexPath.item) {
                items.append(itemToRemove)
            }
        }
        temporarilyUnfilter {
            for itemToRemove in items {
                if let index = allStreamCellItems.firstIndex(of: itemToRemove) {
                    allStreamCellItems.remove(at: index)
                }
            }
        }
    }

    func updateHeight(at indexPath: IndexPath, height: CGFloat) {
        guard isValidIndexPath(indexPath) else { return }

        visibleCellItems[indexPath.item].calculatedCellHeights.oneColumn = height
        visibleCellItems[indexPath.item].calculatedCellHeights.multiColumn = height
    }

    func toggleCollapsed(at indexPath: IndexPath) {
        guard
            let post = self.post(at: indexPath),
            let cellItem = self.streamCellItem(at: indexPath)
        else { return }

        let newState: StreamCellState = cellItem.state == .expanded ? .collapsed : .expanded
        let streamCellItems = cellItems(for: post)
        for item in streamCellItems where item.type != .streamFooter {
            // don't toggle the footer's state, it is used by comment open/closed
            item.state = newState
        }
        updateFilteredItems()
    }

    func insertComment(comment: ElloComment, streamViewController: StreamViewController) {
        guard let parentPost = comment.loadedFromPost else { return }

        let indexPaths = commentIndexPaths(forPost: parentPost)
        if let firstPath = indexPaths.first,
            visibleCellItems[firstPath.item].type == .createComment
        {
            let indexPath = IndexPath(item: firstPath.item + 1, section: 0)
            let items = StreamCellItemParser().parse(
                [comment],
                streamKind: streamKind,
                currentUser: currentUser
            )
            for item in items {
                item.placeholderType = .streamItems
            }
            calculateCellItems(items, withWidth: Globals.windowSize.width) {
                let indexPaths = self.insertStreamCellItems(items, startingIndexPath: indexPath)
                streamViewController.performDataChange { collectionView in
                    collectionView.insertItems(at: indexPaths)
                }
            }
        }
    }

    func insertPost(post: Post, streamViewController: StreamViewController) {
        let currentUserId = currentUser?.id

        var deletePath: IndexPath?
        let firstInsertPath: IndexPath?

        switch streamKind {
        case .following:
            let streamPaths = indexPaths(forPlaceholderType: .streamItems)
            firstInsertPath = streamPaths.first
        case let .userStream(userParam):
            guard currentUserId == userParam else { return }

            let streamPaths = indexPaths(forPlaceholderType: .streamItems)
            if let path = streamPaths.first, streamPaths.count == 1,
                visibleCellItems[path.row].type == .noPosts
            {
                deletePath = path
            }

            firstInsertPath = streamPaths.first
        default:
            return
        }

        guard let indexPath = firstInsertPath else { return }

        let items = StreamCellItemParser().parse(
            [post],
            streamKind: streamKind,
            currentUser: currentUser
        )
        for item in items {
            item.placeholderType = .streamItems
        }
        calculateCellItems(items, withWidth: Globals.windowSize.width) {
            if let deletePath = deletePath {
                self.removeItems(at: [deletePath])
                let indexPaths = self.insertStreamCellItems(items, startingIndexPath: indexPath)
                streamViewController.performDataChange { collectionView in
                    collectionView.deleteItems(at: [deletePath])
                    collectionView.insertItems(at: indexPaths)
                }
            }
            else {
                let indexPaths = self.insertStreamCellItems(items, startingIndexPath: indexPath)
                streamViewController.performDataChange { collectionView in
                    collectionView.insertItems(at: indexPaths)
                }
            }
        }
    }

    func insertLove(love: Love, streamViewController: StreamViewController) {
        guard
            let post = love.post,
            case let .userLoves(username) = streamKind,
            username == currentUser?.username,
            indexPath(where: { ($0.jsonable as? Post)?.id == post.id }) == nil
        else { return }

        let items = StreamCellItemParser().parse(
            [love],
            streamKind: streamKind,
            currentUser: currentUser
        )
        for item in items {
            item.placeholderType = .streamItems
        }
        calculateCellItems(items, withWidth: Globals.windowSize.width) {
            let indexPaths = self.insertStreamCellItems(
                items,
                startingIndexPath: IndexPath(item: 0, section: 0)
            )
            streamViewController.performDataChange { collectionView in
                collectionView.insertItems(at: indexPaths)
            }
        }
    }

    func modifyItems(
        _ jsonable: Model,
        change: ContentChange,
        streamViewController: StreamViewController
    ) {
        // get items that match id and type -> [IndexPath]
        // based on change decide to update/remove those items
        switch change {
        case .create:
            // in post detail, show/hide the love drawer
            if let love = jsonable as? Love,
                love.post.map({ streamKind.isDetail(post: $0) }) == true
            {
                guard let post = love.post, let user = love.user else { return }

                if hasCellItems(for: .postLovers) {
                    for (index, item) in visibleCellItems.enumerated() {
                        guard let userAvatars = item.jsonable as? UserAvatarCellModel,
                            userAvatars.belongsTo(post: post, type: .lovers)
                        else { continue }

                        let indexPath = IndexPath(row: index, section: 0)
                        streamViewController.performDataUpdate { collectionView in
                            userAvatars.append(user: user)
                            collectionView.reloadItems(at: [indexPath])
                        }
                        break
                    }
                }
                else {
                    let items = PostDetailGenerator.userAvatarCellItems(
                        users: [user],
                        postParam: post.id,
                        type: .lovers
                    )
                    let (deleted, inserted) = self.replacePlaceholder(
                        type: .postLovers,
                        items: items
                    )
                    streamViewController.performDataChange { collectionView in
                        collectionView.deleteItems(at: deleted)
                        collectionView.insertItems(at: inserted)
                    }
                }

                if hasCellItems(for: .postReposters) {
                    let padding = PostDetailGenerator.socialPadding()
                    let (deleted, inserted) = self.replacePlaceholder(
                        type: .postSocialPadding,
                        items: padding
                    )
                    streamViewController.performDataChange { collectionView in
                        collectionView.deleteItems(at: deleted)
                        collectionView.insertItems(at: inserted)
                    }
                }
            }
            else {
                if let comment = jsonable as? ElloComment {
                    insertComment(comment: comment, streamViewController: streamViewController)
                }
                // else if post, add new post cells
                else if let post = jsonable as? Post {
                    insertPost(post: post, streamViewController: streamViewController)
                }
                else if let love = jsonable as? Love {
                    insertLove(love: love, streamViewController: streamViewController)
                }
            }

        case .delete:
            if let love = jsonable as? Love,
                let post = love.post,
                let user = love.user
            {
                for (index, item) in visibleCellItems.enumerated() {
                    guard let userAvatars = item.jsonable as? UserAvatarCellModel,
                        userAvatars.belongsTo(post: post, type: .lovers)
                    else { continue }

                    userAvatars.remove(user: user)

                    if userAvatars.users.count == 0 {
                        let (deleted, inserted) = self.replacePlaceholder(
                            type: .postLovers,
                            items: []
                        )
                        streamViewController.performDataChange { collectionView in
                            collectionView.deleteItems(at: deleted)
                            collectionView.insertItems(at: inserted)
                        }
                    }
                    else {
                        let indexPath = IndexPath(row: index, section: 0)
                        streamViewController.performDataUpdate { collectionView in
                            collectionView.reloadItems(at: [indexPath])
                        }
                    }
                    break
                }

                if !hasCellItems(for: .postLovers) && !hasCellItems(for: .postReposters) {
                    let (deleted, inserted) = self.replacePlaceholder(
                        type: .postSocialPadding,
                        items: []
                    )
                    streamViewController.performDataChange { collectionView in
                        collectionView.deleteItems(at: deleted)
                        collectionView.insertItems(at: inserted)
                    }
                }
            }

            let removedPaths = self.removeItemsFor(jsonable: jsonable, change: change)
            streamViewController.performDataChange { collectionView in
                collectionView.deleteItems(at: removedPaths)
            }
        case .replaced:
            let (oldIndexPaths, _) = elementsFor(jsonable: jsonable, change: change)
            guard let firstIndexPath = oldIndexPaths.first else { return }

            let items = StreamCellItemParser().parse(
                [jsonable],
                streamKind: self.streamKind,
                currentUser: currentUser
            )
            calculateCellItems(items, withWidth: Globals.windowSize.width) {
                self.removeItems(at: oldIndexPaths)
                let newIndexPaths = self.insertStreamCellItems(
                    items,
                    startingIndexPath: firstIndexPath
                )
                streamViewController.performDataChange { collectionView in
                    collectionView.deleteItems(at: oldIndexPaths)
                    collectionView.insertItems(at: newIndexPaths)
                }
            }
        case .update:
            var shouldReload = true

            if case .userLoves = streamKind, let post = jsonable as? Post, !post.isLoved {
                let removedPaths = removeItemsFor(jsonable: jsonable, change: .delete)
                streamViewController.performDataChange { collectionView in
                    collectionView.deleteItems(at: removedPaths)
                }
                shouldReload = false
            }

            if shouldReload {
                mergeAndReloadElementsFor(
                    jsonable: jsonable,
                    change: change,
                    streamViewController: streamViewController
                )
            }
        case .loved,
            .reposted,
            .watching:
            mergeAndReloadElementsFor(
                jsonable: jsonable,
                change: change,
                streamViewController: streamViewController
            )
        default: break
        }
    }

    func mergeAndReloadElementsFor(
        jsonable: Model,
        change: ContentChange,
        streamViewController: StreamViewController
    ) {
        let (indexPaths, items) = elementsFor(jsonable: jsonable, change: change)
        let T = type(of: jsonable)
        var modified = false
        for item in items {
            guard item.jsonable.isKind(of: T) else { continue }
            item.jsonable = item.jsonable.merge(jsonable)
            modified = true
        }

        if modified {
            streamViewController.performDataUpdate { collectionView in
                collectionView.reloadItems(at: indexPaths)
            }
        }
    }

    func modifyUserRelationshipItems(_ user: User, streamViewController: StreamViewController) {
        if user.relationshipPriority.isMutedOrBlocked {
            removeUserFromStream(user, streamViewController: streamViewController)
        }
        else {
            updateUserRelationshipControls(user, streamViewController: streamViewController)
        }
    }

    private func removeUserFromStream(_ user: User, streamViewController: StreamViewController) {
        var shouldDelete = true

        switch streamKind {
        case let .userStream(userId):
            shouldDelete = user.id != userId
        case let .simpleStream(endpoint, _):
            if case .currentUserBlockedList = endpoint,
                user.relationshipPriority == .block
            {
                shouldDelete = false
            }
            else if case .currentUserMutedList = endpoint,
                user.relationshipPriority == .mute
            {
                shouldDelete = false
            }
        default:
            break
        }

        if shouldDelete {
            modifyItems(user, change: .delete, streamViewController: streamViewController)
        }
    }

    private func updateUserRelationshipControls(
        _ user: User,
        streamViewController: StreamViewController
    ) {
        var indexPaths = [IndexPath]()
        var changedItems = [StreamCellItem]()
        for (index, item) in visibleCellItems.enumerated() {
            guard
                item.type.showsUserRelationship,
                (item.jsonable as? User)?.id == user.id
                    || (item.jsonable as? Authorable)?.author?.id == user.id
                    || (item.jsonable as? Post)?.repostAuthor?.id == user.id
            else { continue }

            indexPaths.append(IndexPath(item: index, section: 0))
            changedItems.append(item)
        }

        guard changedItems.count > 0 else { return }

        for item in changedItems {
            let possibleUsers = [
                item.jsonable as? User,
                (item.jsonable as? Authorable)?.author,
                (item.jsonable as? Post)?.repostAuthor,
            ]

            for foundUser in possibleUsers {
                guard let foundUser = foundUser, foundUser.id == user.id else { continue }
                foundUser.relationshipPriority = user.relationshipPriority
                foundUser.followersCount = user.followersCount
                foundUser.followingCount = user.followingCount
                ElloLinkedStore.shared.saveObject(foundUser, id: foundUser.id, type: .usersType)
            }
        }

        streamViewController.performDataUpdate { collectionView in
            collectionView.reloadItems(at: indexPaths)
        }
    }

    func modifyUserSettingsItems(_ user: User, streamViewController: StreamViewController) {
        let (indexPaths, changedItems) = elementsFor(jsonable: user, change: .update)
        for item in changedItems where item.jsonable is User {
            item.jsonable = user
        }
        streamViewController.performDataUpdate { collectionView in
            collectionView.reloadItems(at: indexPaths)
        }
    }

    @discardableResult
    func removeItemsFor(jsonable: Model, change: ContentChange) -> [IndexPath] {
        let indexPaths = self.elementsFor(jsonable: jsonable, change: change).0
        temporarilyUnfilter {
            // these paths might be different depending on the filter
            let unfilteredIndexPaths = elementsFor(jsonable: jsonable, change: change).0
            var newItems = [StreamCellItem]()
            for (index, item) in allStreamCellItems.enumerated() {
                let skip = unfilteredIndexPaths.any { $0.item == index }
                if !skip {
                    newItems.append(item)
                }
            }
            allStreamCellItems = newItems
        }
        return indexPaths
    }

    // the IndexPaths returned are guaranteed to be in order, so that the first
    // item has the lowest row/item value.
    private func elementsFor(jsonable: Model, change: ContentChange) -> (
        [IndexPath], [StreamCellItem]
    ) {
        var indexPaths = [IndexPath]()
        var items = [StreamCellItem]()
        if let post = jsonable as? Post {
            for (index, item) in visibleCellItems.enumerated() {
                if let itemPost = item.jsonable as? Post, post.id == itemPost.id {
                    // on loved events, only include the post footer, since nothing else will change
                    if change != .loved || item.type == .streamFooter {
                        indexPaths.append(IndexPath(item: index, section: 0))
                        items.append(item)
                    }
                }
                else if change == .delete {
                    if let itemComment = item.jsonable as? ElloComment,
                        itemComment.loadedFromPostId == post.id || itemComment.postId == post.id
                    {
                        indexPaths.append(IndexPath(item: index, section: 0))
                        items.append(item)
                    }
                }
                else if change == .watching {
                    if let itemComment = item.jsonable as? ElloComment,
                        (itemComment.loadedFromPostId == post.id || itemComment.postId == post.id)
                            && item.type == .createComment
                    {
                        indexPaths.append(IndexPath(item: index, section: 0))
                        items.append(item)
                    }
                }
            }
        }
        else if let user = jsonable as? User {
            for (index, item) in visibleCellItems.enumerated() {
                switch user.relationshipPriority {
                case .following, .none, .inactive, .block, .mute:
                    if let itemUser = item.jsonable as? User, user.id == itemUser.id {
                        indexPaths.append(IndexPath(item: index, section: 0))
                        items.append(item)
                    }
                    else if let itemComment = item.jsonable as? ElloComment {
                        if user.id == itemComment.authorId
                            || user.id == itemComment.loadedFromPost?.authorId
                        {
                            indexPaths.append(IndexPath(item: index, section: 0))
                            items.append(item)
                        }
                    }
                    else if let itemNotification = item.jsonable as? Notification,
                        user.id == itemNotification.author?.id
                    {
                        indexPaths.append(IndexPath(item: index, section: 0))
                        items.append(item)
                    }
                    else if let itemPost = item.jsonable as? Post, user.id == itemPost.authorId {
                        indexPaths.append(IndexPath(item: index, section: 0))
                        items.append(item)
                    }
                    else if let itemPost = item.jsonable as? Post,
                        user.id == itemPost.repostAuthor?.id
                    {
                        indexPaths.append(IndexPath(item: index, section: 0))
                        items.append(item)
                    }
                default:
                    if let itemUser = item.jsonable as? User, user.id == itemUser.id {
                        indexPaths.append(IndexPath(item: index, section: 0))
                        items.append(item)
                    }
                }
            }
        }
        else if let jsonable = jsonable as? JSONSaveable,
            let identifier = jsonable.uniqueId
        {
            for (index, item) in visibleCellItems.enumerated() {
                if let itemJsonable = item.jsonable as? JSONSaveable,
                    identifier == itemJsonable.uniqueId
                {
                    indexPaths.append(IndexPath(item: index, section: 0))
                    items.append(item)
                }
            }
        }
        return (indexPaths, items)
    }
}

extension StreamDataSource {

    func calculateCellItems(
        _ cellItems: [StreamCellItem],
        withWidth width: CGFloat,
        completion: @escaping Block
    ) {
        let (afterAll, done) = afterN(on: DispatchQueue.main, execute: completion)

        for item in cellItems {
            guard
                let calculator = item.sizeCalculator(
                    streamKind: streamKind,
                    width: width,
                    columnCount: columnCount
                )
            else { continue }
            let unmanaged = Unmanaged.passRetained(calculator)
            let completion = afterAll()
            calculator.begin {
                completion()
                unmanaged.release()
            }
        }

        let editorialItems = cellItems.filter {
            return $0.jsonable is Editorial
        }
        let editorialDownloader = EditorialDownloader()
        editorialDownloader.processCells(editorialItems, completion: afterAll())
        done()
    }

    private func temporarilyUnfilter(_ block: Block) {
        visibleCellItems = allStreamCellItems

        block()

        updateFilteredItems()
    }

    private func updateFilteredItems() {
        visibleCellItems = allStreamCellItems.filter { item in
            guard !item.alwaysShow() else { return true }
            let streamFiltered = streamFilter?(item) ?? true
            let collapsedFiltered = streamCollapsedFilter?(item) ?? true
            return streamFiltered && collapsedFiltered
        }
    }
}

// MARK: For Testing
extension StreamDataSource {
    func testingElementsFor(jsonable: Model, change: ContentChange) -> [StreamCellItem] {
        return elementsFor(jsonable: jsonable, change: change).1
    }
}
