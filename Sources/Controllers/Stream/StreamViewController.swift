////
///  StreamViewController.swift
//

import SSPullToRefresh
import FLAnimatedImage
import Crashlytics
import SwiftyUserDefaults
import DeltaCalculator


// MARK: Delegate Implementations
protocol InviteDelegate: class {
    func sendInvite(person: LocalPerson, isOnboarding: Bool, didUpdate: @escaping ElloEmptyCompletion)
}

protocol SimpleStreamDelegate: class {
    func showSimpleStream(endpoint: ElloAPI, title: String, noResultsMessages: (title: String, body: String)?)
}

protocol StreamImageCellDelegate: class {
    func imageTapped(imageView: FLAnimatedImageView, cell: StreamImageCell)
}

protocol StreamEditingDelegate: class {
    func cellDoubleTapped(cell: UICollectionViewCell, location: CGPoint)
    func cellLongPressed(cell: UICollectionViewCell)
}

typealias StreamCellItemGenerator = () -> [StreamCellItem]
protocol StreamViewDelegate: class {
    func streamViewCustomLoadFailed() -> Bool
    func streamViewStreamCellItems(jsonables: [JSONAble], defaultGenerator: StreamCellItemGenerator) -> [StreamCellItem]?
    func streamViewDidScroll(scrollView: UIScrollView)
    func streamViewWillBeginDragging(scrollView: UIScrollView)
    func streamViewDidEndDragging(scrollView: UIScrollView, willDecelerate: Bool)
}

protocol CategoryDelegate: class {
    func categoryCellTapped(cell: UICollectionViewCell)
}

protocol SelectedCategoryDelegate: class {
    func categoriesSelectionChanged(selection: [Category])
}

protocol UserDelegate: class {
    func userTappedAuthor(cell: UICollectionViewCell)
    func userTappedReposter(cell: UICollectionViewCell)
    func userTappedText(cell: UICollectionViewCell)
    func userTappedFeaturedCategories(cell: UICollectionViewCell)
    func userTapped(user: User)
}

protocol WebLinkDelegate: class {
    func webLinkTapped(type: ElloURI, data: String)
}

@objc
protocol GridListToggleDelegate: class {
    func gridListToggled(_ sender: UIButton)
}

protocol CategoryListCellDelegate: class {
    func categoryListCellTapped(slug: String, name: String)
}

protocol SearchStreamDelegate: class {
    func searchFieldChanged(text: String)
}

protocol AnnouncementCellDelegate: class {
    func markAnnouncementAsRead(cell: UICollectionViewCell)
}

protocol AnnouncementDelegate: class {
    func markAnnouncementAsRead(announcement: Announcement)
}

// MARK: StreamNotification
struct StreamNotification {
    static let AnimateCellHeightNotification = TypedNotification<StreamImageCell>(name: "AnimateCellHeightNotification")
    static let UpdateCellHeightNotification = TypedNotification<UICollectionViewCell>(name: "UpdateCellHeightNotification")
}

// MARK: StreamViewController
final class StreamViewController: BaseElloViewController {
    override func trackerName() -> String? { return nil }

    @IBOutlet weak var collectionView: ElloCollectionView!
    @IBOutlet weak var noResultsLabel: UILabel!
    @IBOutlet weak var noResultsTopConstraint: NSLayoutConstraint!
    fileprivate let defaultNoResultsTopConstant: CGFloat = 113

    var currentJSONables = [JSONAble]()

    var noResultsMessages = (title: "", body: "") {
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
    var postbarController: PostbarController?
    var relationshipController: RelationshipController?
    var responseConfig: ResponseConfig?
    var pagingEnabled = false
    fileprivate var scrollToPaginateGuard = false

    let streamService = StreamService()
    lazy var loadingToken: LoadingToken = self.createLoadingToken()

    // moved into a separate function to save compile time
    fileprivate func createLoadingToken() -> LoadingToken {
        var token = LoadingToken()
        token.cancelLoadingClosure = { [unowned self] in
            self.doneLoading()
        }
        return token
    }

    var pullToRefreshView: SSPullToRefreshView?
    var allOlderPagesLoaded = false
    var initialLoadClosure: ElloEmptyCompletion?
    var reloadClosure: ElloEmptyCompletion?
    var toggleClosure: ToggleClosure?
    var initialDataLoaded = false
    var parentTabBarController: ElloTabBarController? {
        if let parentViewController = self.parent,
            let elloController = parentViewController as? BaseElloViewController
        {
            return elloController.elloTabBarController
        }
        return nil
    }

    var streamKind: StreamKind = StreamKind.unknown {
        didSet {
            dataSource.streamKind = streamKind
            setupCollectionViewLayout()
        }
    }
    var imageViewer: StreamImageViewer?
    var updatedStreamImageCellHeightNotification: NotificationObserver?
    var updateCellHeightNotification: NotificationObserver?
    var rotationNotification: NotificationObserver?
    var sizeChangedNotification: NotificationObserver?
    var commentChangedNotification: NotificationObserver?
    var postChangedNotification: NotificationObserver?
    var jsonableChangedNotification: NotificationObserver?
    var relationshipChangedNotification: NotificationObserver?
    var settingChangedNotification: NotificationObserver?
    var currentUserChangedNotification: NotificationObserver?

    weak var createPostDelegate: CreatePostDelegate?
    weak var postTappedDelegate: PostTappedDelegate?
    weak var userTappedDelegate: UserTappedDelegate?
    weak var streamViewDelegate: StreamViewDelegate?
    weak var selectedCategoryDelegate: SelectedCategoryDelegate?
    weak var announcementDelegate: AnnouncementDelegate?
    var searchStreamDelegate: SearchStreamDelegate? {
        get { return dataSource.searchStreamDelegate }
        set { dataSource.searchStreamDelegate = newValue }
    }
    var notificationDelegate: NotificationDelegate? {
        get { return dataSource.notificationDelegate }
        set { dataSource.notificationDelegate = newValue }
    }

    var streamFilter: StreamDataSource.StreamFilter {
        get { return dataSource.streamFilter }
        set {
            dataSource.streamFilter = newValue
            self.reloadCells(now: true)
            self.scrollToTop()
        }
    }

    func batchUpdateFilter(_ filter: StreamDataSource.StreamFilter) {
        let delta = dataSource.updateFilter(filter)
        let collectionView = self.collectionView
        collectionView?.performBatchUpdates({
            delta.applyUpdatesToCollectionView(collectionView!, inSection: 0)
        }, completion: nil)
    }

    var contentInset: UIEdgeInsets {
        get { return collectionView.contentInset }
        set {
            collectionView.contentInset = newValue
            collectionView.scrollIndicatorInsets = newValue
            pullToRefreshView?.defaultContentInset = newValue
        }
    }
    var columnCount: Int {
        guard let layout = self.collectionView.collectionViewLayout as? StreamCollectionViewLayout else {
            return 1
        }
        return layout.columnCount
    }

    var pullToRefreshEnabled: Bool = true {
        didSet { pullToRefreshView?.isHidden = !pullToRefreshEnabled }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
    }

    override func didSetCurrentUser() {
        dataSource.currentUser = currentUser
        relationshipController?.currentUser = currentUser
        postbarController?.currentUser = currentUser
        super.didSetCurrentUser()
    }

    // If we ever create an init() method that doesn't use nib/storyboards,
    // we'll need to call this.
    fileprivate func initialSetup() {
        setupDataSource()
        setupImageViewDelegate()
        // most consumers of StreamViewController expect all outlets (esp collectionView) to be set
        if !isViewLoaded { let _ = view }
    }

    deinit {
        removeNotificationObservers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        pullToRefreshView = SSPullToRefreshView(scrollView: collectionView, delegate: self)
        pullToRefreshView?.contentView = ElloPullToRefreshView(frame: .zero)
        pullToRefreshView?.isHidden = !pullToRefreshEnabled

        setupCollectionView()
        addNotificationObservers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Crashlytics.sharedInstance().setObjectValue(streamKind.name, forKey: CrashlyticsKey.streamName.rawValue)
    }

    class func instantiateFromStoryboard() -> StreamViewController {
        return UIStoryboard.storyboardWithId(.stream) as! StreamViewController
    }

// MARK: Public Functions

    func scrollToTop() {
        collectionView.contentOffset = CGPoint(x: 0, y: contentInset.top)
    }

    func doneLoading() {
        ElloHUD.hideLoadingHudInView(view)
        pullToRefreshView?.finishLoading()
        initialDataLoaded = true
        updateNoResultsLabel()
    }

    fileprivate var debounceCellReload = debounce(0.05)
    func reloadCells(now: Bool = false) {
        if now {
            debounceCellReload {}
            self.collectionView.reloadData()
        }
        else {
            debounceCellReload {
                self.collectionView.reloadData()
            }
        }
    }

    func removeAllCellItems() {
        dataSource.removeAllCellItems()
        reloadCells(now: true)
    }

    func imageCellHeightUpdated(_ cell: StreamImageCell) {
        if let indexPath = collectionView.indexPath(for: cell),
            let calculatedHeight = cell.calculatedHeight
        {
            updateCellHeight(indexPath, height: calculatedHeight)
        }
    }

    func appendStreamCellItems(_ items: [StreamCellItem]) {
        dataSource.appendStreamCellItems(items)
        reloadCells(now: true)
    }

    func appendUnsizedCellItems(_ items: [StreamCellItem], withWidth: CGFloat?, completion: StreamDataSource.StreamContentReady? = nil) {
        let width = withWidth ?? self.view.frame.width
        dataSource.appendUnsizedCellItems(items, withWidth: width) { indexPaths in
            self.reloadCells()
            self.doneLoading()
            completion?(indexPaths)
        }
    }

    func insertUnsizedCellItems(_ cellItems: [StreamCellItem], startingIndexPath: IndexPath, completion: @escaping ElloEmptyCompletion = {}) {
        dataSource.insertUnsizedCellItems(cellItems, withWidth: self.view.frame.width, startingIndexPath: startingIndexPath) { _ in
            self.reloadCells()
            completion()
        }
    }

    func replacePlaceholder(
        _ placeholderType: StreamCellType.PlaceholderType,
        with streamCellItems: [StreamCellItem],
        completion: @escaping ElloEmptyCompletion = {}
        )
    {
        guard streamCellItems.count > 0 else {
            replacePlaceholder(placeholderType, with: [StreamCellItem(type: .placeholder, placeholderType: placeholderType)], completion: completion)
            return
        }

        for item in streamCellItems {
            item.placeholderType = placeholderType
        }

        dataSource.calculateCellItems(streamCellItems, withWidth: view.frame.width) {
            let indexPathsToReplace = self.dataSource.indexPathsForPlaceholderType(placeholderType)
            guard indexPathsToReplace.count > 0 else { return }

            _ = self.dataSource.replaceItems(at: indexPathsToReplace, with: streamCellItems)
            self.reloadCells()
            completion()
        }
    }

    func loadInitialPage(reload: Bool = false) {
        if let reloadClosure = reloadClosure, reload {
            responseConfig = nil
            pagingEnabled = false
            reloadClosure()
        }
        else if let initialLoadClosure = initialLoadClosure {
            initialLoadClosure()
        }
        else {
            let localToken = loadingToken.resetInitialPageLoadingToken()

            streamService.loadStream(
                streamKind: streamKind,
                success: { (jsonables, responseConfig) in
                    guard self.loadingToken.isValidInitialPageLoadingToken(localToken) else { return }

                    self.responseConfig = responseConfig
                    self.showInitialJSONAbles(jsonables)
                }, failure: { (error, statusCode) in
                    print("failed to load \(self.streamKind.cacheKey) stream (reason: \(error))")
                    self.initialLoadFailure()
                }, noContent: {
                    self.clearForInitialLoad()
                    self.showInitialJSONAbles([])
                })
        }
    }

    /// This method can be called by a `StreamableViewController` if it wants to
    /// override `loadInitialPage`, but doesn't need to customize the cell generation.
    func showInitialJSONAbles(_ jsonables: [JSONAble]) {
        self.clearForInitialLoad()
        self.currentJSONables = jsonables

        var items = self.generateStreamCellItems(jsonables)
        if jsonables.count == 0 {
            items.append(StreamCellItem(type: .emptyStream(height: 282)))
        }
        self.appendUnsizedCellItems(items, withWidth: nil, completion: { indexPaths in
            self.pagingEnabled = true
        })
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
        let shouldShowNoResults = noResultsLabel != nil && dataSource.visibleCellItems.count == 0
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

    func clearForInitialLoad() {
        allOlderPagesLoaded = false
        dataSource.removeAllCellItems()
        reloadCells(now: true)
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
            let alertController = AlertViewController(message: message)
            let action = AlertAction(title: InterfaceString.OK, style: .dark, handler: nil)
            alertController.addAction(action)
            logPresentingAlert("StreamViewController")
            present(alertController, animated: true) {
                if let navigationController = self.navigationController, navigationController.childViewControllers.count > 1 {
                    _ = navigationController.popViewController(animated: true)
                }
            }
        }
        else if let navigationController = navigationController, navigationController.childViewControllers.count > 1 {
            _ = navigationController.popViewController(animated: false)
        }
    }

    fileprivate func addNotificationObservers() {
        updatedStreamImageCellHeightNotification = NotificationObserver(notification: StreamNotification.AnimateCellHeightNotification) { [weak self] streamImageCell in
            guard let `self` = self else { return }
            self.imageCellHeightUpdated(streamImageCell)
        }
        updateCellHeightNotification = NotificationObserver(notification: StreamNotification.UpdateCellHeightNotification) { [weak self] streamTextCell in
            guard let `self` = self else { return }
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
        rotationNotification = NotificationObserver(notification: Application.Notifications.DidChangeStatusBarOrientation) { [weak self] _ in
            guard let `self` = self else { return }
            self.reloadCells()
        }
        sizeChangedNotification = NotificationObserver(notification: Application.Notifications.ViewSizeWillChange) { [weak self] size in
            guard let `self` = self else { return }

            if let layout = self.collectionView.collectionViewLayout as? StreamCollectionViewLayout {
                layout.columnCount = self.streamKind.columnCountFor(width: size.width)
                layout.invalidateLayout()
            }
            self.reloadCells()
        }

        commentChangedNotification = NotificationObserver(notification: CommentChangedNotification) { [weak self] (comment, change) in
            guard
                let `self` = self, self.initialDataLoaded && self.isViewLoaded
            else { return }

            switch change {
            case .create, .delete, .update, .replaced:
                self.dataSource.modifyItems(comment, change: change, collectionView: self.collectionView)
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
                    self.dataSource.modifyItems(post, change: change, collectionView: self.collectionView)
                }
                // reload page
            case .create,
                .update,
                .replaced,
                .loved,
                .watching:
                self.dataSource.modifyItems(post, change: change, collectionView: self.collectionView)
            case .read: break
            }
            self.updateNoResultsLabel()
        }

        jsonableChangedNotification = NotificationObserver(notification: JSONAbleChangedNotification) { [weak self] (jsonable, change) in
            guard
                let `self` = self, self.initialDataLoaded && self.isViewLoaded
            else { return }

            self.dataSource.modifyItems(jsonable, change: change, collectionView: self.collectionView)
            self.updateNoResultsLabel()
        }

        relationshipChangedNotification = NotificationObserver(notification: RelationshipChangedNotification) { [weak self] user in
            guard
                let `self` = self, self.initialDataLoaded && self.isViewLoaded
            else { return }

            self.dataSource.modifyUserRelationshipItems(user, collectionView: self.collectionView)
            self.updateNoResultsLabel()
        }

        settingChangedNotification = NotificationObserver(notification: SettingChangedNotification) { [weak self] user in
            guard
                let `self` = self, self.initialDataLoaded && self.isViewLoaded
            else { return }

            self.dataSource.modifyUserSettingsItems(user, collectionView: self.collectionView)
            self.updateNoResultsLabel()
        }

        currentUserChangedNotification = NotificationObserver(notification: CurrentUserChangedNotification) { [weak self] user in
            guard
                let `self` = self, self.initialDataLoaded && self.isViewLoaded
            else { return }

            self.dataSource.modifyItems(user, change: .update, collectionView: self.collectionView)
            self.updateNoResultsLabel()
        }
    }

    fileprivate func removeNotificationObservers() {
        updatedStreamImageCellHeightNotification?.removeObserver()
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
        let existingHeight = dataSource.heightForIndexPath(indexPath, numberOfColumns: columnCount)
        if height != existingHeight {
            self.dataSource.updateHeightForIndexPath(indexPath, height: height)
            // collectionView.performBatchUpdates({
            //     collectionView.reloadItemsAtIndexPaths([indexPath])
            // }, completion: nil)
            collectionView.reloadData()
        }
    }

    fileprivate func setupCollectionView() {
        let postbarController = PostbarController(collectionView: collectionView, dataSource: dataSource, presentingController: self)
        postbarController.currentUser = currentUser
        dataSource.postbarDelegate = postbarController
        self.postbarController = postbarController

        let relationshipController = RelationshipController(presentingController: self)
        relationshipController.currentUser = self.currentUser
        self.relationshipController = relationshipController

        // set delegates
        dataSource.imageDelegate = self
        dataSource.editingDelegate = self
        dataSource.inviteDelegate = self
        dataSource.simpleStreamDelegate = self
        dataSource.categoryDelegate = self
        dataSource.userDelegate = self
        dataSource.webLinkDelegate = self
        dataSource.categoryListCellDelegate = self
        dataSource.announcementCellDelegate = self
        dataSource.relationshipDelegate = relationshipController

        collectionView.dataSource = dataSource
        collectionView.delegate = self
        automaticallyAdjustsScrollViewInsets = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.alwaysBounceVertical = true
        collectionView.isDirectionalLockEnabled = true
        collectionView.keyboardDismissMode = .onDrag
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true

        StreamCellType.registerAll(collectionView)
        setupCollectionViewLayout()
    }

    // this gets reset whenever the streamKind changes
    fileprivate func setupCollectionViewLayout() {
        guard let layout = collectionView?.collectionViewLayout as? StreamCollectionViewLayout else { return }
        layout.columnCount = streamKind.columnCountFor(width: view.frame.width)
        layout.sectionInset = UIEdgeInsets.zero
        layout.minimumColumnSpacing = streamKind.columnSpacing
        layout.minimumInteritemSpacing = 0
    }

    fileprivate func setupImageViewDelegate() {
        if imageViewer == nil {
            imageViewer = StreamImageViewer(presentingController: self)
        }
    }

    fileprivate func setupDataSource() {
        dataSource = StreamDataSource(
            streamKind: streamKind,
            textSizeCalculator: StreamTextCellSizeCalculator(webView: UIWebView()),
            notificationSizeCalculator: StreamNotificationCellSizeCalculator(webView: UIWebView()),
            announcementSizeCalculator: AnnouncementCellSizeCalculator(),
            profileHeaderSizeCalculator: ProfileHeaderCellSizeCalculator(),
            imageSizeCalculator: StreamImageCellSizeCalculator(),
            categoryHeaderSizeCalculator: CategoryHeaderCellSizeCalculator()

        )

        dataSource.streamCollapsedFilter = { item in
            if !item.type.collapsable {
                return true
            }
            if item.jsonable is Post {
                return item.state != .collapsed
            }
            return true
        }
    }

}

// MARK: DELEGATE EXTENSIONS

// MARK: StreamViewController: InviteDelegate
extension StreamViewController: InviteDelegate {

    func sendInvite(person: LocalPerson, isOnboarding: Bool, didUpdate: @escaping ElloEmptyCompletion) {
        if let email = person.emails.first {
            if isOnboarding {
                Tracker.shared.onboardingFriendInvited()
            }
            else {
                Tracker.shared.friendInvited()
            }
            ElloHUD.showLoadingHudInView(view)
            InviteService().invite(email,
                success: {
                    ElloHUD.hideLoadingHudInView(self.view)
                    didUpdate()
                },
                failure: { _ in
                    ElloHUD.hideLoadingHudInView(self.view)
                    didUpdate()
                })
        }
    }
}

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
        self.removeAllCellItems()
        let items = generateStreamCellItems(self.currentJSONables)
        self.appendUnsizedCellItems(items, withWidth: nil) { indexPaths in
            animate {
                self.collectionView.alpha = 1
            }
        }
        self.setupCollectionViewLayout()
    }
}

// MARK: StreamViewController: CategoryListCellDelegate
extension StreamViewController: CategoryListCellDelegate {

    func categoryListCellTapped(slug: String, name: String) {
        showCategoryViewController(slug: slug, name: name)
    }

}

// MARK: StreamViewController: SimpleStreamDelegate
extension StreamViewController: SimpleStreamDelegate {
    func showSimpleStream(endpoint: ElloAPI, title: String, noResultsMessages: (title: String, body: String)? = nil ) {
        let vc = SimpleStreamViewController(endpoint: endpoint, title: title)
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
        return pullToRefreshEnabled
    }

    func pull(_ view: SSPullToRefreshView, didTransitionTo toState: SSPullToRefreshViewState, from fromState: SSPullToRefreshViewState, animated: Bool) {
        if toState == .loading {
            if pullToRefreshEnabled {
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
        sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
            let width = calculateColumnWidth(frameWidth: UIWindow.windowWidth(), columnCount: columnCount)
            let height = dataSource.heightForIndexPath(indexPath, numberOfColumns: 1)
            return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        groupForItemAtIndexPath indexPath: IndexPath) -> String? {
            return dataSource.groupForIndexPath(indexPath)
    }

    func collectionView(_ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        heightForItemAtIndexPath indexPath: IndexPath, numberOfColumns: NSInteger) -> CGFloat {
            return dataSource.heightForIndexPath(indexPath, numberOfColumns: numberOfColumns)
    }

    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        isFullWidthAtIndexPath indexPath: IndexPath) -> Bool {
            return dataSource.isFullWidthAtIndexPath(indexPath)
    }
}

// MARK: StreamViewController: StreamEditingDelegate
extension StreamViewController: StreamEditingDelegate {
    func cellDoubleTapped(cell: UICollectionViewCell, location: CGPoint) {
        if let path = collectionView.indexPath(for: cell),
            let post = dataSource.postForIndexPath(path),
            let footerPath = dataSource.footerIndexPathForPost(post)
        {
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

            if !post.loved {
                let footerCell = collectionView.cellForItem(at: footerPath) as? StreamFooterCell
                postbarController?.lovesButtonTapped(footerCell, indexPath: footerPath)
            }
        }
    }

    func cellLongPressed(cell: UICollectionViewCell) {
        if let indexPath = collectionView.indexPath(for: cell),
            let post = dataSource.postForIndexPath(indexPath),
            let currentUser = currentUser, currentUser.isOwn(post: post)
        {
            createPostDelegate?.editPost(post, fromController: self)
        }
        else if let indexPath = collectionView.indexPath(for: cell),
            let comment = dataSource.commentForIndexPath(indexPath),
            let currentUser = currentUser, currentUser.isOwn(comment: comment)
        {
            createPostDelegate?.editComment(comment, fromController: self)
        }
    }
}

// MARK: StreamViewController: StreamImageCellDelegate
extension StreamViewController: StreamImageCellDelegate {
    func imageTapped(imageView: FLAnimatedImageView, cell: StreamImageCell) {
        let indexPath = collectionView.indexPath(for: cell)
        let post = indexPath.flatMap(dataSource.postForIndexPath)
        let imageAsset = indexPath.flatMap(dataSource.imageAssetForIndexPath)

        if streamKind.isGridView || cell.isGif {
            if let post = post {
                postTappedDelegate?.postTapped(post)
            }
        }
        else if let imageViewer = imageViewer {
            imageViewer.imageTapped(imageView, imageURL: cell.presentedImageUrl)
            if let post = post,
                    let asset = imageAsset {
                Tracker.shared.viewedImage(asset, post: post)
            }
        }
    }
}

// MARK: StreamViewController: Commenting
extension StreamViewController {

    func createCommentTapped(_ post: Post) {
        createPostDelegate?.createComment(post, text: nil, fromController: self)
    }
}

// MARK: StreamViewController: Open category
extension StreamViewController {

    func categoryTapped(_ category: Category) {
        showCategoryViewController(slug: category.slug, name: category.name)
    }

    func showCategoryViewController(slug: String, name: String) {
        Tracker.shared.categoryOpened(slug)
        let vc = CategoryViewController(slug: slug, name: name)
        vc.currentUser = currentUser
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: StreamViewController: CategoryDelegate
extension StreamViewController: CategoryDelegate {

    func categoryCellTapped(cell: UICollectionViewCell) {
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let post = dataSource.jsonableForIndexPath(indexPath) as? Post,
            let category = post.category
        else { return }

        categoryTapped(category)
    }
}


// MARK: StreamViewController: UserDelegate
extension StreamViewController: UserDelegate {

    func userTappedText(cell: UICollectionViewCell) {
        guard streamKind.tappingTextOpensDetail,
            let indexPath = collectionView.indexPath(for: cell)
        else { return }

        collectionView(collectionView, didSelectItemAt: indexPath)
    }

    func userTapped(user: User) {
        userTappedDelegate?.userTapped(user)
    }

    func userTappedAuthor(cell: UICollectionViewCell) {
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let user = dataSource.userForIndexPath(indexPath)
        else { return }

        userTapped(user: user)
    }

    func userTappedReposter(cell: UICollectionViewCell) {
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let reposter = dataSource.reposterForIndexPath(indexPath)
        else { return }

        userTapped(user: reposter)
    }

    func userTappedUser(_ user: User) {
        userTapped(user: user)
    }

    func userTappedFeaturedCategories(cell: UICollectionViewCell) {
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let user = dataSource.userForIndexPath(indexPath)
        else { return }

        print("\(user.atName) userTappedFeaturedCategories()")
    }

}

// MARK: StreamViewController: WebLinkDelegate
extension StreamViewController: WebLinkDelegate {

    func webLinkTapped(type: ElloURI, data: String) {
        switch type {
        case .confirm,
             .faceMaker,
             .freedomOfSpeech,
             .invitations,
             .invite,
             .join,
             .login,
             .nativeRedirect,
             .onboarding,
             .passwordResetError,
             .profileFollowers,
             .profileFollowing,
             .profileLoves,
             .randomSearch,
             .requestInvitations,
             .resetMyPassword,
             .searchPeople,
             .searchPosts,
             .unblock:
            break
        case .downloads,
             .external,
             .forgotMyPassword,
             .manifesto,
             .requestInvite,
             .requestInvitation,
             .subdomain,
             .whoMadeThis,
             .wtf:
            postNotification(ExternalWebNotification, value: data)
        case .discover:
            DeepLinking.showDiscover(navVC: navigationController, currentUser: currentUser)
        case .category,
             .discoverRandom,
             .discoverRecent,
             .discoverRelated,
             .discoverTrending,
             .exploreRecommended,
             .exploreRecent,
             .exploreTrending:
            DeepLinking.showCategory(navVC: navigationController, currentUser: currentUser, slug: data)
        case .email: break // this is handled in ElloWebViewHelper
        case .betaPublicProfiles,
             .enter,
             .exit,
             .root,
             .explore:
            break // do nothing since we should already be in app
        case .friends, .following, .noise, .starred: selectTab(.stream)
        case .notifications: selectTab(.notifications)
        case .post,
             .pushNotificationComment,
             .pushNotificationPost:
            DeepLinking.showPostDetail(navVC: navigationController, currentUser: currentUser, token: data)
        case .profile,
             .pushNotificationUser:
            DeepLinking.showProfile(navVC: navigationController, currentUser: currentUser, username: data)
        case .search: DeepLinking.showSearch(navVC: navigationController, currentUser: currentUser, terms: data)
        case .settings: DeepLinking.showSettings(navVC: navigationController, currentUser: currentUser)
        }
    }

    fileprivate func selectTab(_ tab: ElloTab) {
        elloTabBarController?.selectedTab = tab
    }
}

// MARK: StreamViewController: AnnouncementCellDelegate
extension StreamViewController: AnnouncementCellDelegate {
    func markAnnouncementAsRead(cell: UICollectionViewCell) {
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let announcement = dataSource.jsonableForIndexPath(indexPath) as? Announcement
        else { return }

        announcementDelegate?.markAnnouncementAsRead(announcement: announcement)
    }
}

// MARK: StreamViewController: UICollectionViewDelegate
extension StreamViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? DismissableCell {
            cell.didEndDisplay()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let tappedCell = collectionView.cellForItem(at: indexPath)

        if let item = dataSource.visibleStreamCellItem(at: indexPath),
            let paths = collectionView.indexPathsForSelectedItems,
            tappedCell is CategoryCardCell && item.type == .selectableCategoryCard
        {
            let selection = paths.flatMap { dataSource.jsonableForIndexPath($0) as? Category }
            selectedCategoryDelegate?.categoriesSelectionChanged(selection: selection)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tappedCell = collectionView.cellForItem(at: indexPath)

        var keepSelected = false
        if tappedCell is StreamToggleCell {
            dataSource.toggleCollapsedForIndexPath(indexPath)
            reloadCells(now: true)
        }
        else if tappedCell is UserListItemCell {
            if let user = dataSource.userForIndexPath(indexPath) {
                userTapped(user: user)
            }
        }
        else if tappedCell is StreamSeeMoreCommentsCell {
            if let lastComment = dataSource.commentForIndexPath(indexPath),
                let post = lastComment.loadedFromPost
            {
                postTappedDelegate?.postTapped(post, scrollToComment: lastComment)
            }
        }
        else if let post = dataSource.postForIndexPath(indexPath) {
            postTappedDelegate?.postTapped(post)
        }
        else if let notification = dataSource.jsonableForIndexPath(indexPath) as? Notification,
            let postId = notification.postId
        {
            postTappedDelegate?.postTapped(postId: postId)
        }
        else if let notification = dataSource.jsonableForIndexPath(indexPath) as? Notification,
            let user = notification.subject as? User
        {
            userTapped(user: user)
        }
        else if let announcement = dataSource.jsonableForIndexPath(indexPath) as? Announcement,
            let callToAction = announcement.ctaURL
        {
            Tracker.shared.announcementOpened(announcement)
            let request = URLRequest(url: callToAction)
            ElloWebViewHelper.handle(request: request, webLinkDelegate: self)
        }
        else if let comment = dataSource.commentForIndexPath(indexPath),
            let post = comment.loadedFromPost
        {
            createCommentTapped(post)
        }
        else if let item = dataSource.visibleStreamCellItem(at: indexPath),
            let category = dataSource.jsonableForIndexPath(indexPath) as? Category
        {
            if item.type == .selectableCategoryCard {
                keepSelected = true
                let paths = collectionView.indexPathsForSelectedItems
                let selection = paths?.flatMap { dataSource.jsonableForIndexPath($0) as? Category }
                selectedCategoryDelegate?.categoriesSelectionChanged(selection: selection ?? [Category]())
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
                let cellItemType = dataSource.visibleStreamCellItem(at: indexPath)?.type
            else { return false }

            return cellItemType.selectable
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
            pagingEnabled &&
            scrollView.contentOffset.y + (self.view.frame.height * 1.666)
            > scrollView.contentSize.height
        else { return }

        guard
            !allOlderPagesLoaded &&
            responseConfig?.totalPagesRemaining != "0"
        else { return }

        guard
            let nextQueryItems = responseConfig?.nextQueryItems
        else { return }

        guard let lastCellItem = dataSource.visibleCellItems.last, lastCellItem.type != .streamLoading
        else { return }

        let placeholderType = lastCellItem.placeholderType
        appendStreamCellItems([StreamCellItem(type: .streamLoading)])

        scrollToPaginateGuard = false

        let scrollAPI = ElloAPI.infiniteScroll(queryItems: nextQueryItems) { return self.streamKind.endpoint }
        streamService.loadStream(
            endpoint: scrollAPI,
            streamKind: streamKind,
            success: {
                (jsonables, responseConfig) in
                self.scrollLoaded(jsonables: jsonables, placeholderType: placeholderType)
                self.responseConfig = responseConfig
            },
            failure: { (error, statusCode) in
                print("failed to load stream (reason: \(error))")
                self.scrollLoaded()
            },
            noContent: {
                self.allOlderPagesLoaded = true
                self.scrollLoaded()
            })
    }

    fileprivate func scrollLoaded(jsonables: [JSONAble] = [], placeholderType: StreamCellType.PlaceholderType? = nil) {
        guard
            let lastIndexPath = collectionView.lastIndexPathForSection(0)
        else { return }

        if jsonables.count > 0 {
            if let controller = parent as? BaseElloViewController {
                Tracker.shared.screenAppeared(controller)
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

        dataSource.removeItemsAtIndexPaths([lastIndexPath])
        reloadCells(now: true)
    }
}
