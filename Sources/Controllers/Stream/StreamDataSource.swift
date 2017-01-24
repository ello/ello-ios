////
///  StreamDataSource.swift
//

import WebKit
import DeltaCalculator


class StreamDataSource: NSObject, UICollectionViewDataSource {

    typealias StreamContentReady = (_ indexPaths: [IndexPath]) -> Void
    typealias StreamFilter = ((StreamCellItem) -> Bool)?

    var streamKind: StreamKind
    var currentUser: User?

    // these are the items assigned from the parent controller
    var streamCellItems: [StreamCellItem] = []

    // these are either the same as streamCellItems (no filter) or if a filter
    // is applied this stores the filtered items
    fileprivate(set) var visibleCellItems: [StreamCellItem] = []

    // if a filter is added or removed, we update the items
    var streamFilter: StreamFilter {
        didSet { updateFilteredItems() }
    }

    // if a filter is added or removed, we update the items
    var streamCollapsedFilter: StreamFilter {
        didSet { updateFilteredItems() }
    }

    let textSizeCalculator: StreamTextCellSizeCalculator
    let notificationSizeCalculator: StreamNotificationCellSizeCalculator
    let announcementSizeCalculator: AnnouncementCellSizeCalculator
    let profileHeaderSizeCalculator: ProfileHeaderCellSizeCalculator
    let categoryHeaderSizeCalculator: CategoryHeaderCellSizeCalculator
    let imageSizeCalculator: StreamImageCellSizeCalculator

    weak var postbarDelegate: PostbarDelegate?
    weak var createPostDelegate: CreatePostDelegate?
    weak var notificationDelegate: NotificationDelegate?
    weak var webLinkDelegate: WebLinkDelegate?
    weak var imageDelegate: StreamImageCellDelegate?
    weak var editingDelegate: StreamEditingDelegate?
    weak var categoryDelegate: CategoryDelegate?
    weak var userDelegate: UserDelegate?
    weak var relationshipDelegate: RelationshipDelegate?
    weak var simpleStreamDelegate: SimpleStreamDelegate?
    weak var searchStreamDelegate: SearchStreamDelegate?
    weak var inviteDelegate: InviteDelegate?
    weak var categoryListCellDelegate: CategoryListCellDelegate?
    weak var announcementCellDelegate: AnnouncementCellDelegate?
    var inviteCache = InviteCache()

    init(
        streamKind: StreamKind,
        textSizeCalculator: StreamTextCellSizeCalculator,
        notificationSizeCalculator: StreamNotificationCellSizeCalculator,
        announcementSizeCalculator: AnnouncementCellSizeCalculator,
        profileHeaderSizeCalculator: ProfileHeaderCellSizeCalculator,
        imageSizeCalculator: StreamImageCellSizeCalculator,
        categoryHeaderSizeCalculator: CategoryHeaderCellSizeCalculator)
    {
        self.streamKind = streamKind
        self.textSizeCalculator = textSizeCalculator
        self.notificationSizeCalculator = notificationSizeCalculator
        self.announcementSizeCalculator = announcementSizeCalculator
        self.profileHeaderSizeCalculator = profileHeaderSizeCalculator
        self.imageSizeCalculator = imageSizeCalculator
        self.categoryHeaderSizeCalculator = categoryHeaderSizeCalculator
        super.init()
    }

    // MARK: - Public

    func removeAllCellItems() {
        streamCellItems = []
        updateFilteredItems()
    }

    func updateFilter(_ filter: StreamFilter) -> Delta {
        let prevItems = visibleCellItems
        streamFilter = filter

        let calculator = DeltaCalculator<StreamCellItem>()
        return calculator.deltaFromOldArray(prevItems, toNewArray: visibleCellItems)
    }

    func indexPathForItem(_ item: StreamCellItem) -> IndexPath? {
        if let index = self.visibleCellItems.index(where: {$0 == item}) {
            return IndexPath(item: index, section: 0)
        }
        return nil
    }

    func hasCellItems(for placeholderType: StreamCellType.PlaceholderType) -> Bool {
        // don't filter on 'type', because we need to check that the number of
        // items is 1 or 0, and if it's 1, then we need to see if its type is
        // .Placeholder
        let items = streamCellItems.filter {
            $0.placeholderType == placeholderType
        }
        if let item = items.first, items.count == 1 {
            switch item.type {
            case .placeholder:
                return false
            default:
                return true
            }
        }
        return items.count > 0
    }

    func indexPathsForPlaceholderType(_ placeholderType: StreamCellType.PlaceholderType) -> [IndexPath] {
        guard let index = self.visibleCellItems.index(where: {$0.placeholderType == placeholderType}) else { return [] }

        let indexPath = IndexPath(item: index, section: 0)
        var indexPaths = [indexPath]
        var position = indexPath.item
        var found = true
        while found && position < self.visibleCellItems.count - 1 {
            position += 1
            found = visibleCellItems[position].placeholderType == placeholderType
            if found {
                indexPaths.append(IndexPath(item: position, section: 0))
            }
        }
        return indexPaths
    }

    func userForIndexPath(_ indexPath: IndexPath) -> User? {
        if let item = visibleStreamCellItem(at: indexPath) {
            if case .header = item.type,
                let repostAuthor = (item.jsonable as? Post)?.repostAuthor
            {
                return repostAuthor
            }

            if case .pagePromotionalHeader = item.type,
                let user = (item.jsonable as? PagePromotional)?.user
            {
                return user
            }

            if case .categoryPromotionalHeader = item.type,
                let user = (item.jsonable as? Category)?.randomPromotional?.user
            {
                return user
            }

            if let authorable = item.jsonable as? Authorable {
                return authorable.author
            }

            return item.jsonable as? User
        }
        return nil
    }

    func reposterForIndexPath(_ indexPath: IndexPath) -> User? {
        if let item = visibleStreamCellItem(at: indexPath) {
            if let authorable = item.jsonable as? Authorable {
                return authorable.author
            }
            return item.jsonable as? User
        }
        return nil
    }

    func postForIndexPath(_ indexPath: IndexPath) -> Post? {
        let item = visibleStreamCellItem(at: indexPath)

        if let notification = item?.jsonable as? Notification {
            if let comment = notification.activity.subject as? ElloComment {
                return comment.loadedFromPost
            }
            return notification.activity.subject as? Post
        }
        return item?.jsonable as? Post
    }

    func imageAssetForIndexPath(_ indexPath: IndexPath) -> Asset? {
        let item = visibleStreamCellItem(at: indexPath)
        let region = item?.type.data as? ImageRegion
        return region?.asset
    }

    func commentForIndexPath(_ indexPath: IndexPath) -> ElloComment? {
        return jsonableForIndexPath(indexPath) as? ElloComment
    }

    func jsonableForIndexPath(_ indexPath: IndexPath) -> JSONAble? {
        let item = visibleStreamCellItem(at: indexPath)
        return item?.jsonable
    }

    func visibleStreamCellItem(at indexPath: IndexPath) -> StreamCellItem? {
        if !isValidIndexPath(indexPath) { return nil }
        return visibleCellItems.safeValue(indexPath.item)
    }

    func cellItemsForPost(_ post: Post) -> [StreamCellItem] {
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
    func commentIndexPathsForPost(_ post: Post) -> [IndexPath] {
        var indexPaths = [IndexPath]()
        for (index, value) in visibleCellItems.enumerated() {
            if let comment = value.jsonable as? ElloComment, comment.loadedFromPostId == post.id {
                indexPaths.append(IndexPath(item: index, section: 0))
            }
        }
        return indexPaths
    }

    func footerIndexPathForPost(_ searchPost: Post) -> IndexPath? {
        for (index, value) in visibleCellItems.enumerated() {
            if value.type == .footer,
               let post = value.jsonable as? Post {
                if searchPost.id == post.id {
                    return IndexPath(item: index, section: 0)
                }
            }
        }
        return nil
    }

    func createCommentIndexPathForPost(_ post: Post) -> IndexPath? {
        let paths = commentIndexPathsForPost(post)
        if paths.count > 0 {
            let path = paths[0]
            if let createCommentItem = visibleStreamCellItem(at: path) {
                if createCommentItem.type == .createComment {
                    return path
                }
            }
        }
        return nil
    }

    func removeCommentsFor(post: Post) -> [IndexPath] {
        let indexPaths = self.commentIndexPathsForPost(post)
        temporarilyUnfilter() {
            // these paths might be different depending on the filter
            let unfilteredIndexPaths = self.commentIndexPathsForPost(post)
            var newItems = [StreamCellItem]()
            for (index, item) in self.streamCellItems.enumerated() {
                let skip = unfilteredIndexPaths.any { $0.item == index }
                if !skip {
                    newItems.append(item)
                }
            }
            self.streamCellItems = newItems
        }
        return indexPaths
    }

    func removeItemsAtIndexPaths(_ indexPaths: [IndexPath]) {
        var items: [StreamCellItem] = []
        for indexPath in indexPaths {
            if let itemToRemove = self.visibleCellItems.safeValue(indexPath.item) {
                items.append(itemToRemove)
            }
        }
        temporarilyUnfilter() {
            for itemToRemove in items {
                if let index = self.streamCellItems.index(of: itemToRemove) {
                    self.streamCellItems.remove(at: index)
                }
            }
        }
    }

    func updateHeightForIndexPath(_ indexPath: IndexPath, height: CGFloat) {
        if indexPath.item < visibleCellItems.count {
            visibleCellItems[indexPath.item].calculatedCellHeights.oneColumn = height
            visibleCellItems[indexPath.item].calculatedCellHeights.multiColumn = height
        }
    }

    func heightForIndexPath(_ indexPath: IndexPath, numberOfColumns: NSInteger) -> CGFloat {
        if !isValidIndexPath(indexPath) { return 0 }

        // always try to return a calculated value before the default
        if numberOfColumns == 1 {
            if let height = visibleCellItems[indexPath.item].calculatedCellHeights.oneColumn {
                return height
            }
            else {
                return visibleCellItems[indexPath.item].type.oneColumnHeight
            }
        }
        else {
            if let height = visibleCellItems[indexPath.item].calculatedCellHeights.multiColumn {
                return height
            }
            else {
                return visibleCellItems[indexPath.item].type.multiColumnHeight
            }
        }
    }

    func isFullWidthAtIndexPath(_ indexPath: IndexPath) -> Bool {
        if !isValidIndexPath(indexPath) { return true }
        return visibleCellItems[indexPath.item].type.isFullWidth
    }

    func groupForIndexPath(_ indexPath: IndexPath) -> String? {
        if !isValidIndexPath(indexPath) { return nil }

        return (visibleCellItems[indexPath.item].jsonable as? Groupable)?.groupId
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCellItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.item < visibleCellItems.count else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: StreamCellType.unknown.name, for: indexPath)
        }

        let streamCellItem = visibleCellItems[indexPath.item]

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: streamCellItem.type.name, for: indexPath)

        switch streamCellItem.type {
        case .announcement:
            (cell as! AnnouncementCell).delegate = announcementCellDelegate
        case .categoryPromotionalHeader,
             .pagePromotionalHeader:
            (cell as! CategoryHeaderCell).webLinkDelegate = webLinkDelegate
            (cell as! CategoryHeaderCell).userDelegate = userDelegate
        case .categoryList:
            (cell as! CategoryListCell).delegate = categoryListCellDelegate
        case .footer:
            (cell as! StreamFooterCell).delegate = postbarDelegate
            (cell as! StreamFooterCell).streamEditingDelegate = editingDelegate
        case .createComment:
            (cell as! StreamCreateCommentCell).delegate = postbarDelegate
        case .header, .commentHeader:
            (cell as! StreamHeaderCell).relationshipDelegate = relationshipDelegate
            (cell as! StreamHeaderCell).postbarDelegate = postbarDelegate
            (cell as! StreamHeaderCell).categoryDelegate = categoryDelegate
            (cell as! StreamHeaderCell).userDelegate = userDelegate
            (cell as! StreamHeaderCell).streamEditingDelegate = editingDelegate
        case .image:
            (cell as! StreamImageCell).streamImageCellDelegate = imageDelegate
            (cell as! StreamImageCell).streamEditingDelegate = editingDelegate
        case .inviteFriends, .onboardingInviteFriends:
            (cell as! StreamInviteFriendsCell).inviteDelegate = inviteDelegate
            (cell as! StreamInviteFriendsCell).inviteCache = inviteCache
        case .notification:
            (cell as! NotificationCell).relationshipControl.relationshipDelegate = relationshipDelegate
            (cell as! NotificationCell).webLinkDelegate = webLinkDelegate
            (cell as! NotificationCell).userDelegate = userDelegate
            (cell as! NotificationCell).delegate = notificationDelegate
        case .profileHeader:
            (cell as! ProfileHeaderCell).webLinkDelegate = webLinkDelegate
        case .search:
            (cell as! SearchStreamCell).delegate = searchStreamDelegate
        case .text:
            (cell as! StreamTextCell).webLinkDelegate = webLinkDelegate
            (cell as! StreamTextCell).userDelegate = userDelegate
            (cell as! StreamTextCell).streamEditingDelegate = editingDelegate
        case .userAvatars:
            (cell as! UserAvatarsCell).simpleStreamDelegate = simpleStreamDelegate
            (cell as! UserAvatarsCell).userDelegate = userDelegate
        case .userListItem:
            (cell as! UserListItemCell).relationshipControl.relationshipDelegate = relationshipDelegate
            (cell as! UserListItemCell).userDelegate = userDelegate
        default:
            break
        }

        streamCellItem.type.configure(
            cell,
            streamCellItem,
            streamKind,
            indexPath,
            currentUser
        )

        return cell
    }

    func clientSidePostInsertIndexPath() -> IndexPath? {
        let currentUserId = currentUser?.id

        switch streamKind {
        case .following:
            return IndexPath(item: 0, section: 0)
        case .currentUserStream:
            if visibleCellItems.count == 2 && visibleCellItems[1].type == .noPosts {
                removeItemsAtIndexPaths([IndexPath(item: 1, section: 0)])
                return IndexPath(item: 1, section: 0)
            }
            return IndexPath(item: 2, section: 0)
        case let .userStream(userParam):
            if currentUserId == userParam {
                if visibleCellItems.count == 2 && visibleCellItems[1].type == .noPosts {
                    removeItemsAtIndexPaths([IndexPath(item: 1, section: 0)])
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

    func modifyItems(_ jsonable: JSONAble, change: ContentChange, collectionView: ElloCollectionView) {
        // get items that match id and type -> [IndexPath]
        // based on change decide to update/remove those items
        switch change {
        case .create:
            var indexPath: IndexPath?

            // if comment, add new comment cells
            if let comment = jsonable as? ElloComment,
                let parentPost = comment.loadedFromPost
            {
                let indexPaths = self.commentIndexPathsForPost(parentPost)
                if let first = indexPaths.first, self.visibleCellItems[first.item].type == .createComment
                {
                    indexPath = IndexPath(item: first.item + 1, section: first.section)
                }
            }
            // else if post, add new post cells
            else if jsonable is Post {
                indexPath = clientSidePostInsertIndexPath()
            }
            // else if love, add post to loves
            else if jsonable is Love {
                indexPath = clientSideLoveInsertIndexPath()
            }

            if let indexPath = indexPath {
                self.insertUnsizedCellItems(
                    StreamCellItemParser().parse([jsonable], streamKind: self.streamKind, currentUser: currentUser),
                    withWidth: UIWindow.windowWidth(),
                    startingIndexPath: indexPath)
                    { newIndexPaths in
                        delay(0.5) {  // no one hates this more than me - colin
                            collectionView.reloadData()
                        }
                    }
            }

        case .delete:
            removeItemsFor(jsonable: jsonable, change: change)
            collectionView.reloadData() // deleteItemsAtIndexPaths(indexPaths)
        case .replaced:
            let (oldIndexPaths, _) = elementsFor(jsonable: jsonable, change: change)
            if let post = jsonable as? Post, let firstIndexPath = oldIndexPaths.first {
                let firstIndexPath = oldIndexPaths.reduce(firstIndexPath) { (memo: IndexPath, path: IndexPath) in
                    if path.section == memo.section {
                        return path.item > memo.section ? memo : path
                    }
                    else {
                        return path.section > memo.section ? memo : path
                    }
                }
                let items = StreamCellItemParser().parse([post], streamKind: self.streamKind, currentUser: currentUser)
                insertUnsizedCellItems(items, withWidth: UIWindow.windowWidth(), startingIndexPath: firstIndexPath) { newIndexPaths in
                    for wrongIndexPath in Array(oldIndexPaths.reversed()) {
                        let indexPath = IndexPath(item: wrongIndexPath.item + newIndexPaths.count, section: wrongIndexPath.section)
                        self.removeItemsAtIndexPaths([indexPath])
                    }
                    // collectionView.performBatchUpdates({
                    //     collectionView.insertItemsAtIndexPaths(newIndexPaths)
                    //     collectionView.deleteItemsAtIndexPaths(oldIndexPaths)
                    // }, completion: nil)
                    collectionView.reloadData()
                }
            }
            else if let comment = jsonable as? ElloComment, let firstIndexPath = oldIndexPaths.first  {
                let firstIndexPath = oldIndexPaths.reduce(firstIndexPath) { (memo: IndexPath, path: IndexPath) in
                    if path.section == memo.section {
                        return path.item > memo.section ? memo : path
                    }
                    else {
                        return path.section > memo.section ? memo : path
                    }
                }
                let items = StreamCellItemParser().parse([comment], streamKind: self.streamKind, currentUser: currentUser)
                insertUnsizedCellItems(items, withWidth: UIWindow.windowWidth(), startingIndexPath: firstIndexPath) { newIndexPaths in
                    for wrongIndexPath in Array(oldIndexPaths.reversed()) {
                        let indexPath = IndexPath(item: wrongIndexPath.item + newIndexPaths.count, section: wrongIndexPath.section)
                        self.removeItemsAtIndexPaths([indexPath])
                    }
                    // collectionView.performBatchUpdates({
                    //     collectionView.insertItemsAtIndexPaths(newIndexPaths)
                    //     collectionView.deleteItemsAtIndexPaths(oldIndexPaths)
                    // }, completion: nil)
                    collectionView.reloadData()
                }
            }
        case .update:
            var shouldReload = true
            switch streamKind {
            case let .simpleStream(endpoint, _):
                switch endpoint {
                case .loves:
                    if let post = jsonable as? Post, !post.loved {
                        // the post was unloved
                        removeItemsFor(jsonable: jsonable, change: .delete)
                        collectionView.reloadData() // deleteItemsAtIndexPaths(indexPaths)
                        shouldReload = false
                    }
                default: break
                }
            default: break
            }

            if shouldReload {
                mergeAndReloadElementsFor(jsonable: jsonable, change: change, collectionView: collectionView)
            }
        case .loved,
             .reposted,
             .watching:
            mergeAndReloadElementsFor(jsonable: jsonable, change: change, collectionView: collectionView)
        default: break
        }
    }

    func mergeAndReloadElementsFor(jsonable: JSONAble, change: ContentChange, collectionView: ElloCollectionView) {
        let (_, items) = elementsFor(jsonable: jsonable, change: change)
        for item in items {
            item.jsonable = item.jsonable.merge(jsonable)
        }
        collectionView.reloadData() // reload(indexPaths)
    }

    func modifyUserRelationshipItems(_ user: User, collectionView: ElloCollectionView) {
        let (_, changedItems) = elementsFor(jsonable: user, change: .update)

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

        collectionView.reloadData()

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
                modifyItems(user, change: .delete, collectionView: collectionView)
            }
        }
    }

    func modifyUserSettingsItems(_ user: User, collectionView: ElloCollectionView) {
        let (_, changedItems) = elementsFor(jsonable: user, change: .update)
        for item in changedItems {
            if item.jsonable is User {
                item.jsonable = user
            }
        }
        collectionView.reloadData()
    }

    @discardableResult
    func removeItemsFor(jsonable: JSONAble, change: ContentChange) -> [IndexPath] {
        let indexPaths = self.elementsFor(jsonable: jsonable, change: change).0
        temporarilyUnfilter() {
            // these paths might be different depending on the filter
            let unfilteredIndexPaths = self.elementsFor(jsonable: jsonable, change: change).0
            var newItems = [StreamCellItem]()
            for (index, item) in self.streamCellItems.enumerated() {
                let skip = unfilteredIndexPaths.any { $0.item == index }
                if !skip {
                    newItems.append(item)
                }
            }
            self.streamCellItems = newItems
        }
        return indexPaths
    }

    fileprivate func elementsFor(jsonable: JSONAble, change: ContentChange) -> ([IndexPath], [StreamCellItem]) {
        var indexPaths = [IndexPath]()
        var items = [StreamCellItem]()
        if let post = jsonable as? Post {
            for (index, item) in visibleCellItems.enumerated() {
                if let itemPost = item.jsonable as? Post, post.id == itemPost.id {
                    indexPaths.append(IndexPath(item: index, section: 0))
                    items.append(item)
                }
                else if change == .delete || change == .replaced {
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
                case .following, .starred, .none, .inactive, .block, .mute:
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

    // MARK: Adding items
    func appendStreamCellItems(_ items: [StreamCellItem]) {
        self.streamCellItems += items
        self.updateFilteredItems()
    }

    func appendUnsizedCellItems(_ cellItems: [StreamCellItem], withWidth: CGFloat, completion: @escaping StreamContentReady) {
        let startingIndexPath = IndexPath(item: self.streamCellItems.count, section: 0)
        insertUnsizedCellItems(cellItems, withWidth: withWidth, startingIndexPath: startingIndexPath, completion: completion)
    }

    func replaceItems(at indexPaths: [IndexPath], with streamCellItems: [StreamCellItem]) -> [IndexPath] {
        guard indexPaths.count > 0 else { return [] }
        removeItemsAtIndexPaths(indexPaths)
        return insertStreamCellItems(streamCellItems, startingIndexPath: indexPaths[0])
    }

    @discardableResult
    func insertStreamCellItems(_ cellItems: [StreamCellItem], startingIndexPath: IndexPath) -> [IndexPath] {
        // startingIndex represents the filtered index,
        // arrayIndex is the streamCellItems index
        let startingIndex = startingIndexPath.item
        var arrayIndex = startingIndexPath.item

        if let item = self.visibleStreamCellItem(at: startingIndexPath) {
            if let foundIndex = self.streamCellItems.index(of: item) {
                arrayIndex = foundIndex
            }
        }
        else if arrayIndex == visibleCellItems.count {
            arrayIndex = streamCellItems.count
        }

        var indexPaths: [IndexPath] = []

        for (index, cellItem) in cellItems.enumerated() {
            indexPaths.append(IndexPath(item: startingIndex + index, section: startingIndexPath.section))

            let atIndex = arrayIndex + index
            if atIndex <= streamCellItems.count {
                streamCellItems.insert(cellItem, at: atIndex)
            }
            else {
                streamCellItems.append(cellItem)
            }
        }

        self.updateFilteredItems()
        return indexPaths
    }

    func insertUnsizedCellItems(_ cellItems: [StreamCellItem], withWidth: CGFloat, startingIndexPath: IndexPath, completion: @escaping StreamContentReady) {
        self.calculateCellItems(cellItems, withWidth: withWidth) {
            let indexPaths = self.insertStreamCellItems(cellItems, startingIndexPath: startingIndexPath)
            completion(indexPaths)
        }
    }

    func toggleCollapsedForIndexPath(_ indexPath: IndexPath) {
        if let post = self.postForIndexPath(indexPath),
            let cellItem = self.visibleStreamCellItem(at: indexPath)
        {
            let newState: StreamCellState = cellItem.state == .expanded ? .collapsed : .expanded
            let cellItems = self.cellItemsForPost(post)
            for item in cellItems {
                // don't toggle the footer's state, it is used by comment open/closed
                if item.type != .footer {
                    item.state = newState
                }
            }
            self.updateFilteredItems()
        }
    }

    func isValidIndexPath(_ indexPath: IndexPath) -> Bool {
        return indexPath.item >= 0 &&  indexPath.item < visibleCellItems.count && indexPath.section == 0
    }

    func calculateCellItems(_ cellItems: [StreamCellItem], withWidth: CGFloat, completion: @escaping ElloEmptyCompletion) {
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

        let (afterAll, done) = afterN(completion)
        // -30.0 acounts for the 15 on either side for constraints
        let textLeftRightConstraintWidth = (StreamTextCellPresenter.postMargin * 2)
        textSizeCalculator.processCells(textCells.normal, withWidth: withWidth - textLeftRightConstraintWidth, columnCount: streamKind.columnCount, completion: afterAll())
        // extra -30.0 acounts for the left indent on a repost with the black line
        let repostLeftRightConstraintWidth = textLeftRightConstraintWidth + StreamTextCellPresenter.repostMargin
        textSizeCalculator.processCells(textCells.repost, withWidth: withWidth - repostLeftRightConstraintWidth, columnCount: streamKind.columnCount, completion: afterAll())
        imageSizeCalculator.processCells(imageCells.normal + imageCells.repost, withWidth: withWidth, columnCount: streamKind.columnCount, completion: afterAll())
        notificationSizeCalculator.processCells(notificationElements, withWidth: withWidth, completion: afterAll())
        announcementSizeCalculator.processCells(announcementElements, withWidth: withWidth, completion: afterAll())
        profileHeaderSizeCalculator.processCells(profileHeaderItems, withWidth: withWidth, columnCount: streamKind.columnCount, completion: afterAll())
        categoryHeaderSizeCalculator.processCells(categoryHeaderItems, withWidth: withWidth, completion: afterAll())
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

    fileprivate func temporarilyUnfilter(_ block: @escaping ElloEmptyCompletion) {
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

    fileprivate func updateFilteredItems() {
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
extension StreamDataSource {
    func testingElementsFor(jsonable: JSONAble, change: ContentChange) -> ([IndexPath], [StreamCellItem]) {
        return elementsFor(jsonable: jsonable, change: change)
    }
}
