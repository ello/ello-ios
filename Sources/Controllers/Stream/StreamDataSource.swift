////
///  StreamDataSource.swift
//

import WebKit

public class StreamDataSource: NSObject, UICollectionViewDataSource {

    public typealias StreamContentReady = (indexPaths: [NSIndexPath]) -> Void
    public typealias StreamFilter = (StreamCellItem -> Bool)?

    public var streamKind: StreamKind
    public var currentUser: User?

    // these are the items assigned from the parent controller
    public var streamCellItems: [StreamCellItem] = []

    // these are either the same as streamCellItems (no filter) or if a filter
    // is applied this stores the filtered items
    public private(set) var visibleCellItems: [StreamCellItem] = []

    // if a filter is added or removed, we update the items
    public var streamFilter: StreamFilter {
        didSet { updateFilteredItems() }
    }

    // if a filter is added or removed, we update the items
    public var streamCollapsedFilter: StreamFilter {
        didSet { updateFilteredItems() }
    }

    public let textSizeCalculator: StreamTextCellSizeCalculator
    public let notificationSizeCalculator: StreamNotificationCellSizeCalculator
    public let profileHeaderSizeCalculator: ProfileHeaderCellSizeCalculator
    public let imageSizeCalculator: StreamImageCellSizeCalculator

    weak public var postbarDelegate: PostbarDelegate?
    weak public var createPostDelegate: CreatePostDelegate?
    weak public var notificationDelegate: NotificationDelegate?
    weak public var webLinkDelegate: WebLinkDelegate?
    weak public var imageDelegate: StreamImageCellDelegate?
    weak public var editingDelegate: StreamEditingDelegate?
    weak public var categoryDelegate: CategoryDelegate?
    weak public var userDelegate: UserDelegate?
    weak public var relationshipDelegate: RelationshipDelegate?
    weak public var simpleStreamDelegate: SimpleStreamDelegate?
    weak public var conversationDelegate: ConversationDelegate?
    weak public var inviteDelegate: InviteDelegate?
    weak public var columnToggleDelegate: ColumnToggleDelegate?
    weak public var discoverCategoryPickerDelegate: DiscoverCategoryPickerDelegate?
    public let inviteCache = InviteCache()

    public init(
        streamKind: StreamKind,
        textSizeCalculator: StreamTextCellSizeCalculator,
        notificationSizeCalculator: StreamNotificationCellSizeCalculator,
        profileHeaderSizeCalculator: ProfileHeaderCellSizeCalculator,
        imageSizeCalculator: StreamImageCellSizeCalculator)
    {
        self.streamKind = streamKind
        self.textSizeCalculator = textSizeCalculator
        self.notificationSizeCalculator = notificationSizeCalculator
        self.profileHeaderSizeCalculator = profileHeaderSizeCalculator
        self.imageSizeCalculator = imageSizeCalculator
        super.init()
    }

    // MARK: - Public

    public func removeAllCellItems() {
        streamCellItems = []
        updateFilteredItems()
    }

    public func indexPathForItem(item: StreamCellItem) -> NSIndexPath? {
        if let index = self.visibleCellItems.indexOf({$0 == item}) {
            return NSIndexPath(forItem: index, inSection: 0)
        }
        return nil
    }

    public func indexPathsForPlaceholderType(placeholderType: StreamCellType.PlaceholderType) -> [NSIndexPath] {

        guard let index = self.visibleCellItems.indexOf({$0.placeholderType == placeholderType}) else { return [] }

        let indexPath = NSIndexPath(forItem: index, inSection: 0)
        var indexPaths = [indexPath]
        var position = indexPath.item
        var found = true
        while found && position < self.visibleCellItems.count - 1 {
            position += 1
            found = visibleCellItems[position].placeholderType == placeholderType
            if found {
                indexPaths.append(NSIndexPath(forItem: position, inSection: 0))
            }
        }
        return indexPaths
    }

    public func userForIndexPath(indexPath: NSIndexPath) -> User? {
        if let item = visibleStreamCellItem(at: indexPath) {
            if case .Header = item.type,
                let repostAuthor = (item.jsonable as? Post)?.repostAuthor
            {
                return repostAuthor
            }

            if let authorable = item.jsonable as? Authorable {
                return authorable.author
            }
            return item.jsonable as? User
        }
        return nil
    }

    public func reposterForIndexPath(indexPath: NSIndexPath) -> User? {
        if let item = visibleStreamCellItem(at: indexPath) {
            if let authorable = item.jsonable as? Authorable {
                return authorable.author
            }
            return item.jsonable as? User
        }
        return nil
    }

    public func postForIndexPath(indexPath: NSIndexPath) -> Post? {
        let item = visibleStreamCellItem(at: indexPath)

        if let notification = item?.jsonable as? Notification {
            if let comment = notification.activity.subject as? ElloComment {
                return comment.loadedFromPost
            }
            return notification.activity.subject as? Post
        }
        return item?.jsonable as? Post
    }

    public func imageAssetForIndexPath(indexPath: NSIndexPath) -> Asset? {
        let item = visibleStreamCellItem(at: indexPath)
        let region = item?.type.data as? ImageRegion
        return region?.asset
    }

    public func commentForIndexPath(indexPath: NSIndexPath) -> ElloComment? {
        return jsonableForIndexPath(indexPath) as? ElloComment
    }

    public func jsonableForIndexPath(indexPath: NSIndexPath) -> JSONAble? {
        let item = visibleStreamCellItem(at: indexPath)
        return item?.jsonable
    }

    public func visibleStreamCellItem(at indexPath: NSIndexPath) -> StreamCellItem? {
        if !isValidIndexPath(indexPath) { return nil }
        return visibleCellItems.safeValue(indexPath.item)
    }

    public func cellItemsForPost(post: Post) -> [StreamCellItem] {
        var tmp = [StreamCellItem]()
        temporarilyUnfilter {
            tmp = self.visibleCellItems.reduce([]) { arr, item in
                if let cellPost = item.jsonable as? Post where post.id == cellPost.id {
                    return arr + [item]
                }
                return arr
            }
        }
        return tmp
    }

    // this includes the `createComment` cell, `spacer` cell, and `seeMoreComments` cell since they contain a comment item
    public func commentIndexPathsForPost(post: Post) -> [NSIndexPath] {
        var indexPaths = [NSIndexPath]()
        for (index, value) in visibleCellItems.enumerate() {
            if let comment = value.jsonable as? ElloComment where comment.loadedFromPostId == post.id {
                indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
            }
        }
        return indexPaths
    }

    public func footerIndexPathForPost(searchPost: Post) -> NSIndexPath? {
        for (index, value) in visibleCellItems.enumerate() {
            if value.type == .Footer,
               let post = value.jsonable as? Post {
                if searchPost.id == post.id {
                    return NSIndexPath(forItem: index, inSection: 0)
                }
            }
        }
        return nil
    }

    public func createCommentIndexPathForPost(post: Post) -> NSIndexPath? {
        let paths = commentIndexPathsForPost(post)
        if paths.count > 0 {
            let path = paths[0]
            if let createCommentItem = visibleStreamCellItem(at: path) {
                if createCommentItem.type == .CreateComment {
                    return path
                }
            }
        }
        return nil
    }

    public func removeCommentsForPost(post: Post) -> [NSIndexPath] {
        let indexPaths = self.commentIndexPathsForPost(post)
        temporarilyUnfilter() {
            // these paths might be different depending on the filter
            let unfilteredIndexPaths = self.commentIndexPathsForPost(post)
            var newItems = [StreamCellItem]()
            for (index, item) in self.streamCellItems.enumerate() {
                let skip = unfilteredIndexPaths.any { $0.item == index }
                if !skip {
                    newItems.append(item)
                }
            }
            self.streamCellItems = newItems
        }
        return indexPaths
    }

    public func removeItemsAtIndexPaths(indexPaths: [NSIndexPath]) {
        var items: [StreamCellItem] = []
        for indexPath in indexPaths {
            if let itemToRemove = self.visibleCellItems.safeValue(indexPath.item) {
                items.append(itemToRemove)
            }
        }
        temporarilyUnfilter() {
            for itemToRemove in items {
                if let index = self.streamCellItems.indexOf(itemToRemove) {
                    self.streamCellItems.removeAtIndex(index)
                }
            }
        }
    }

    public func updateHeightForIndexPath(indexPath: NSIndexPath, height: CGFloat) {
        if indexPath.item < visibleCellItems.count {
            visibleCellItems[indexPath.item].calculatedOneColumnCellHeight = height
            visibleCellItems[indexPath.item].calculatedMultiColumnCellHeight = height
        }
    }

    public func heightForIndexPath(indexPath: NSIndexPath, numberOfColumns: NSInteger) -> CGFloat {
        if !isValidIndexPath(indexPath) { return 0 }

        // always try to return a calculated value before the default
        if numberOfColumns == 1 {
            if let height = visibleCellItems[indexPath.item].calculatedOneColumnCellHeight {
                return height
            }
            else {
                return visibleCellItems[indexPath.item].type.oneColumnHeight
            }
        }
        else {
            if let height = visibleCellItems[indexPath.item].calculatedMultiColumnCellHeight {
                return height
            }
            else {
                return visibleCellItems[indexPath.item].type.multiColumnHeight
            }
        }
    }

    public func isFullWidthAtIndexPath(indexPath: NSIndexPath) -> Bool {
        if !isValidIndexPath(indexPath) { return true }
        return visibleCellItems[indexPath.item].type.isFullWidth
    }

    public func groupForIndexPath(indexPath: NSIndexPath) -> String {
        if !isValidIndexPath(indexPath) { return "0" }

        return (visibleCellItems[indexPath.item].jsonable as? Groupable)?.groupId ?? "0"
    }

    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCellItems.count ?? 0
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard indexPath.item < visibleCellItems.count else {
            return UICollectionViewCell()
        }

        let streamCellItem = visibleCellItems[indexPath.item]

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(streamCellItem.type.name, forIndexPath: indexPath)

        switch streamCellItem.type {
        case .ColumnToggle:
            (cell as! ColumnToggleCell).columnToggleDelegate = columnToggleDelegate
        case .CategoryList:
            (cell as! CategoryListCell).discoverCategoryPickerDelegate = discoverCategoryPickerDelegate
        case .Footer:
            (cell as! StreamFooterCell).delegate = postbarDelegate
            (cell as! StreamFooterCell).streamEditingDelegate = editingDelegate
        case .CreateComment:
            (cell as! StreamCreateCommentCell).delegate = postbarDelegate
        case .Header, .CommentHeader:
            (cell as! StreamHeaderCell).relationshipDelegate = relationshipDelegate
            (cell as! StreamHeaderCell).postbarDelegate = postbarDelegate
            (cell as! StreamHeaderCell).categoryDelegate = categoryDelegate
            (cell as! StreamHeaderCell).userDelegate = userDelegate
            (cell as! StreamHeaderCell).streamEditingDelegate = editingDelegate
        case .Image:
            (cell as! StreamImageCell).streamImageCellDelegate = imageDelegate
            (cell as! StreamImageCell).streamEditingDelegate = editingDelegate
        case .InviteFriends:
            (cell as! StreamInviteFriendsCell).inviteDelegate = inviteDelegate
            (cell as! StreamInviteFriendsCell).inviteCache = inviteCache
        case .Notification:
            (cell as! NotificationCell).relationshipControl.relationshipDelegate = relationshipDelegate
            (cell as! NotificationCell).webLinkDelegate = webLinkDelegate
            (cell as! NotificationCell).userDelegate = userDelegate
            (cell as! NotificationCell).delegate = notificationDelegate
        case .ProfileHeader:
            (cell as! ProfileHeaderCell).simpleStreamDelegate = simpleStreamDelegate
            (cell as! ProfileHeaderCell).webLinkDelegate = webLinkDelegate
        case .Text:
            (cell as! StreamTextCell).webLinkDelegate = webLinkDelegate
            (cell as! StreamTextCell).userDelegate = userDelegate
            (cell as! StreamTextCell).streamEditingDelegate = editingDelegate
        case .UserAvatars:
            (cell as! UserAvatarsCell).simpleStreamDelegate = simpleStreamDelegate
            (cell as! UserAvatarsCell).userDelegate = userDelegate
        case .UserListItem:
            (cell as! UserListItemCell).relationshipControl.relationshipDelegate = relationshipDelegate
            (cell as! UserListItemCell).userDelegate = userDelegate
        case .ConversationMemberSelection:
            (cell as! ConversationMemberSelectionCell).conversationDelegate = conversationDelegate
        default:
            break
        }

        streamCellItem.type.configure(
            cell: cell,
            streamCellItem: streamCellItem,
            streamKind: streamKind,
            indexPath: indexPath,
            currentUser: currentUser
        )

        return cell
    }

    public func modifyItems(jsonable: JSONAble, change: ContentChange, collectionView: UICollectionView) {
        // get items that match id and type -> [IndexPath]
        // based on change decide to update/remove those items
        switch change {
        case .Create:
            var indexPath: NSIndexPath?
            var reloadPaths: [NSIndexPath]?

            // if comment, add new comment cells
            if let comment = jsonable as? ElloComment,
                parentPost = comment.loadedFromPost
            {
                let indexPaths = self.commentIndexPathsForPost(parentPost)
                if let first = indexPaths.first {
                    if self.visibleCellItems[first.item].type == .CreateComment {
                        indexPath = NSIndexPath(forItem: first.item + 1, inSection: first.section)
                    }
                }
                reloadPaths = indexPaths
            }

            // else if post, add new post cells
            else if jsonable is Post {
                indexPath = streamKind.clientSidePostInsertIndexPath(currentUser?.id)
            }

            // else if love, add post to loves
            else if jsonable is Love {
                indexPath = streamKind.clientSideLoveInsertIndexPath
            }

            if let indexPath = indexPath {
                self.insertUnsizedCellItems(
                    StreamCellItemParser().parse([jsonable], streamKind: self.streamKind, currentUser: currentUser),
                    withWidth: UIWindow.windowWidth(),
                    startingIndexPath: indexPath)
                    { newIndexPaths in
                        collectionView.insertItemsAtIndexPaths(newIndexPaths)
                        if let prevReloadPaths = reloadPaths {
                            let reloadPaths = prevReloadPaths.map { path in
                                return NSIndexPath(forItem: path.item + newIndexPaths.count, inSection: path.section)
                            }
                            collectionView.reloadItemsAtIndexPaths(reloadPaths)
                        }
                    }
            }

        case .Delete:
            collectionView.deleteItemsAtIndexPaths(removeItemsForJSONAble(jsonable, change: change))
        case .Replaced:
            let (oldIndexPaths, _) = elementsForJSONAble(jsonable, change: change)
            if let post = jsonable as? Post, firstIndexPath = oldIndexPaths.first {
                let firstIndexPath = oldIndexPaths.reduce(firstIndexPath) { (memo: NSIndexPath, path: NSIndexPath) in
                    if path.section == memo.section {
                        return path.item > memo.section ? memo : path
                    }
                    else {
                        return path.section > memo.section ? memo : path
                    }
                }
                let items = StreamCellItemParser().parse([post], streamKind: self.streamKind, currentUser: currentUser)
                insertUnsizedCellItems(items, withWidth: UIWindow.windowWidth(), startingIndexPath: firstIndexPath) { newIndexPaths in
                    for wrongIndexPath in Array(oldIndexPaths.reverse()) {
                        let indexPath = NSIndexPath(forItem: wrongIndexPath.item + newIndexPaths.count, inSection: wrongIndexPath.section)
                        self.removeItemsAtIndexPaths([indexPath])
                    }
                    collectionView.performBatchUpdates({
                        collectionView.insertItemsAtIndexPaths(newIndexPaths)
                        collectionView.deleteItemsAtIndexPaths(oldIndexPaths)
                    }, completion: nil)
                }
            }
            else if let comment = jsonable as? ElloComment, firstIndexPath = oldIndexPaths.first  {
                let firstIndexPath = oldIndexPaths.reduce(firstIndexPath) { (memo: NSIndexPath, path: NSIndexPath) in
                    if path.section == memo.section {
                        return path.item > memo.section ? memo : path
                    }
                    else {
                        return path.section > memo.section ? memo : path
                    }
                }
                let items = StreamCellItemParser().parse([comment], streamKind: self.streamKind, currentUser: currentUser)
                insertUnsizedCellItems(items, withWidth: UIWindow.windowWidth(), startingIndexPath: firstIndexPath) { newIndexPaths in
                    for wrongIndexPath in Array(oldIndexPaths.reverse()) {
                        let indexPath = NSIndexPath(forItem: wrongIndexPath.item + newIndexPaths.count, inSection: wrongIndexPath.section)
                        self.removeItemsAtIndexPaths([indexPath])
                    }
                    collectionView.performBatchUpdates({
                        collectionView.insertItemsAtIndexPaths(newIndexPaths)
                        collectionView.deleteItemsAtIndexPaths(oldIndexPaths)
                    }, completion: nil)
                }
            }
        case .Update:
            var shouldReload = true
            switch streamKind {
            case let .SimpleStream(endpoint, _):
                switch endpoint {
                case .Loves:
                    if let post = jsonable as? Post where !post.loved {
                        // the post was unloved
                        collectionView.deleteItemsAtIndexPaths(removeItemsForJSONAble(jsonable, change: .Delete))
                        shouldReload = false
                    }
                default: break
                }
            default: break
            }

            if shouldReload {
                let (indexPaths, items) = elementsForJSONAble(jsonable, change: change)
                for item in items {
                    item.jsonable = item.jsonable.merge(jsonable)
                }
                collectionView.reloadItemsAtIndexPaths(indexPaths)
            }
        case .Loved:
            let (_, items) = elementsForJSONAble(jsonable, change: change)
            var indexPaths = [NSIndexPath]()
            for item in items {
                if let path = indexPathForItem(item)
                where item.type == .Footer {
                    indexPaths.append(path)
                }
                item.jsonable = item.jsonable.merge(jsonable)
            }
            collectionView.reloadItemsAtIndexPaths(indexPaths)
        default: break
        }
    }

    public func modifyUserRelationshipItems(user: User, collectionView: UICollectionView) {
        let (changedPaths, changedItems) = elementsForJSONAble(user, change: .Update)

        for item in changedItems {
            if let oldUser = item.jsonable as? User {
                // relationship changes
                oldUser.relationshipPriority = user.relationshipPriority
                oldUser.followersCount = user.followersCount
                oldUser.followingCount = user.followingCount
            }

            if let authorable = item.jsonable as? Authorable,
                author = authorable.author
                where author.id == user.id
            {
                author.relationshipPriority = user.relationshipPriority
                author.followersCount = user.followersCount
                author.followingCount = user.followingCount
            }

            if let post = item.jsonable as? Post,
                repostAuthor = post.repostAuthor
                where repostAuthor.id == user.id
            {
                repostAuthor.relationshipPriority = user.relationshipPriority
                repostAuthor.followersCount = user.followersCount
                repostAuthor.followingCount = user.followingCount
            }
        }

        let reloadPaths: [NSIndexPath]
        if collectionView.window != nil {
            reloadPaths = changedPaths.filter { path in
                if let item = visibleStreamCellItem(at: path)
                    where item.type == .ProfileHeader
                {
                    return false
                }
                return true
            }
        }
        else {
            reloadPaths = changedPaths
        }
        collectionView.reloadItemsAtIndexPaths(reloadPaths)

        if user.relationshipPriority.isMutedOrBlocked {
            var shouldDelete = true

            switch streamKind {
            case let .UserStream(userId):
                shouldDelete = user.id != userId
            case let .SimpleStream(endpoint, _):
                if case .CurrentUserBlockedList = endpoint
                where user.relationshipPriority == .Block
                {
                    shouldDelete = false
                }
                else if case .CurrentUserMutedList = endpoint
                where user.relationshipPriority == .Mute
                {
                    shouldDelete = false
                }
            default:
                break
            }

            if shouldDelete {
                modifyItems(user, change: .Delete, collectionView: collectionView)
            }
        }
    }

    public func modifyUserSettingsItems(user: User, collectionView: UICollectionView) {
        let (changedPaths, changedItems) = elementsForJSONAble(user, change: .Update)
        for item in changedItems {
            if item.jsonable is User {
                item.jsonable = user
            }
        }
        collectionView.reloadItemsAtIndexPaths(changedPaths)
    }

    public func removeItemsForJSONAble(jsonable: JSONAble, change: ContentChange) -> [NSIndexPath] {
        let indexPaths = self.elementsForJSONAble(jsonable, change: change).0
        temporarilyUnfilter() {
            // these paths might be different depending on the filter
            let unfilteredIndexPaths = self.elementsForJSONAble(jsonable, change: change).0
            var newItems = [StreamCellItem]()
            for (index, item) in self.streamCellItems.enumerate() {
                let skip = unfilteredIndexPaths.any { $0.item == index }
                if !skip {
                    newItems.append(item)
                }
            }
            self.streamCellItems = newItems
        }
        return indexPaths
    }

    private func elementsForJSONAble(jsonable: JSONAble, change: ContentChange) -> ([NSIndexPath], [StreamCellItem]) {
        var indexPaths = [NSIndexPath]()
        var items = [StreamCellItem]()
        if let comment = jsonable as? ElloComment {
            for (index, item) in visibleCellItems.enumerate() {
                if let itemComment = item.jsonable as? ElloComment where comment.id == itemComment.id {
                    indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
                    items.append(item)
                }
            }
        }
        else if let post = jsonable as? Post {
            for (index, item) in visibleCellItems.enumerate() {
                if let itemPost = item.jsonable as? Post where post.id == itemPost.id {
                    indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
                    items.append(item)
                }
                else if change == .Delete || change == .Replaced {
                    if let itemComment = item.jsonable as? ElloComment where itemComment.loadedFromPostId == post.id || itemComment.postId == post.id {
                        indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
                        items.append(item)
                    }
                }
            }
        }
        else if let user = jsonable as? User {
            for (index, item) in visibleCellItems.enumerate() {
                switch user.relationshipPriority {
                case .Following, .Starred, .None, .Inactive, .Block, .Mute:
                    if let itemUser = item.jsonable as? User where user.id == itemUser.id {
                        indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
                        items.append(item)
                    }
                    else if let itemComment = item.jsonable as? ElloComment {
                        if  user.id == itemComment.authorId ||
                            user.id == itemComment.loadedFromPost?.authorId
                        {
                            indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
                            items.append(item)
                        }
                    }
                    else if let itemNotification = item.jsonable as? Notification where user.id == itemNotification.author?.id {
                        indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
                        items.append(item)
                    }
                    else if let itemPost = item.jsonable as? Post where user.id == itemPost.authorId {
                        indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
                        items.append(item)
                    }
                    else if let itemPost = item.jsonable as? Post where user.id == itemPost.repostAuthor?.id {
                        indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
                        items.append(item)
                    }
                default:
                    if let itemUser = item.jsonable as? User where user.id == itemUser.id {
                        indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
                        items.append(item)
                    }
                }
            }
        }
        return (indexPaths, items)
    }

    // MARK: Adding items
    public func appendStreamCellItems(items: [StreamCellItem]) {
        self.streamCellItems += items
        self.updateFilteredItems()
    }

    public func appendUnsizedCellItems(cellItems: [StreamCellItem], withWidth: CGFloat, completion: StreamContentReady) {
        let startingIndexPath = NSIndexPath(forItem: self.streamCellItems.count, inSection: 0)
        insertUnsizedCellItems(cellItems, withWidth: withWidth, startingIndexPath: startingIndexPath, completion: completion)
    }

    public func replaceItems(at indexPaths: [NSIndexPath], with streamCellItems: [StreamCellItem]) -> [NSIndexPath] {
        guard indexPaths.count > 0 else { return []}
        removeItemsAtIndexPaths(indexPaths)
        return insertStreamCellItems(streamCellItems, startingIndexPath: indexPaths[0])
    }

    public func insertStreamCellItems(cellItems: [StreamCellItem], startingIndexPath: NSIndexPath) -> [NSIndexPath] {
        // startingIndex represents the filtered index,
        // arrayIndex is the streamCellItems index
        let startingIndex = startingIndexPath.item
        var arrayIndex = startingIndexPath.item

        if let item = self.visibleStreamCellItem(at: startingIndexPath) {
            if let foundIndex = self.streamCellItems.indexOf(item) {
                arrayIndex = foundIndex
            }
        }
        else if arrayIndex == visibleCellItems.count {
            arrayIndex = streamCellItems.count
        }

        var indexPaths: [NSIndexPath] = []

        for (index, cellItem) in cellItems.enumerate() {
            indexPaths.append(NSIndexPath(forItem: startingIndex + index, inSection: startingIndexPath.section))

            let atIndex = arrayIndex + index
            if atIndex <= streamCellItems.count {
                streamCellItems.insert(cellItem, atIndex: arrayIndex + index)
            }
            else {
                streamCellItems.append(cellItem)
            }
        }

        self.updateFilteredItems()
        return indexPaths
    }

    public func insertUnsizedCellItems(cellItems: [StreamCellItem], withWidth: CGFloat, startingIndexPath: NSIndexPath, completion: StreamContentReady) {
        self.calculateCellItems(cellItems, withWidth: withWidth) {
            let indexPaths = self.insertStreamCellItems(cellItems, startingIndexPath: startingIndexPath)
            completion(indexPaths: indexPaths)
        }
    }

    public func toggleCollapsedForIndexPath(indexPath: NSIndexPath) {
        if let post = self.postForIndexPath(indexPath),
            cellItem = self.visibleStreamCellItem(at: indexPath)
        {
            let newState: StreamCellState = cellItem.state == .Expanded ? .Collapsed : .Expanded
            let cellItems = self.cellItemsForPost(post)
            for item in cellItems {
                // don't toggle the footer's state, it is used by comment open/closed
                if item.type != .Footer {
                    item.state = newState
                }
            }
            self.updateFilteredItems()
        }
    }

    public func isValidIndexPath(indexPath: NSIndexPath) -> Bool {
        return indexPath.item >= 0 &&  indexPath.item < visibleCellItems.count && indexPath.section == 0
    }

    public func calculateCellItems(cellItems: [StreamCellItem], withWidth: CGFloat, completion: ElloEmptyCompletion) {
        let textCells = filterTextCells(cellItems)
        let imageCells = filterImageCells(cellItems)
        let notificationElements = cellItems.filter {
            return $0.type == StreamCellType.Notification
        }
        let profileHeaderItems = cellItems.filter {
            return $0.type == StreamCellType.ProfileHeader
        }
        let afterAll = after(4, block: completion)

        self.imageSizeCalculator.processCells(imageCells.normal + imageCells.repost, withWidth: withWidth, columnCount: self.streamKind.columnCount, completion: afterAll)

        // -30.0 acounts for the 15 on either side for constraints
        let textLeftRightConstraintWidth = (StreamTextCellPresenter.postMargin * 2)
        self.textSizeCalculator.processCells(textCells.normal, withWidth: withWidth - textLeftRightConstraintWidth, columnCount: streamKind.columnCount) {
            // extra -30.0 acounts for the left indent on a repost with the black line
            self.textSizeCalculator.processCells(textCells.repost, withWidth: withWidth - (textLeftRightConstraintWidth * 2), columnCount: self.streamKind.columnCount, completion: afterAll)
        }
        self.notificationSizeCalculator.processCells(notificationElements, withWidth: withWidth, columnCount: streamKind.columnCount, completion: afterAll)
        self.profileHeaderSizeCalculator.processCells(profileHeaderItems, withWidth: withWidth, columnCount: streamKind.columnCount, completion: afterAll)
    }

    private func filterTextCells(cellItems: [StreamCellItem]) -> (normal: [StreamCellItem], repost: [StreamCellItem]) {
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

    private func filterImageCells(cellItems: [StreamCellItem]) -> (normal: [StreamCellItem], repost: [StreamCellItem]) {
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

    private func temporarilyUnfilter(@noescape block: ElloEmptyCompletion) {
        let cachedStreamFilter = streamFilter
        let cachedStreamCollapsedFilter = streamCollapsedFilter
        self.streamFilter = nil
        self.streamCollapsedFilter = nil
        updateFilteredItems()

        block()

        self.streamFilter = cachedStreamFilter
        self.streamCollapsedFilter = cachedStreamCollapsedFilter
        updateFilteredItems()
    }

    private func updateFilteredItems() {
        self.visibleCellItems = self.streamCellItems

        if let streamFilter = streamFilter {
            self.visibleCellItems = self.visibleCellItems.filter { item in
                return item.alwaysShow() || streamFilter(item)
            }
        }

        if let streamCollapsedFilter = streamCollapsedFilter {
            self.visibleCellItems = self.visibleCellItems.filter { item in
                return item.alwaysShow() || streamCollapsedFilter(item)
            }
        }
    }
}

// MARK: For Testing
public extension StreamDataSource {
    public func testingElementsForJSONAble(jsonable: JSONAble, change: ContentChange) -> ([NSIndexPath], [StreamCellItem]) {
        return elementsForJSONAble(jsonable, change: change)
    }
}
