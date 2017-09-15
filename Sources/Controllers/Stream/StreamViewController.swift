////
///  StreamViewController.swift
//

import SSPullToRefresh
import FLAnimatedImage
import SwiftyUserDefaults
import DeltaCalculator
import SnapKit
import PromiseKit


// MARK: StreamNotification
struct StreamNotification {
    static let UpdateCellHeightNotification = TypedNotification<StreamCellItem>(name: "UpdateCellHeightNotification")
}

// This is an NSObject in order to pass it as an
// objective-c argument to a responder chain call
class NoResultsMessages: NSObject {
    let title: String
    let body: String
    init(title: String, body: String) {
        self.title = title
        self.body = body
    }
}

// MARK: StreamViewController
final class StreamViewController: BaseElloViewController {
    override func trackerName() -> String? { return nil }

    let collectionView = ElloCollectionView(frame: .zero, collectionViewLayout: StreamCollectionViewLayout())
    let noResultsLabel = UILabel()
    var noResultsTopConstraint: NSLayoutConstraint!
    fileprivate let defaultNoResultsTopConstant: CGFloat = 113

    override var next: UIResponder? {
        return postbarController
    }

    var currentJSONables = [JSONAble]()

    var noResultsMessages: NoResultsMessages = NoResultsMessages(title: "", body: "") {
        didSet {
            let titleParagraphStyle = NSMutableParagraphStyle()
            titleParagraphStyle.lineSpacing = 17

            let titleAttributes = [
                NSFontAttributeName: UIFont.defaultBoldFont(18),
                NSForegroundColorAttributeName: UIColor.black,
                NSParagraphStyleAttributeName: titleParagraphStyle
            ]

            let bodyParagraphStyle = NSMutableParagraphStyle()
            bodyParagraphStyle.lineSpacing = 8

            let bodyAttributes = [
                NSFontAttributeName: UIFont.defaultFont(),
                NSForegroundColorAttributeName: UIColor.black,
                NSParagraphStyleAttributeName: bodyParagraphStyle
            ]

            let title = NSAttributedString(string: self.noResultsMessages.title + "\n", attributes: titleAttributes)
            let body = NSAttributedString(string: self.noResultsMessages.body, attributes: bodyAttributes)
            self.noResultsLabel.attributedText = title.appending(body)
        }
    }

    typealias ToggleClosure = (Bool) -> Void

    var dataSource: StreamDataSource!
    var collectionViewDataSource: CollectionViewDataSource!

    var postbarController: PostbarController?
    var responseConfig: ResponseConfig?

    var pullToRefreshView: SSPullToRefreshView?
    var allOlderPagesLoaded = false
    var initialLoadClosure: Block?
    var reloadClosure: Block?
    var toggleClosure: ToggleClosure?
    var initialDataLoaded = false

    var streamKind: StreamKind = StreamKind.unknown {
        didSet {
            dataSource.streamKind = streamKind
            collectionViewDataSource.streamKind = streamKind
            setupCollectionViewLayout()
        }
    }
    var imageViewer: StreamImageViewer?
    var updateCellHeightNotification: NotificationObserver?
    var rotationNotification: NotificationObserver?
    var sizeChangedNotification: NotificationObserver?
    var commentChangedNotification: NotificationObserver?
    var postChangedNotification: NotificationObserver?
    var jsonableChangedNotification: NotificationObserver?
    var relationshipChangedNotification: NotificationObserver?
    var settingChangedNotification: NotificationObserver?
    var currentUserChangedNotification: NotificationObserver?

    weak var streamViewDelegate: StreamViewDelegate?

    fileprivate var dataChangeJobs: [(
        newItems: [StreamCellItem],
        change: StreamViewDataChange,
        promise: Promise<Void>,
        resolve: () -> Void)] = []
    fileprivate var isRunningDataChangeJobs = false

    var contentInset: UIEdgeInsets {
        get { return collectionView.contentInset }
        set {
            // the order here is important, because SSPullToRefresh will try to
            // set the contentInset, and that can have weird side effects, so
            // we need to set the contentInset *after* pullToRefreshView.
            pullToRefreshView?.defaultContentInset = newValue
            collectionView.contentInset = newValue
            collectionView.scrollIndicatorInsets = newValue
        }
    }
    var columnCount: Int {
        guard let layout = collectionView.collectionViewLayout as? StreamCollectionViewLayout else {
            return 1
        }
        return layout.columnCount
    }

    var isPullToRefreshEnabled: Bool = true {
        didSet { pullToRefreshView?.isHidden = !isPullToRefreshEnabled }
    }
    var isPagingEnabled = false
    fileprivate var scrollToPaginateGuard = false

    lazy var loadingToken: LoadingToken = self.createLoadingToken()

    // moved into a separate function to save compile time
    fileprivate func createLoadingToken() -> LoadingToken {
        var token = LoadingToken()
        token.cancelLoadingClosure = { [unowned self] in
            self.doneLoading()
        }
        return token
    }

    required init() {
        super.init(nibName: nil, bundle: nil)
        initialSetup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didSetCurrentUser() {
        dataSource.currentUser = currentUser
        collectionViewDataSource.currentUser = currentUser
        super.didSetCurrentUser()
    }

    // If we ever create an init() method that doesn't use nib/storyboards,
    // we'll need to call this.
    fileprivate func initialSetup() {
        setupDataSources()
        setupImageViewDelegate()
        // most consumers of StreamViewController expect all outlets (esp collectionView) to be set
        if !isViewLoaded { _ = view }
    }

    fileprivate func setupCollectionView() {
        let postbarController = PostbarController(streamViewController: self, collectionViewDataSource: collectionViewDataSource)

        // next is a closure due to the need
        // to lazily evaluate it at runtime. `super.next` is not available
        // at assignment but is present when the responder is used later on
        let chainableController = ResponderChainableController(
            controller: self,
            next: { [weak self] in
                return self?.superNext
            }
        )

        postbarController.responderChainable = chainableController
        self.postbarController = postbarController

        collectionView.dataSource = collectionViewDataSource
        collectionView.delegate = self

        automaticallyAdjustsScrollViewInsets = false
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.alwaysBounceHorizontal = false
        collectionView.alwaysBounceVertical = true
        collectionView.isDirectionalLockEnabled = true
        collectionView.keyboardDismissMode = .onDrag
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
        collectionView.backgroundColor = .clear

        StreamCellType.registerAll(collectionView)
        setupCollectionViewLayout()
    }

    // this gets reset whenever the streamKind changes
    fileprivate func setupCollectionViewLayout() {
        guard let layout = collectionView.collectionViewLayout as? StreamCollectionViewLayout else { return }
        let columnCount = Window.columnCountFor(width: view.frame.width)
        layout.columnCount = columnCount
        dataSource.columnCount = columnCount
        layout.sectionInset = UIEdgeInsets.zero
        layout.minimumColumnSpacing = streamKind.columnSpacing
        layout.minimumInteritemSpacing = 0
    }

    fileprivate func setupImageViewDelegate() {
        if imageViewer == nil {
            imageViewer = StreamImageViewer(presentingController: self)
        }
    }

    fileprivate func setupDataSources() {
        dataSource = StreamDataSource(streamKind: streamKind)
        collectionViewDataSource = CollectionViewDataSource(streamKind: streamKind)
    }

    deinit {
        removeNotificationObservers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        pullToRefreshView = SSPullToRefreshView(scrollView: collectionView, delegate: self)
        pullToRefreshView?.contentView = ElloPullToRefreshView(frame: .zero)
        pullToRefreshView?.isHidden = !isPullToRefreshEnabled

        setupCollectionView()
        addNotificationObservers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        for cell in collectionView.visibleCells {
            guard let cell = cell as? DismissableCell else { continue }
            cell.didEndDisplay()
        }
        super.viewWillDisappear(animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        for cell in collectionView.visibleCells {
            guard let cell = cell as? DismissableCell else { continue }
            cell.willDisplay()
        }
    }

    override func loadView() {
        super.loadView()
        view.addSubview(collectionView)
        view.addSubview(noResultsLabel)

        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        noResultsLabel.snp.makeConstraints { make in
            let c = make.top.equalTo(self.view).constraint
            self.noResultsTopConstraint = c.layoutConstraints.first!
            make.leading.trailing.equalTo(self.view).inset(15)
        }
        view.layoutIfNeeded()
    }

    // changing the filter, i.e. when searching for contacts
    func batchUpdateFilter(_ filter: StreamDataSource.StreamFilter?) {
        let delta = dataSource.updateFilter(filter)
        peformDataDelta(delta)
    }

// MARK: Public Functions

    func scrollToTop(animated: Bool) {
        collectionView.setContentOffset(CGPoint(x: 0, y: -contentInset.top), animated: animated)
    }

    func scrollTo(placeholderType: StreamCellType.PlaceholderType, animated: Bool) {
        guard let indexPath = collectionViewDataSource.firstIndexPath(forPlaceholderType: placeholderType) else { return }

        collectionView.scrollToItem(at: indexPath, at: .top, animated: animated)
    }

    func doneLoading() {
        ElloHUD.hideLoadingHudInView(view)
        pullToRefreshView?.finishLoading()
        initialDataLoaded = true
        updateNoResultsLabel()
    }

    func removeAllCellItems() {
        dataSource.removeAllCellItems()
        performDataReload()
    }

    func appendStreamCellItems(_ items: [StreamCellItem]) {
        let indexPaths = dataSource.appendStreamCellItems(items)
        performDataChange { collectionView in
            collectionView.insertItems(at: indexPaths)
        }
    }

    func appendUnsizedCellItems(_ items: [StreamCellItem], completion: Block? = nil) {
        let width = view.frame.width
        dataSource.calculateCellItems(items, withWidth: width) {
            let indexPaths = self.dataSource.appendStreamCellItems(items)
            self.performDataChange { collectionView in
                collectionView.insertItems(at: indexPaths)
            }.always { _ in
                self.doneLoading()
                completion?()
            }
        }
    }

    func insertUnsizedCellItems(_ cellItems: [StreamCellItem], startingIndexPath: IndexPath, completion: @escaping Block = {}) {
        guard cellItems.count > 0 else {
            completion()
            return
        }

        let width = view.frame.width
        dataSource.calculateCellItems(cellItems, withWidth: width) {
            let indexPaths = self.dataSource.insertStreamCellItems(cellItems, startingIndexPath: startingIndexPath)
            self.performDataChange { collectionView in
                collectionView.insertItems(at: indexPaths)
            }.always { _ in
                completion()
            }
        }
    }

    func removeComments(forPost post: Post) {
        let indexPaths = dataSource.removeComments(forPost: post)
        performDataChange { collectionView in
            collectionView.deleteItems(at: indexPaths)
        }
    }

    func hasCellItems(for placeholderType: StreamCellType.PlaceholderType) -> Bool {
        return dataSource.hasCellItems(for: placeholderType)
    }

    func replacePlaceholder(
        type placeholderType: StreamCellType.PlaceholderType,
        items streamCellItems: [StreamCellItem],
        completion: @escaping Block = {}
        )
    {
        let width = view.frame.width
        dataSource.calculateCellItems(streamCellItems, withWidth: width) {
            self.dataSource.replacePlaceholder(type: placeholderType, items: streamCellItems)
            self.performDataReload()
                .always { _ in
                    completion()
                }
        }
    }

    func appendPlaceholder(
        _ placeholderType: StreamCellType.PlaceholderType,
        with streamCellItems: [StreamCellItem],
        completion: @escaping Block = {}
        )
    {
        guard
            streamCellItems.count > 0,
            let lastIndexPath = dataSource.indexPaths(forPlaceholderType: placeholderType).last
        else { return }

        for item in streamCellItems {
            item.placeholderType = placeholderType
        }

        let nextIndexPath = IndexPath(item: lastIndexPath.item + 1, section: lastIndexPath.section)
        insertUnsizedCellItems(streamCellItems, startingIndexPath: nextIndexPath, completion: completion)
    }

    func loadInitialPage(reload: Bool = false) {
        if let reloadClosure = reloadClosure, reload {
            responseConfig = nil
            isPagingEnabled = false
            reloadClosure()
        }
        else if let initialLoadClosure = initialLoadClosure {
            initialLoadClosure()
        }
        else {
            let localToken = loadingToken.resetInitialPageLoadingToken()

            StreamService().loadStream(streamKind: streamKind)
                .thenFinally { response in
                    guard self.loadingToken.isValidInitialPageLoadingToken(localToken) else { return }

                    switch response {
                    case let .jsonables(jsonables, responseConfig):
                        self.responseConfig = responseConfig
                        self.showInitialJSONAbles(jsonables)
                    case .empty:
                        self.showInitialJSONAbles([])
                    }
                }
                .catch { error in
                    self.initialLoadFailure()
                }
        }
    }

    /// This method can be called by a `StreamableViewController` if it wants to
    /// override `loadInitialPage`, but doesn't need to customize the cell generation.
    func showInitialJSONAbles(_ jsonables: [JSONAble]) {
        clearForInitialLoad()
        currentJSONables = jsonables

        var items = generateStreamCellItems(jsonables)
        if jsonables.count == 0 {
            items.append(StreamCellItem(type: .emptyStream(height: 282)))
        }
        appendUnsizedCellItems(items) {
            self.isPagingEnabled = true
        }
    }

    fileprivate func generateStreamCellItems(_ jsonables: [JSONAble]) -> [StreamCellItem] {
        let defaultGenerator: StreamCellItemGenerator = {
            return StreamCellItemParser().parse(jsonables, streamKind: self.streamKind, currentUser: self.currentUser)
        }

        if let items = streamViewDelegate?.streamViewStreamCellItems(jsonables: jsonables, defaultGenerator: defaultGenerator) {
            return items
        }

        return defaultGenerator()
    }

    fileprivate func updateNoResultsLabel() {
        let shouldShowNoResults = dataSource.visibleCellItems.count == 0
        if shouldShowNoResults {
            delay(0.666) {
                self.showNoResults()
            }
        }
        else {
            self.hideNoResults()
        }
    }

    func hideNoResults() {
        noResultsLabel.isHidden = true
        noResultsLabel.alpha = 0
    }

    func showNoResults() {
        noResultsLabel.isHidden = false
        UIView.animate(withDuration: 0.25, animations: {
            self.noResultsLabel.alpha = 1
        })
    }

    func clearForInitialLoad(newItems: [StreamCellItem] = []) {
        allOlderPagesLoaded = false
        dataSource.removeAllCellItems()
        if newItems.count > 0 {
            dataSource.appendStreamCellItems(newItems)
        }
        performDataReload()
    }

// MARK: Private Functions

    fileprivate func initialLoadFailure() {
        guard streamViewDelegate?.streamViewCustomLoadFailed() == false else {
            return
        }
        self.doneLoading()

        var isVisible = false
        var view: UIView? = self.view
        while view != nil {
            if view is UIWindow {
                isVisible = true
                break
            }

            view = view!.superview
        }

        if isVisible {
            let message = InterfaceString.GenericError
            let alertController = AlertViewController(error: message) { _ in
                guard
                    let navigationController = self.navigationController,
                    navigationController.childViewControllers.count > 1
                else { return }

                _ = navigationController.popViewController(animated: true)
            }
            present(alertController, animated: true)
        }
        else if let navigationController = navigationController, navigationController.childViewControllers.count > 1 {
            _ = navigationController.popViewController(animated: false)
        }
    }

    fileprivate func addNotificationObservers() {
        updateCellHeightNotification = NotificationObserver(notification: StreamNotification.UpdateCellHeightNotification) { [weak self] streamCellItem in
            guard let `self` = self, self.dataSource.visibleCellItems.contains(streamCellItem) else { return }
            nextTick {
                self.collectionView.collectionViewLayout.invalidateLayout()
            }
        }
        rotationNotification = NotificationObserver(notification: Application.Notifications.DidChangeStatusBarOrientation) { [weak self] _ in
            guard let `self` = self else { return }
            self.reloadCells()
        }
        sizeChangedNotification = NotificationObserver(notification: Application.Notifications.ViewSizeWillChange) { [weak self] size in
            guard let `self` = self else { return }

            let columnCount = Window.columnCountFor(width: size.width)
            if let layout = self.collectionView.collectionViewLayout as? StreamCollectionViewLayout {
                layout.columnCount = columnCount
            }
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.dataSource.columnCount = columnCount
            self.reloadCells()
        }

        commentChangedNotification = NotificationObserver(notification: CommentChangedNotification) { [weak self] (comment, change) in
            guard
                let `self` = self, self.initialDataLoaded && self.isViewLoaded
            else { return }

            switch change {
            case .create, .delete, .update, .replaced:
                self.dataSource.modifyItems(comment, change: change, streamViewController: self)
            default: break
            }
            self.updateNoResultsLabel()
        }

        postChangedNotification = NotificationObserver(notification: PostChangedNotification) { [weak self] (post, change) in
            guard
                let `self` = self, self.initialDataLoaded && self.isViewLoaded
            else { return }

            switch change {
            case .delete:
                switch self.streamKind {
                case .postDetail: break
                default:
                    self.dataSource.modifyItems(post, change: change, streamViewController: self)
                }
                // reload page
            case .create,
                .update,
                .replaced,
                .loved,
                .reposted,
                .watching:
                self.dataSource.modifyItems(post, change: change, streamViewController: self)
            case .read: break
            }
            self.updateNoResultsLabel()
        }

        jsonableChangedNotification = NotificationObserver(notification: JSONAbleChangedNotification) { [weak self] (jsonable, change) in
            guard
                let `self` = self, self.initialDataLoaded && self.isViewLoaded
            else { return }

            self.dataSource.modifyItems(jsonable, change: change, streamViewController: self)
            self.updateNoResultsLabel()
        }

        relationshipChangedNotification = NotificationObserver(notification: RelationshipChangedNotification) { [weak self] user in
            guard
                let `self` = self, self.initialDataLoaded && self.isViewLoaded
            else { return }

            self.dataSource.modifyUserRelationshipItems(user, streamViewController: self)
            self.updateNoResultsLabel()
        }

        settingChangedNotification = NotificationObserver(notification: SettingChangedNotification) { [weak self] user in
            guard
                let `self` = self, self.initialDataLoaded && self.isViewLoaded
            else { return }

            self.dataSource.modifyUserSettingsItems(user, streamViewController: self)
            self.updateNoResultsLabel()
        }

        currentUserChangedNotification = NotificationObserver(notification: CurrentUserChangedNotification) { [weak self] user in
            guard
                let `self` = self, self.initialDataLoaded && self.isViewLoaded
            else { return }

            self.dataSource.modifyItems(user, change: .update, streamViewController: self)
            self.updateNoResultsLabel()
        }
    }

    func reloadCells() {
        performDataReload()
    }

    fileprivate func removeNotificationObservers() {
        updateCellHeightNotification?.removeObserver()
        rotationNotification?.removeObserver()
        sizeChangedNotification?.removeObserver()
        commentChangedNotification?.removeObserver()
        postChangedNotification?.removeObserver()
        relationshipChangedNotification?.removeObserver()
        jsonableChangedNotification?.removeObserver()
        settingChangedNotification?.removeObserver()
        currentUserChangedNotification?.removeObserver()
    }

    fileprivate func updateCellHeight(_ indexPath: IndexPath, height: CGFloat) {
        let existingHeight = collectionViewDataSource.height(at: indexPath, numberOfColumns: columnCount)
        if height != existingHeight {
            performDataUpdate { collectionView in
                self.dataSource.updateHeight(at: indexPath, height: height)
                collectionView.reloadItems(at: [indexPath])
            }
        }
    }

}

// MARK: DELEGATE & RESPONDER EXTENSIONS


// MARK: StreamViewController: GridListToggleDelegate
extension StreamViewController: GridListToggleDelegate {
    func gridListToggled(_ sender: UIButton) {
        let isGridView = !streamKind.isGridView
        sender.setImage(isGridView ? .listView : .gridView, imageStyle: .normal, for: .normal)
        streamKind.setIsGridView(isGridView)
        if let toggleClosure = toggleClosure {
            // setting 'scrollToPaginateGuard' to false will prevent pagination from triggering when this profile has no posts
            // triggering pagination at this time will, inexplicably, cause the cells to disappear
            scrollToPaginateGuard = false
            setupCollectionViewLayout()

            toggleClosure(isGridView)
        }
        else {
            UIView.animate(withDuration: 0.2, animations: {
                self.collectionView.alpha = 0
            }, completion: { _ in
                self.toggleGrid(isGridView: isGridView)
            })
        }
    }

    fileprivate func toggleGrid(isGridView: Bool) {
        var emptyStreamCellItem: StreamCellItem?
        if let first = dataSource.visibleCellItems.first {
            switch first.type {
            case .emptyStream: emptyStreamCellItem = first
            default: break
            }
        }

        removeAllCellItems()
        var items = generateStreamCellItems(currentJSONables)

        if let item = emptyStreamCellItem, items.count == 0 {
            items = [item]
        }

        appendUnsizedCellItems(items) {
            animate {
                if let streamableViewController = self.parent as? StreamableViewController {
                    streamableViewController.trackScreenAppeared()
                }
                self.collectionView.alpha = 1
            }
        }
        setupCollectionViewLayout()
    }
}

// MARK: StreamViewController: CategoryListCellResponder
extension StreamViewController: CategoryListCellResponder {

    func categoryListCellTapped(slug: String, name: String) {
        showCategoryViewController(slug: slug, name: name)
    }

}

// MARK: StreamViewController: SimpleStreamResponder
extension StreamViewController: SimpleStreamResponder {

    func showSimpleStream(boxedEndpoint: BoxedElloAPI, title: String, noResultsMessages: NoResultsMessages? = nil) {
        let vc = SimpleStreamViewController(endpoint: boxedEndpoint.endpoint, title: title)
        vc.currentUser = currentUser
        if let messages = noResultsMessages {
            vc.streamViewController.noResultsMessages = messages
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: StreamViewController: SSPullToRefreshViewDelegate
extension StreamViewController: SSPullToRefreshViewDelegate {

    func pull(toRefreshViewShouldStartLoading view: SSPullToRefreshView!) -> Bool {
        return isPullToRefreshEnabled
    }

    func pull(_ view: SSPullToRefreshView, didTransitionTo toState: SSPullToRefreshViewState, from fromState: SSPullToRefreshViewState, animated: Bool) {
        if toState == .loading {
            if isPullToRefreshEnabled {
                streamViewDelegate?.streamWillPullToRefresh()

                if let controller = parent as? BaseElloViewController {
                    controller.trackScreenAppeared()
                }
                self.loadInitialPage(reload: true)
            }
            else {
                pullToRefreshView?.finishLoading()
            }
        }
    }

}

// MARK: StreamViewController: StreamCollectionViewLayoutDelegate
extension StreamViewController: StreamCollectionViewLayoutDelegate {

    func collectionView(_ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize
    {
        let width = calculateColumnWidth(frameWidth: UIWindow.windowWidth(), columnCount: columnCount)
        let height = self.collectionViewDataSource.height(at: indexPath, numberOfColumns: 1)
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        groupForItemAtIndexPath indexPath: IndexPath) -> String? {
            return collectionViewDataSource.group(at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        heightForItemAtIndexPath indexPath: IndexPath,
        numberOfColumns: NSInteger) -> CGFloat
    {
        return collectionViewDataSource.height(at: indexPath, numberOfColumns: numberOfColumns)
    }

    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        isFullWidthAtIndexPath indexPath: IndexPath) -> Bool
    {
        return collectionViewDataSource.isFullWidth(at: indexPath)
    }
}

// MARK: StreamViewController: StreamEditingResponder
extension StreamViewController: StreamEditingResponder {

    func cellDoubleTapped(cell: UICollectionViewCell, location: CGPoint) {
        guard
            let path = collectionView.indexPath(for: cell),
            let post = collectionViewDataSource.post(at: path)
        else { return }

        cellDoubleTapped(cell: cell, post: post, location: location)
    }

    func cellDoubleTapped(cell: UICollectionViewCell, post: Post, location: CGPoint) {
        guard currentUser != nil else {
            postNotification(LoggedOutNotifications.userActionAttempted, value: .postTool)
            return
        }

        guard post.author?.hasLovesEnabled == true else { return }

        if let window = cell.window {
            let fullDuration: TimeInterval = 0.4
            let halfDuration: TimeInterval = fullDuration / 2

            let imageView = UIImageView(image: InterfaceImage.giantHeart.normalImage)
            imageView.contentMode = .scaleAspectFit
            imageView.frame = window.bounds
            imageView.center = location
            imageView.alpha = 0
            imageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            let grow: () -> Void = { imageView.transform = CGAffineTransform(scaleX: 1, y: 1) }
            let remove: (Bool) -> Void = { _ in imageView.removeFromSuperview() }
            let fadeIn: () -> Void = { imageView.alpha = 0.5 }
            let fadeOut: (Bool) -> Void = { _ in animate(duration: halfDuration, completion: remove) { imageView.alpha = 0 } }
            animate(duration: halfDuration, completion: fadeOut, animations: fadeIn)
            animate(duration: fullDuration, completion: remove, animations: grow)
            window.addSubview(imageView)
        }

        if !post.isLoved {
            let loveableCell = self.loveableCell(for: cell)
            postbarController?.toggleLove(loveableCell, post: post, via: "double tap")
        }
    }

    func cellLongPressed(cell: UICollectionViewCell) {
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let currentUser = currentUser
        else { return }

        if let post = collectionViewDataSource.post(at: indexPath),
            currentUser.isOwnerOf(post: post)
        {
            let responder: CreatePostResponder? = findResponder()
            responder?.editPost(post, fromController: self)
        }
        else if let comment = collectionViewDataSource.comment(at: indexPath),
            currentUser.isOwnerOf(comment: comment)
        {
            let responder: CreatePostResponder? = findResponder()
            responder?.editComment(comment, fromController: self)
        }
    }
}

// MARK: StreamViewController: StreamImageCellResponder
extension StreamViewController: StreamImageCellResponder {
    func imageTapped(imageView: FLAnimatedImageView, cell: StreamImageCell) {
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let streamCellItem = collectionViewDataSource.streamCellItem(at: indexPath)
        else { return }

        let post = collectionViewDataSource.post(at: indexPath)
        let imageAsset = collectionViewDataSource.imageAsset(at: indexPath)

        let isGridView = streamCellItem.isGridView(streamKind: streamKind)
        if isGridView || cell.isGif {
            if let post = post {
                sendToPostTappedResponder(post: post, streamCellItem: streamCellItem)
            }
        }
        else if let imageViewer = imageViewer {
            imageViewer.imageTapped(imageView, imageURL: cell.presentedImageUrl)
            if let post = post, let asset = imageAsset {
                Tracker.shared.viewedImage(asset, post: post)
            }
        }
    }
}

// MARK: StreamViewController: Open post
extension StreamViewController: StreamPostTappedResponder {

    @objc
    func postTappedInStream(_ cell: UICollectionViewCell) {
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let post = collectionViewDataSource.post(at: indexPath),
            let streamCellItem = collectionViewDataSource.streamCellItem(at: indexPath)
        else { return }

        sendToPostTappedResponder(post: post, streamCellItem: streamCellItem)
    }

    func sendToPostTappedResponder(post: Post, streamCellItem: StreamCellItem, scrollToComment: ElloComment? = nil) {
        if let placeholderType = streamCellItem.placeholderType,
            case .postRelatedPosts = placeholderType
        {
            Tracker.shared.relatedPostTapped(post)
        }

        let responder: PostTappedResponder? = findResponder()
        if let scrollToComment = scrollToComment {
            responder?.postTapped(post, scrollToComment: scrollToComment)
        }
        else {
            responder?.postTapped(post)
        }
    }

}

// MARK: StreamViewController: Open category
extension StreamViewController {

    func showCategoryViewController(slug: String, name: String) {
        if let vc = parent as? CategoryViewController {
            vc.selectCategoryFor(slug: slug)
        }
        else {
            Tracker.shared.categoryOpened(slug)
            let vc = CategoryViewController(slug: slug, name: name)
            vc.currentUser = currentUser
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: StreamViewController: CategoryResponder
extension StreamViewController: CategoryResponder {

    func categoryTapped(_ category: Category) {
        showCategoryViewController(slug: category.slug, name: category.name)
    }

    func categoryCellTapped(cell: UICollectionViewCell) {
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let post = collectionViewDataSource.jsonable(at: indexPath) as? Post,
            let category = post.category
        else { return }

        categoryTapped(category)
    }
}

// MARK: StreamViewController: StreamCellResponder
extension StreamViewController: StreamCellResponder {

    func streamCellTapped(cell: UICollectionViewCell) {
        guard
            let indexPath = collectionView.indexPath(for: cell),
            collectionViewDataSource.isTappable(at: indexPath)
        else { return }

        collectionView(collectionView, didSelectItemAt: indexPath)
    }

}

// MARK: StreamViewController: UserResponder
extension StreamViewController: UserResponder {

    func userTapped(user: User) {
        let responder: UserTappedResponder? = findResponder()
        responder?.userTapped(user)
    }

    func userTappedAuthor(cell: UICollectionViewCell) {
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let user = collectionViewDataSource.user(at: indexPath)
        else { return }

        userTapped(user: user)
    }

    func userTappedReposter(cell: UICollectionViewCell) {
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let reposter = collectionViewDataSource.reposter(at: indexPath)
        else { return }

        userTapped(user: reposter)
    }
}

// MARK: StreamViewController: ArtistInviteResponder
extension StreamViewController {

    func artistInviteTapped(_ artistInvite: ArtistInvite) {
        Tracker.shared.artistInviteOpened(slug: artistInvite.slug)

        let vc = ArtistInviteDetailController(artistInvite: artistInvite)
        vc.currentUser = currentUser
        navigationController?.pushViewController(vc, animated: true)
    }

    func artistInviteTapped(slug: String) {
        Tracker.shared.artistInviteOpened(slug: slug)

        let vc = ArtistInviteDetailController(slug: slug)
        vc.currentUser = currentUser
        navigationController?.pushViewController(vc, animated: true)
    }

}


// MARK: StreamViewController: WebLinkResponder
extension StreamViewController: WebLinkResponder {

    func webLinkTapped(path: String, type: ElloURIWrapper, data: String) {
        guard
            let parentController = parent as? HasAppController,
            let appViewController = parentController.appViewController
        else { return }

        appViewController.navigateToURI(path: path, type: type.uri, data: data)
    }

    fileprivate func selectTab(_ tab: ElloTab) {
        elloTabBarController?.selectedTab = tab
    }
}

// MARK: StreamViewController: AnnouncementCellResponder
extension StreamViewController: AnnouncementCellResponder {

    func markAnnouncementAsRead(cell: UICollectionViewCell) {
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let announcement = jsonable(forPath: indexPath) as? Announcement
        else { return }

        let responder: AnnouncementResponder? = findResponder()
        responder?.markAnnouncementAsRead(announcement: announcement)
    }
}

// MARK: StreamViewController: UICollectionViewDelegate
extension StreamViewController: UICollectionViewDelegate {

    func jsonable(forPath indexPath: IndexPath) -> JSONAble? {
        guard let item = collectionViewDataSource.streamCellItem(at: indexPath) else { return nil }
        return item.jsonable
    }

    func jsonable(forCell cell: UICollectionViewCell) -> JSONAble? {
        guard let indexPath = collectionView.indexPath(for: cell) else { return nil}
        return jsonable(forPath: indexPath)
    }

    func loveableCell(for cell: UICollectionViewCell) -> LoveableCell? {
        if let cell = cell as? LoveableCell {
            return cell
        }

        if let path = collectionView.indexPath(for: cell),
            let post = jsonable(forPath: path) as? Post,
            let footerPath = collectionViewDataSource.footerIndexPath(forPost: post)
        {
            return collectionView.cellForItem(at: footerPath) as? LoveableCell
        }

        return nil
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? DismissableCell else { return }
        cell.didEndDisplay()
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? DismissableCell else { return }
        cell.willDisplay()
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard
            let tappedCell = collectionView.cellForItem(at: indexPath),
            let item = collectionViewDataSource.streamCellItem(at: indexPath),
            let paths = collectionView.indexPathsForSelectedItems,
            tappedCell is CategoryCardCell && item.type == .selectableCategoryCard
        else { return }

        let selection = paths.flatMap { collectionViewDataSource.jsonable(at: $0) as? Category }

        let responder: SelectedCategoryResponder? = findResponder()
        responder?.categoriesSelectionChanged(selection: selection)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tappedCell = collectionView.cellForItem(at: indexPath)

        var keepSelected = false
        if tappedCell is StreamToggleCell {
            performDataUpdate { collectionView in
                self.dataSource.toggleCollapsed(at: indexPath)
                collectionView.reloadItems(at: [indexPath])
            }
        }
        else if tappedCell is UserListItemCell {
            if let user = collectionViewDataSource.user(at: indexPath) {
                userTapped(user: user)
            }
        }
        else if tappedCell is BadgeCell,
            let badge = dataSource.jsonable(at: indexPath) as? Badge,
            let url = badge.url
        {
            Tracker.shared.badgeScreenLink(badge.slug)
            postNotification(ExternalWebNotification, value: url.absoluteString)
        }
        else if tappedCell is StreamSeeMoreCommentsCell {
            if let lastComment = dataSource.comment(at: indexPath),
                let post = lastComment.loadedFromPost,
                let streamCellItem = dataSource.streamCellItem(at: indexPath)
            {
                sendToPostTappedResponder(post: post, streamCellItem: streamCellItem, scrollToComment: lastComment)
            }
        }
        else if tappedCell is StreamLoadMoreCommentsCell {
            let responder: PostCommentsResponder? = findResponder()
            responder?.loadCommentsTapped()
        }
        else if let post = dataSource.post(at: indexPath),
                let streamCellItem = dataSource.streamCellItem(at: indexPath) {
            sendToPostTappedResponder(post: post, streamCellItem: streamCellItem)
        }
        else if let notification = dataSource.jsonable(at: indexPath) as? Notification,
            let postId = notification.postId
        {
            let responder: PostTappedResponder? = findResponder()
            responder?.postTapped(postId: postId)
        }
        else if let notification = dataSource.jsonable(at: indexPath) as? Notification,
            let user = notification.subject as? User
        {
            userTapped(user: user)
        }
        else if let notification = dataSource.jsonable(at: indexPath) as? Notification,
            let artistInviteSubmission = notification.subject as? ArtistInviteSubmission,
            let artistInvite = artistInviteSubmission.artistInvite
        {
            artistInviteTapped(slug: artistInvite.slug)
        }
        else if let announcement = dataSource.jsonable(at: indexPath) as? Announcement,
            let callToAction = announcement.ctaURL
        {
            Tracker.shared.announcementOpened(announcement)
            let request = URLRequest(url: callToAction)
            ElloWebViewHelper.handle(request: request, origin: self)
        }
        else if let artistInvite = dataSource.jsonable(at: indexPath) as? ArtistInvite {
            artistInviteTapped(artistInvite)
        }
        else if let comment = dataSource.comment(at: indexPath) {
            let responder: CreatePostResponder? = findResponder()
            responder?.createComment(comment.loadedFromPostId, text: nil, fromController: self)
        }
        else if tappedCell is RevealControllerCell,
            let streamCellItem = dataSource.streamCellItem(at: indexPath),
            let info = streamCellItem.type.data
        {
            let responder: RevealControllerResponder? = findResponder()
            responder?.revealControllerTapped(info: info)
        }
        else if let item = dataSource.streamCellItem(at: indexPath),
            let category = dataSource.jsonable(at: indexPath) as? Category
        {
            if item.type == .selectableCategoryCard {
                keepSelected = true
                let paths = collectionView.indexPathsForSelectedItems
                let selection = paths?.flatMap { dataSource.jsonable(at: $0) as? Category }

                let responder: SelectedCategoryResponder? = findResponder()
                responder?.categoriesSelectionChanged(selection: selection ?? [Category]())
            }
            else {
                showCategoryViewController(slug: category.slug, name: category.name)
            }
        }

        if !keepSelected {
            collectionView.deselectItem(at: indexPath, animated: false)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath) -> Bool {
            guard
                let cellItemType = dataSource.streamCellItem(at: indexPath)?.type
            else { return false }

            return cellItemType.isSelectable
    }
}

// MARK: StreamViewController: UIScrollViewDelegate
extension StreamViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        streamViewDelegate?.streamViewDidScroll(scrollView: scrollView)
        if !noResultsLabel.isHidden {
            noResultsTopConstraint.constant = -scrollView.contentOffset.y + defaultNoResultsTopConstant
            self.view.layoutIfNeeded()
        }

        if scrollToPaginateGuard {
            self.loadNextPage(scrollView: scrollView)
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollToPaginateGuard = true
        streamViewDelegate?.streamViewWillBeginDragging(scrollView: scrollView)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate: Bool) {
        streamViewDelegate?.streamViewDidEndDragging(scrollView: scrollView, willDecelerate: willDecelerate)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollToPaginateGuard = false
    }

    fileprivate func loadNextPage(scrollView: UIScrollView) {
        guard
            isPagingEnabled &&
            scrollView.contentOffset.y + (self.view.frame.height * 1.666)
            > scrollView.contentSize.height
        else { return }

        guard
            !allOlderPagesLoaded &&
            responseConfig?.totalPagesRemaining != "0"
        else { return }

        guard
            let nextQuery = responseConfig?.nextQuery
        else { return }

        guard
            let lastCellItem = dataSource.visibleCellItems.last,
            lastCellItem.type != .streamLoading
        else { return }

        let placeholderType = lastCellItem.placeholderType
        appendStreamCellItems([StreamCellItem(type: .streamLoading)])

        scrollToPaginateGuard = false

        let scrollAPI = ElloAPI.infiniteScroll(query: nextQuery, api: streamKind.endpoint)
        StreamService().loadStream(endpoint: scrollAPI, streamKind: streamKind)
            .thenFinally { response in
                switch response {
                case let .jsonables(jsonables, responseConfig):
                    self.allOlderPagesLoaded = jsonables.count == 0
                    self.scrollLoaded(jsonables: jsonables, placeholderType: placeholderType)
                    self.responseConfig = responseConfig
                case .empty:
                    self.allOlderPagesLoaded = true
                    self.scrollLoaded()
                }
            }
            .catch { error in
                self.scrollLoaded()
            }
    }

    fileprivate func scrollLoaded(jsonables: [JSONAble] = [], placeholderType: StreamCellType.PlaceholderType? = nil) {
        guard
            let lastIndexPath = collectionView.lastIndexPathForSection(0)
        else { return }

        if jsonables.count > 0 {
            if let controller = parent as? BaseElloViewController {
                controller.trackScreenAppeared()
            }

            let items = StreamCellItemParser().parse(jsonables, streamKind: streamKind, currentUser: currentUser)
            for item in items {
                item.placeholderType = placeholderType
            }
            insertUnsizedCellItems(items, startingIndexPath: lastIndexPath) {
                self.removeLoadingCell()
                self.doneLoading()
            }
        }
        else {
            removeLoadingCell()
            self.doneLoading()
        }
    }

    fileprivate func removeLoadingCell() {
        let lastIndexPath = IndexPath(item: dataSource.visibleCellItems.count - 1, section: 0)
        guard
            dataSource.visibleCellItems[lastIndexPath.row].type == .streamLoading
        else { return }

        dataSource.removeItems(at: [lastIndexPath])
        performDataChange { collectionView in
            collectionView.deleteItems(at: [lastIndexPath])
        }
    }
}

extension StreamViewController {
    typealias CollectionViewChange = (UICollectionView) -> Void

    @discardableResult
    func peformDataDelta(_ delta: Delta) -> Promise<Void> {
        return appendDataChange(.delta(delta))
    }

    @discardableResult
    func performDataUpdate(_ block: @escaping CollectionViewChange) -> Promise<Void> {
        return appendDataChange(.update(block))
    }

    @discardableResult
    func performDataReload() -> Promise<Void> {
        return appendDataChange(.reload)
    }

    @discardableResult
    func performDataChange(_ block: @escaping CollectionViewChange) -> Promise<Void> {
        return appendDataChange(.batch(block))
    }

    private func appendDataChange(_ change: StreamViewDataChange) -> Promise<Void> {
        let (promise, resolve, _) = Promise<Void>.pending()
        dataChangeJobs.append((dataSource.visibleCellItems, change, promise, resolve))
        runNextDataChangeJob()
        return promise
    }

    func runNextDataChangeJob() {
        guard dataChangeJobs.count > 0 else {
            isRunningDataChangeJobs = false
            return
        }

        guard !isRunningDataChangeJobs else { return }
        isRunningDataChangeJobs = true

        let job = dataChangeJobs.removeFirst()
        job.promise.always { _ in
            self.isRunningDataChangeJobs = false
            self.runNextDataChangeJob()
        }

        switch job.change {
        case .reload:
            collectionViewDataSource.visibleCellItems = job.newItems

            collectionView.reloadData()
            collectionView.layoutIfNeeded()

            job.resolve(())
        case let .delta(delta):
            collectionView.performBatchUpdates({
                self.collectionViewDataSource.visibleCellItems = job.newItems
                delta.applyUpdatesToCollectionView(self.collectionView, inSection: 0)
            }, completion: { _ in
                job.resolve(())
            })
        case let .update(block):
            block(collectionView)
            job.resolve(())
        case let .batch(block):
            collectionView.performBatchUpdates({
                self.collectionViewDataSource.visibleCellItems = job.newItems
                block(self.collectionView)
            }, completion: { _ in
                job.resolve(())
            })
        }
    }
}
