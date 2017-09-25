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

    fileprivate var streamFilter: StreamFilter?
    fileprivate var streamCollapsedFilter: StreamFilter? = { item in
        guard item.type.isCollapsable, item.jsonable is Post else { return true }
        return item.state != .collapsed
    }

    var textSizeCalculator = StreamTextCellSizeCalculator()
    var notificationSizeCalculator = StreamNotificationCellSizeCalculator()
    var announcementSizeCalculator = AnnouncementCellSizeCalculator()
    var profileHeaderSizeCalculator = ProfileHeaderCellSizeCalculator()
    var categoryHeaderSizeCalculator = CategoryHeaderCellSizeCalculator()
    var imageSizeCalculator = StreamImageCellSizeCalculator()
    var editorialDownloader = EditorialDownloader()
    var artistInviteCalculator = ArtistInviteCellSizeCalculator()

    // MARK: Adding items

    @discardableResult
    func appendStreamCellItems(_ items: [StreamCellItem]) -> [IndexPath] {
        let startIndex = visibleCellItems.count
        self.allStreamCellItems += items
        self.updateFilteredItems()
        let lastIndex = visibleCellItems.count

        return (startIndex ..< lastIndex).map { IndexPath(item: $0, section: 0) }
    }

    @discardableResult
    func replacePlaceholder(type placeholderType: StreamCellType.PlaceholderType, items cellItems: [StreamCellItem])
        -> (deleted: [IndexPath], inserted: [IndexPath])
    {
        guard cellItems.count > 0 else {
            return replacePlaceholder(type: placeholderType, items: [StreamCellItem(type: .placeholder, placeholderType: placeholderType)])
        }

        for item in cellItems {
            item.placeholderType = placeholderType
        }

        let deletedIndexPaths = indexPaths(forPlaceholderType: placeholderType)
        guard deletedIndexPaths.count > 0 else { return (deleted: [], inserted: []) }

        removeItems(at: deletedIndexPaths)
        let insertedIndexPaths = insertStreamCellItems(cellItems, startingIndexPath: deletedIndexPaths[0])
        return (deleted: deletedIndexPaths, inserted: insertedIndexPaths)
    }

    @discardableResult
    func insertStreamCellItems(_ cellItems: [StreamCellItem], startingIndexPath: IndexPath) -> [IndexPath] {
        // startingIndex represents the filtered index,
        // arrayIndex is the allStreamCellItems index
        let startingIndex = startingIndexPath.item
        var arrayIndex = startingIndexPath.item

        if let item = streamCellItem(at: startingIndexPath) {
            if let foundIndex = allStreamCellItems.index(of: item) {
                arrayIndex = foundIndex
            }
        }
        else if arrayIndex == visibleCellItems.count {
            arrayIndex = allStreamCellItems.count
        }

        var indexPaths: [IndexPath] = []

        for (index, cellItem) in cellItems.enumerated() {
            indexPaths.append(IndexPath(item: startingIndex + index, section: startingIndexPath.section))

            let atIndex = arrayIndex + index
            if atIndex <= allStreamCellItems.count {
                allStreamCellItems.insert(cellItem, at: atIndex)
            }
            else {
                allStreamCellItems.append(cellItem)
            }
        }

        updateFilteredItems()
        return indexPaths
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
                if let index = allStreamCellItems.index(of: itemToRemove) {
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

    func clientSidePostInsertIndexPath() -> IndexPath? {
        let currentUserId = currentUser?.id

        switch streamKind {
        case .following:
            return IndexPath(item: 0, section: 0)
        case let .userStream(userParam):
            if currentUserId == userParam {
                if visibleCellItems.count == 2 && visibleCellItems[1].type == .noPosts {
                    removeItems(at: [IndexPath(item: 1, section: 0)])
                    return IndexPath(item: 1, section: 0)
                }
                return IndexPath(item: 2, section: 0)
            }
        default:
            break
        }
        return nil
    }

    func clientSideLoveInsertIndexPath() -> IndexPath? {
        switch streamKind {
        case let .simpleStream(endpoint, _):
            switch endpoint {
            case .loves:
                return IndexPath(item: 1, section: 0)
            default:
                break
            }
        default:
            break
        }
        return nil
    }

    func modifyItems(_ jsonable: JSONAble, change: ContentChange, streamViewController: StreamViewController) {
        // get items that match id and type -> [IndexPath]
        // based on change decide to update/remove those items
        switch change {
        case .create:
            // in post detail, show/hide the love drawer
            if let love = jsonable as? Love, love.post.map({ streamKind.isDetail(post: $0) }) == true {
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
                    let (deleted, inserted) = self.replacePlaceholder(type: .postLovers, items: items)
                    streamViewController.performDataChange { collectionView in
                        collectionView.deleteItems(at: deleted)
                        collectionView.insertItems(at: inserted)
                    }
                }

                if hasCellItems(for: .postReposters) {
                    let padding = PostDetailGenerator.socialPadding()
                    let (deleted, inserted) = self.replacePlaceholder(type: .postSocialPadding, items: padding)
                    streamViewController.performDataChange { collectionView in
                        collectionView.deleteItems(at: deleted)
                        collectionView.insertItems(at: inserted)
                    }
                }
            }
            else {
                var indexPath: IndexPath?

                if let comment = jsonable as? ElloComment,
                    let parentPost = comment.loadedFromPost
                {
                    let indexPaths = commentIndexPaths(forPost: parentPost)
                    if let firstPath = indexPaths.first,
                        visibleCellItems[firstPath.item].type == .createComment
                    {
                        indexPath = IndexPath(item: firstPath.item + 1, section: 0)
                    }
                }
                // else if post, add new post cells
                else if jsonable is Post {
                    indexPath = clientSidePostInsertIndexPath()
                }
                else if jsonable is Love {
                    indexPath = clientSideLoveInsertIndexPath()
                }

                if let indexPath = indexPath {
                    let items = StreamCellItemParser().parse([jsonable], streamKind: streamKind, currentUser: currentUser)
                    let postCreatedPlaceholder: StreamCellType.PlaceholderType = .streamPosts
                    for item in items {
                        item.placeholderType = postCreatedPlaceholder
                    }
                    calculateCellItems(items, withWidth: UIWindow.windowWidth()) {
                        let indexPaths = self.insertStreamCellItems(items, startingIndexPath: indexPath)
                        streamViewController.performDataChange { collectionView in
                            collectionView.insertItems(at: indexPaths)
                        }
                    }
                }
            }

        case .delete:
            if let love = jsonable as? Love,
                let post = love.post,
                let user = love.user
            {
                for (index, item) in visibleCellItems.enumerated() {
                    guard let userAvatars = item.jsonable as? UserAvatarCellModel,
                        userAvatars.belongsTo(post: post, type: .lovers) else { continue }

                    userAvatars.remove(user: user)

                    if userAvatars.users.count == 0 {
                        let (deleted, inserted) = self.replacePlaceholder(type: .postLovers, items: [])
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
                    let (deleted, inserted) = self.replacePlaceholder(type: .postSocialPadding, items: [])
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

            let items = StreamCellItemParser().parse([jsonable], streamKind: self.streamKind, currentUser: currentUser)
            calculateCellItems(items, withWidth: UIWindow.windowWidth()) {
                self.removeItems(at: oldIndexPaths)
                let newIndexPaths = self.insertStreamCellItems(items, startingIndexPath: firstIndexPath)
                streamViewController.performDataChange { collectionView in
                    collectionView.deleteItems(at: oldIndexPaths)
                    collectionView.insertItems(at: newIndexPaths)
                }
            }
        case .update:
            var shouldReload = true

            if case let .simpleStream(endpoint, _) = streamKind,
                case .loves = endpoint,
                let post = jsonable as? Post, !post.isLoved
            {
                let removedPaths = removeItemsFor(jsonable: jsonable, change: .delete)
                streamViewController.performDataChange { collectionView in
                    collectionView.deleteItems(at: removedPaths)
                }
                shouldReload = false
            }

            if shouldReload {
                mergeAndReloadElementsFor(jsonable: jsonable, change: change, streamViewController: streamViewController)
            }
        case .loved,
             .reposted,
             .watching:
            mergeAndReloadElementsFor(jsonable: jsonable, change: change, streamViewController: streamViewController)
        default: break
        }
    }

    func mergeAndReloadElementsFor(jsonable: JSONAble, change: ContentChange, streamViewController: StreamViewController) {
        let (indexPaths, items) = elementsFor(jsonable: jsonable, change: change)
        let T = type(of: jsonable)
        var modified = false
        for item in items {
            if item.jsonable.isKind(of: T) {
                item.jsonable = item.jsonable.merge(jsonable)
                modified = true
            }
        }

        if modified {
            streamViewController.performDataUpdate { collectionView in
                collectionView.reloadItems(at: indexPaths)
            }
        }
    }

    func modifyUserRelationshipItems(_ user: User, streamViewController: StreamViewController) {
        let (indexPaths, changedItems) = elementsFor(jsonable: user, change: .update)

        streamViewController.performDataUpdate { collectionView in
            for item in changedItems {
                if let oldUser = item.jsonable as? User {
                    // relationship changes
                    oldUser.relationshipPriority = user.relationshipPriority
                    oldUser.followersCount = user.followersCount
                    oldUser.followingCount = user.followingCount
                }

                if let authorable = item.jsonable as? Authorable,
                    let author = authorable.author, author.id == user.id
                {
                    author.relationshipPriority = user.relationshipPriority
                    author.followersCount = user.followersCount
                    author.followingCount = user.followingCount
                }

                if let post = item.jsonable as? Post,
                    let repostAuthor = post.repostAuthor, repostAuthor.id == user.id
                {
                    repostAuthor.relationshipPriority = user.relationshipPriority
                    repostAuthor.followersCount = user.followersCount
                    repostAuthor.followingCount = user.followingCount
                }
            }

            collectionView.reloadItems(at: indexPaths)
        }

        if user.relationshipPriority.isMutedOrBlocked {
            var shouldDelete = true

            switch streamKind {
            case let .userStream(userId):
                shouldDelete = user.id != userId
            case let .simpleStream(endpoint, _):
                if case .currentUserBlockedList = endpoint, user.relationshipPriority == .block
                {
                    shouldDelete = false
                }
                else if case .currentUserMutedList = endpoint, user.relationshipPriority == .mute
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
    }

    func modifyUserSettingsItems(_ user: User, streamViewController: StreamViewController) {
        let (indexPaths, changedItems) = elementsFor(jsonable: user, change: .update)
        for item in changedItems where item.jsonable is User{
            item.jsonable = user
        }
        streamViewController.performDataUpdate { collectionView in
            collectionView.reloadItems(at: indexPaths)
        }
    }

    @discardableResult
    func removeItemsFor(jsonable: JSONAble, change: ContentChange) -> [IndexPath] {
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
    fileprivate func elementsFor(jsonable: JSONAble, change: ContentChange) -> ([IndexPath], [StreamCellItem]) {
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
                    if let itemComment = item.jsonable as? ElloComment, itemComment.loadedFromPostId == post.id || itemComment.postId == post.id {
                        indexPaths.append(IndexPath(item: index, section: 0))
                        items.append(item)
                    }
                }
                else if change == .watching {
                    if let itemComment = item.jsonable as? ElloComment, (itemComment.loadedFromPostId == post.id || itemComment.postId == post.id) && item.type == .createComment {
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
                        if  user.id == itemComment.authorId ||
                            user.id == itemComment.loadedFromPost?.authorId
                        {
                            indexPaths.append(IndexPath(item: index, section: 0))
                            items.append(item)
                        }
                    }
                    else if let itemNotification = item.jsonable as? Notification, user.id == itemNotification.author?.id {
                        indexPaths.append(IndexPath(item: index, section: 0))
                        items.append(item)
                    }
                    else if let itemPost = item.jsonable as? Post, user.id == itemPost.authorId {
                        indexPaths.append(IndexPath(item: index, section: 0))
                        items.append(item)
                    }
                    else if let itemPost = item.jsonable as? Post, user.id == itemPost.repostAuthor?.id {
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
                if let itemJsonable = item.jsonable as? JSONSaveable, let itemIdentifier = itemJsonable.uniqueId, identifier == itemIdentifier
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

    func calculateCellItems(_ cellItems: [StreamCellItem], withWidth: CGFloat, completion: @escaping Block) {
        let textCells = filterTextCells(cellItems)
        let imageCells = filterImageCells(cellItems)
        let notificationElements = cellItems.filter {
            return $0.type == .notification
        }
        let announcementElements = cellItems.filter {
            return $0.type == .announcement
        }
        let profileHeaderItems = cellItems.filter {
            return $0.type == .profileHeader
        }

        let categoryHeaderItems = cellItems.filter {
            return $0.type == .categoryPromotionalHeader || $0.type == .pagePromotionalHeader
        }
        let editorialItems = cellItems.filter {
            return $0.jsonable is Editorial
        }

        let artistInviteItems = cellItems.filter {
            return $0.jsonable is ArtistInvite
        }

        let (afterAll, done) = afterN(on: DispatchQueue.main, execute: completion)
        // -30.0 acounts for the 15 on either side for constraints
        let textLeftRightConstraintWidth = (StreamTextCell.Size.postMargin * 2)
        textSizeCalculator.processCells(textCells.normal, withWidth: withWidth - textLeftRightConstraintWidth, columnCount: columnCount, completion: afterAll())
        // extra -30.0 acounts for the left indent on a repost with the black line
        let repostLeftRightConstraintWidth = textLeftRightConstraintWidth + StreamTextCell.Size.repostMargin
        textSizeCalculator.processCells(textCells.repost, withWidth: withWidth - repostLeftRightConstraintWidth, columnCount: columnCount, completion: afterAll())
        imageSizeCalculator.processCells(imageCells.normal + imageCells.repost, withWidth: withWidth, columnCount: columnCount, completion: afterAll())
        notificationSizeCalculator.processCells(notificationElements, withWidth: withWidth, completion: afterAll())
        announcementSizeCalculator.processCells(announcementElements, withWidth: withWidth, completion: afterAll())
        profileHeaderSizeCalculator.processCells(profileHeaderItems, withWidth: withWidth, columnCount: columnCount, completion: afterAll())
        categoryHeaderSizeCalculator.processCells(categoryHeaderItems, withWidth: withWidth, completion: afterAll())
        editorialDownloader.processCells(editorialItems, completion: afterAll())
        artistInviteCalculator.processCells(artistInviteItems, withWidth: withWidth, hasCurrentUser: true, completion: afterAll())
        done()
    }

    fileprivate func filterTextCells(_ cellItems: [StreamCellItem]) -> (normal: [StreamCellItem], repost: [StreamCellItem]) {
        var cells = [StreamCellItem]()
        var repostCells = [StreamCellItem]()
        for item in cellItems {
            if let textRegion = item.type.data as? TextRegion {
                if textRegion.isRepost {
                    repostCells.append(item)
                }
                else {
                    cells.append(item)
                }
            }
        }
        return (cells, repostCells)
    }

    fileprivate func filterImageCells(_ cellItems: [StreamCellItem]) -> (normal: [StreamCellItem], repost: [StreamCellItem]) {
        var cells = [StreamCellItem]()
        var repostCells = [StreamCellItem]()
        for item in cellItems {
            if let imageRegion = item.type.data as? ImageRegion {
                if imageRegion.isRepost {
                    repostCells.append(item)
                }
                else {
                    cells.append(item)
                }
            }
            else if let embedRegion = item.type.data as? EmbedRegion {
                if embedRegion.isRepost {
                    repostCells.append(item)
                }
                else {
                    cells.append(item)
                }
            }
        }
        return (cells, repostCells)
    }

    fileprivate func temporarilyUnfilter(_ block: Block) {
        visibleCellItems = allStreamCellItems

        block()

        updateFilteredItems()
    }

    fileprivate func updateFilteredItems() {
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
    func testingElementsFor(jsonable: JSONAble, change: ContentChange) -> ([IndexPath], [StreamCellItem]) {
        return elementsFor(jsonable: jsonable, change: change)
    }
}
