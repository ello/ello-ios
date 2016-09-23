////
///  StreamViewController.swift
//

import SSPullToRefresh
import FLAnimatedImage
import Crashlytics
import SwiftyUserDefaults
import DeltaCalculator


// MARK: Delegate Implementations
public protocol InviteDelegate: class {
    func sendInvite(person: LocalPerson, didUpdate: ElloEmptyCompletion)
}

public protocol SimpleStreamDelegate: class {
    func showSimpleStream(endpoint: ElloAPI, title: String, noResultsMessages: (title: String, body: String)?)
}

public protocol StreamImageCellDelegate: class {
    func imageTapped(imageView: FLAnimatedImageView, cell: StreamImageCell)
}

public protocol StreamEditingDelegate: class {
    func cellDoubleTapped(cell: UICollectionViewCell, location: CGPoint)
    func cellLongPressed(cell: UICollectionViewCell)
}

public typealias StreamCellItemGenerator = () -> [StreamCellItem]
public protocol StreamViewDelegate: class {
    func streamViewCustomLoadFailed() -> Bool
    func streamViewStreamCellItems(jsonables: [JSONAble], defaultGenerator: StreamCellItemGenerator) -> [StreamCellItem]?
    func streamViewDidScroll(scrollView: UIScrollView)
    func streamViewWillBeginDragging(scrollView: UIScrollView)
    func streamViewDidEndDragging(scrollView: UIScrollView, willDecelerate: Bool)
}

public protocol CategoryDelegate: class {
    func categoryCellTapped(cell: UICollectionViewCell)
}

public protocol SelectedCategoryDelegate: class {
    func categoriesSelectionChanged(selection: [Category])
}

public protocol UserDelegate: class {
    func userTappedAuthor(cell: UICollectionViewCell)
    func userTappedReposter(cell: UICollectionViewCell)
    func userTappedText(cell: UICollectionViewCell)
    func userTappedUser(user: User)
}

public protocol WebLinkDelegate: class {
    func webLinkTapped(type: ElloURI, data: String)
}

public protocol ColumnToggleDelegate: class {
    func columnToggleTapped(isGridView: Bool)
}

public protocol DiscoverCategoryPickerDelegate: class {
    func discoverCategoryTapped(endpoint: ElloAPI)
    func discoverAllCategoriesTapped()
}

public protocol SearchStreamDelegate: class {
    func searchFieldChanged(text: String)
}

// MARK: StreamNotification
public struct StreamNotification {
    static let AnimateCellHeightNotification = TypedNotification<StreamImageCell>(name: "AnimateCellHeightNotification")
    static let UpdateCellHeightNotification = TypedNotification<UICollectionViewCell>(name: "UpdateCellHeightNotification")
}

// MARK: StreamViewController
public final class StreamViewController: BaseElloViewController {

    @IBOutlet weak public var collectionView: UICollectionView!
    @IBOutlet weak public var noResultsLabel: UILabel!
    @IBOutlet weak public var noResultsTopConstraint: NSLayoutConstraint!
    private let defaultNoResultsTopConstant: CGFloat = 113

    var currentJSONables = [JSONAble]()

    public var noResultsMessages = (title: "", body: "") {
        didSet {
            let titleParagraphStyle = NSMutableParagraphStyle()
            titleParagraphStyle.lineSpacing = 17

            let titleAttributes = [
                NSFontAttributeName: UIFont.defaultBoldFont(18),
                NSForegroundColorAttributeName: UIColor.blackColor(),
                NSParagraphStyleAttributeName: titleParagraphStyle
            ]

            let bodyParagraphStyle = NSMutableParagraphStyle()
            bodyParagraphStyle.lineSpacing = 8

            let bodyAttributes = [
                NSFontAttributeName: UIFont.defaultFont(),
                NSForegroundColorAttributeName: UIColor.blackColor(),
                NSParagraphStyleAttributeName: bodyParagraphStyle
            ]

            let title = NSAttributedString(string: self.noResultsMessages.title + "\n", attributes: titleAttributes)
            let body = NSAttributedString(string: self.noResultsMessages.body, attributes: bodyAttributes)
            self.noResultsLabel.attributedText = title.append(body)
        }
    }

    public typealias ToggleClosure = (Bool) -> Void

    public var dataSource: StreamDataSource!
    public var postbarController: PostbarController?
    var relationshipController: RelationshipController?
    public var responseConfig: ResponseConfig?
    public var pagingEnabled = false
    private var scrollToPaginateGuard = false

    public let streamService = StreamService()
    lazy public var loadingToken: LoadingToken = self.createLoadingToken()

    // moved into a separate function to save compile time
    private func createLoadingToken() -> LoadingToken {
        var token = LoadingToken()
        token.cancelLoadingClosure = { [unowned self] in
            self.doneLoading()
        }
        return token
    }

    public var pullToRefreshView: SSPullToRefreshView?
    var allOlderPagesLoaded = false
    public var initialLoadClosure: ElloEmptyCompletion?
    public var reloadClosure: ElloEmptyCompletion?
    public var toggleClosure: ToggleClosure?
    var initialDataLoaded = false
    var parentTabBarController: ElloTabBarController? {
        if let parentViewController = self.parentViewController,
            elloController = parentViewController as? BaseElloViewController
        {
            return elloController.elloTabBarController
        }
        return nil
    }

    public var streamKind: StreamKind = StreamKind.Unknown {
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
    var loveChangedNotification: NotificationObserver?
    var relationshipChangedNotification: NotificationObserver?
    var settingChangedNotification: NotificationObserver?
    var currentUserChangedNotification: NotificationObserver?

    weak var createPostDelegate: CreatePostDelegate?
    weak var postTappedDelegate: PostTappedDelegate?
    weak var userTappedDelegate: UserTappedDelegate?
    weak var streamViewDelegate: StreamViewDelegate?
    weak var selectedCategoryDelegate: SelectedCategoryDelegate?
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

    public func batchUpdateFilter(filter: StreamDataSource.StreamFilter) {
        let delta = dataSource.updateFilter(filter)
        let collectionView = self.collectionView
        collectionView.performBatchUpdates({
            delta.applyUpdatesToCollectionView(collectionView, inSection: 0)
        }, completion: nil)
    }

    public var contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) {
        didSet {
            self.collectionView.contentInset = contentInset
            self.collectionView.scrollIndicatorInsets = contentInset
            self.pullToRefreshView?.defaultContentInset = contentInset
        }
    }
    public var columnCount: Int {
        guard let layout = self.collectionView.collectionViewLayout as? StreamCollectionViewLayout else {
            return 1
        }
        return layout.columnCount
    }

    var pullToRefreshEnabled: Bool = true {
        didSet { pullToRefreshView?.hidden = !pullToRefreshEnabled }
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
    }

    override public func didSetCurrentUser() {
        dataSource.currentUser = currentUser
        relationshipController?.currentUser = currentUser
        postbarController?.currentUser = currentUser
        super.didSetCurrentUser()
    }

    // If we ever create an init() method that doesn't use nib/storyboards,
    // we'll need to call this.
    private func initialSetup() {
        setupDataSource()
        setupImageViewDelegate()
        // most consumers of StreamViewController expect all outlets (esp collectionView) to be set
        if !isViewLoaded() { let _ = view }
    }

    deinit {
        removeNotificationObservers()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        pullToRefreshView = SSPullToRefreshView(scrollView: collectionView, delegate: self)
        pullToRefreshView?.contentView = ElloPullToRefreshView(frame: .zero)
        pullToRefreshView?.hidden = !pullToRefreshEnabled

        setupCollectionView()
        addNotificationObservers()
    }

    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Crashlytics.sharedInstance().setObjectValue(streamKind.name, forKey: CrashlyticsKey.StreamName.rawValue)
    }

    public class func instantiateFromStoryboard() -> StreamViewController {
        return UIStoryboard.storyboardWithId(.Stream) as! StreamViewController
    }

// MARK: Public Functions

    public func scrollToTop() {
        collectionView.contentOffset = CGPoint(x: 0, y: 0)
    }

    public func doneLoading() {
        ElloHUD.hideLoadingHudInView(view)
        pullToRefreshView?.finishLoading()
        initialDataLoaded = true
        updateNoResultsLabel()
    }

    private var debounceCellReload = debounce(0.05)
    public func reloadCells(now now: Bool = false) {
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

    public func removeAllCellItems() {
        dataSource.removeAllCellItems()
        reloadCells(now: true)
    }

    public func imageCellHeightUpdated(cell: StreamImageCell) {
        if let indexPath = collectionView.indexPathForCell(cell),
            calculatedHeight = cell.calculatedHeight
        {
            updateCellHeight(indexPath, height: calculatedHeight)
        }
    }

    public func appendStreamCellItems(items: [StreamCellItem]) {
        dataSource.appendStreamCellItems(items)
        reloadCells(now: true)
    }

    public func appendUnsizedCellItems(items: [StreamCellItem], withWidth: CGFloat?, completion: StreamDataSource.StreamContentReady? = nil) {
        let width = withWidth ?? self.view.frame.width
        dataSource.appendUnsizedCellItems(items, withWidth: width) { indexPaths in
            self.reloadCells()
            self.doneLoading()
            completion?(indexPaths: indexPaths)
        }
    }

    public func insertUnsizedCellItems(cellItems: [StreamCellItem], startingIndexPath: NSIndexPath, completion: ElloEmptyCompletion? = nil) {
        dataSource.insertUnsizedCellItems(cellItems, withWidth: self.view.frame.width, startingIndexPath: startingIndexPath) { _ in
            self.reloadCells()
            completion?()
        }
    }

    public func replacePlaceholder(
        placeholderType: StreamCellType.PlaceholderType,
        @autoclosure with streamCellItemsGenerator: () -> [StreamCellItem],
        completion: ElloEmptyCompletion = {}
        )
    {
        let streamCellItems = streamCellItemsGenerator()
        for item in streamCellItems {
            item.placeholderType = placeholderType
        }

        dataSource.calculateCellItems(streamCellItems, withWidth: view.frame.width) {
            let indexPathsToReplace = self.dataSource.indexPathsForPlaceholderType(placeholderType)
            guard indexPathsToReplace.count > 0 else { return }

            self.dataSource.replaceItems(at: indexPathsToReplace, with: streamCellItems)
            self.reloadCells()
            completion()
        }
    }

    public func loadInitialPage(reload reload: Bool = false) {
        if let reloadClosure = reloadClosure where reload {
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
                streamKind.endpoint,
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
                    self.currentJSONables = []
                    var items = self.generateStreamCellItems([])
                    items.append(StreamCellItem(type: .Text(data: TextRegion(content: "Nothing to see here"))))
                    self.appendUnsizedCellItems(items, withWidth: nil, completion: { indexPaths in
                        if self.streamKind.gridViewPreferenceSet {
                            self.collectionView.layoutIfNeeded()
                            self.collectionView.setContentOffset(self.streamKind.gridPreferenceSetOffset, animated: false)
                        }
                    })
                })
        }
    }

    /// This method can be called by a `StreamableViewController` if it wants to
    /// override `loadInitialPage`, but doesn't need to customize the cell generation.
    public func showInitialJSONAbles(jsonables: [JSONAble]) {
        self.clearForInitialLoad()
        self.currentJSONables = jsonables

        let items = self.generateStreamCellItems(jsonables)
        self.appendUnsizedCellItems(items, withWidth: nil, completion: { indexPaths in
            self.pagingEnabled = true
            if self.streamKind.gridViewPreferenceSet {
                self.collectionView.layoutIfNeeded()
                self.collectionView.setContentOffset(self.streamKind.gridPreferenceSetOffset, animated: false)
            }
        })
    }

    private func generateStreamCellItems(jsonables: [JSONAble]) -> [StreamCellItem] {
        let defaultGenerator: StreamCellItemGenerator = {
            return StreamCellItemParser().parse(jsonables, streamKind: self.streamKind, currentUser: self.currentUser)
        }

        if let items = streamViewDelegate?.streamViewStreamCellItems(jsonables, defaultGenerator: defaultGenerator) {
            return items
        }

        var items: [StreamCellItem] = []
        if self.streamKind.hasGridViewToggle {
            let toggleCellItem = StreamCellItem(type: .ColumnToggle)
            items += [toggleCellItem]
        }

        items += defaultGenerator()
        return items
    }

    private func updateNoResultsLabel() {
        delay(0.666) {
            if self.noResultsLabel != nil {
                self.dataSource.visibleCellItems.count > 0 ? self.hideNoResults() : self.showNoResults()
            }
        }
    }

    public func hideNoResults() {
        noResultsLabel.hidden = true
        noResultsLabel.alpha = 0
    }

    public func showNoResults() {
        noResultsLabel.hidden = false
        UIView.animateWithDuration(0.25) {
            self.noResultsLabel.alpha = 1
        }
    }

    public func clearForInitialLoad() {
        allOlderPagesLoaded = false
        dataSource.removeAllCellItems()
        reloadCells(now: true)
    }

// MARK: Private Functions

    private func initialLoadFailure() {
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
            let action = AlertAction(title: InterfaceString.OK, style: .Dark, handler: nil)
            alertController.addAction(action)
            logPresentingAlert("StreamViewController")
            presentViewController(alertController, animated: true) {
                if let navigationController = self.navigationController
                where navigationController.childViewControllers.count > 1 {
                    navigationController.popViewControllerAnimated(true)
                }
            }
        }
        else if let navigationController = navigationController
        where navigationController.childViewControllers.count > 1 {
            navigationController.popViewControllerAnimated(false)
        }
    }

    private func addNotificationObservers() {
        updatedStreamImageCellHeightNotification = NotificationObserver(notification: StreamNotification.AnimateCellHeightNotification) { [unowned self] streamImageCell in
            self.imageCellHeightUpdated(streamImageCell)
        }
        updateCellHeightNotification = NotificationObserver(notification: StreamNotification.UpdateCellHeightNotification) { [unowned self] streamTextCell in
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
        rotationNotification = NotificationObserver(notification: Application.Notifications.DidChangeStatusBarOrientation) { [unowned self] _ in
            self.reloadCells()
        }
        sizeChangedNotification = NotificationObserver(notification: Application.Notifications.ViewSizeWillChange) { [unowned self] size in
            if let layout = self.collectionView.collectionViewLayout as? StreamCollectionViewLayout {
                layout.columnCount = self.streamKind.columnCountFor(width: size.width)
                layout.invalidateLayout()
            }
            self.reloadCells()
        }

        commentChangedNotification = NotificationObserver(notification: CommentChangedNotification) { [weak self] (comment, change) in
            guard let
                sself = self
            where sself.initialDataLoaded && sself.isViewLoaded()
            else { return }

            switch change {
            case .Create, .Delete, .Update, .Replaced:
                sself.dataSource.modifyItems(comment, change: change, collectionView: sself.collectionView)
            default: break
            }
            sself.updateNoResultsLabel()
        }

        postChangedNotification = NotificationObserver(notification: PostChangedNotification) { [unowned self] (post, change) in
            if !self.initialDataLoaded {
                return
            }
            switch change {
            case .Delete:
                switch self.streamKind {
                case .PostDetail: break
                default:
                    self.dataSource.modifyItems(post, change: change, collectionView: self.collectionView)
                }
                // reload page
            case .Create,
                .Update,
                .Replaced,
                .Loved:
                self.dataSource.modifyItems(post, change: change, collectionView: self.collectionView)
            case .Read: break
            }
            self.updateNoResultsLabel()
        }

        loveChangedNotification  = NotificationObserver(notification: LoveChangedNotification) { [unowned self] (love, change) in
            if !self.initialDataLoaded {
                return
            }
            self.dataSource.modifyItems(love, change: change, collectionView: self.collectionView)
            self.updateNoResultsLabel()
        }

        relationshipChangedNotification = NotificationObserver(notification: RelationshipChangedNotification) { [unowned self] user in
            if !self.initialDataLoaded {
                return
            }
            self.dataSource.modifyUserRelationshipItems(user, collectionView: self.collectionView)
            self.updateNoResultsLabel()
        }

        settingChangedNotification = NotificationObserver(notification: SettingChangedNotification) { [unowned self] user in
            if !self.initialDataLoaded {
                return
            }
            self.dataSource.modifyUserSettingsItems(user, collectionView: self.collectionView)
            self.updateNoResultsLabel()
        }

        currentUserChangedNotification = NotificationObserver(notification: CurrentUserChangedNotification) { [unowned self] user in
            if !self.initialDataLoaded {
                return
            }
            self.dataSource.modifyItems(user, change: .Update, collectionView: self.collectionView)
            self.updateNoResultsLabel()
        }
    }

    private func removeNotificationObservers() {
        updatedStreamImageCellHeightNotification?.removeObserver()
        updateCellHeightNotification?.removeObserver()
        rotationNotification?.removeObserver()
        sizeChangedNotification?.removeObserver()
        commentChangedNotification?.removeObserver()
        postChangedNotification?.removeObserver()
        relationshipChangedNotification?.removeObserver()
        loveChangedNotification?.removeObserver()
        settingChangedNotification?.removeObserver()
        currentUserChangedNotification?.removeObserver()
    }

    private func updateCellHeight(indexPath: NSIndexPath, height: CGFloat) {
        let existingHeight = dataSource.heightForIndexPath(indexPath, numberOfColumns: columnCount)
        if height != existingHeight {
            collectionView.performBatchUpdates({
                self.dataSource.updateHeightForIndexPath(indexPath, height: height)
            }, completion: nil)
            collectionView.reloadItemsAtIndexPaths([indexPath])
        }
    }

    private func setupCollectionView() {
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
        dataSource.columnToggleDelegate = self
        dataSource.discoverCategoryPickerDelegate = self
        dataSource.relationshipDelegate = relationshipController

        collectionView.dataSource = dataSource
        collectionView.delegate = self
        automaticallyAdjustsScrollViewInsets = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.alwaysBounceVertical = true
        collectionView.directionalLockEnabled = true
        collectionView.keyboardDismissMode = .OnDrag
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true

        StreamCellType.registerAll(collectionView)
        setupCollectionViewLayout()
    }

    // this gets reset whenever the streamKind changes
    private func setupCollectionViewLayout() {
        guard let layout = collectionView?.collectionViewLayout as? StreamCollectionViewLayout else { return }
        layout.columnCount = streamKind.columnCountFor(width: view.frame.width)
        layout.sectionInset = UIEdgeInsetsZero
        layout.minimumColumnSpacing = streamKind.columnSpacing
        layout.minimumInteritemSpacing = 0
    }

    private func setupImageViewDelegate() {
        if imageViewer == nil {
            imageViewer = StreamImageViewer(presentingController: self)
        }
    }

    private func setupDataSource() {
        dataSource = StreamDataSource(
            streamKind: streamKind,
            textSizeCalculator: StreamTextCellSizeCalculator(webView: UIWebView()),
            notificationSizeCalculator: StreamNotificationCellSizeCalculator(webView: UIWebView()),
            profileHeaderSizeCalculator: ProfileHeaderCellSizeCalculator(webView: UIWebView()),
            imageSizeCalculator: StreamImageCellSizeCalculator()
        )

        dataSource.streamCollapsedFilter = { item in
            if !item.type.collapsable {
                return true
            }
            if item.jsonable is Post {
                return item.state != .Collapsed
            }
            return true
        }
    }

}

// MARK: DELEGATE EXTENSIONS

// MARK: StreamViewController: InviteDelegate
extension StreamViewController: InviteDelegate {

    public func sendInvite(person: LocalPerson, didUpdate: ElloEmptyCompletion) {
        if let email = person.emails.first {
            Tracker.sharedTracker.friendInvited()
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

// MARK: StreamViewController: ColumnToggleDelegate
extension StreamViewController: ColumnToggleDelegate {
    public func columnToggleTapped(isGridView: Bool) {
        guard self.streamKind.isGridView != isGridView else {
            return
        }

        self.streamKind.setIsGridView(isGridView)
        if let toggleClosure = toggleClosure {
            // setting 'scrollToPaginateGuard' to false will prevent pagination from triggering when this profile has no posts
            // triggering pagination at this time will, inexplicably, cause the cells to disappear
            scrollToPaginateGuard = false
            setupCollectionViewLayout()

            toggleClosure(isGridView)
        }
        else {
            UIView.animateWithDuration(0.2, animations: {
                self.collectionView.alpha = 0
                }, completion: { _ in
                    self.toggleGrid(isGridView)
                })
        }
    }

    private func toggleGrid(isGridView: Bool) {
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

// MARK: StreamViewController: DiscoverCategoryPickerDelegate
extension StreamViewController: DiscoverCategoryPickerDelegate {

    public func discoverCategoryTapped(endpoint: ElloAPI) {
        hideNoResults()
        switch endpoint {
        case let .CategoryPosts(slug):
            Tracker.sharedTracker.discoverCategory(slug)
            streamKind = .CategoryPosts(slug: slug)
        case let .Discover(type):
            Tracker.sharedTracker.discoverCategory(type.rawValue)
            streamKind = .Discover(type: type)
        default:
            fatalError("invalid endpoint \(endpoint)")
        }
        removeAllCellItems()
        ElloHUD.showLoadingHudInView(view)
        loadInitialPage()
    }

    public func discoverAllCategoriesTapped() {
        let vc = DiscoverAllCategoriesViewController()
        vc.currentUser = currentUser
        navigationController?.pushViewController(vc, animated: true)
    }

}

// MARK: StreamViewController: SimpleStreamDelegate
extension StreamViewController: SimpleStreamDelegate {
    public func showSimpleStream(endpoint: ElloAPI, title: String, noResultsMessages: (title: String, body: String)? = nil ) {
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
    public func pullToRefreshViewShouldStartLoading(view: SSPullToRefreshView!) -> Bool {
        return pullToRefreshEnabled
    }

    public func pullToRefreshViewDidStartLoading(view: SSPullToRefreshView!) {
        if pullToRefreshEnabled {
            self.loadInitialPage(reload: true)
        }
        else {
            pullToRefreshView?.finishLoading()
        }
    }
}

// MARK: StreamViewController: StreamCollectionViewLayoutDelegate
extension StreamViewController: StreamCollectionViewLayoutDelegate {

    public func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            let width = calculateColumnWidth(screenWidth: UIWindow.windowWidth(), columnCount: columnCount)
            let height = dataSource.heightForIndexPath(indexPath, numberOfColumns: 1)
            return CGSize(width: width, height: height)
    }

    public func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        groupForItemAtIndexPath indexPath: NSIndexPath) -> String? {
            return dataSource.groupForIndexPath(indexPath)
    }

    public func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        heightForItemAtIndexPath indexPath: NSIndexPath, numberOfColumns: NSInteger) -> CGFloat {
            return dataSource.heightForIndexPath(indexPath, numberOfColumns: numberOfColumns)
    }

    public func collectionView (collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        isFullWidthAtIndexPath indexPath: NSIndexPath) -> Bool {
            return dataSource.isFullWidthAtIndexPath(indexPath)
    }
}

// MARK: StreamViewController: StreamEditingDelegate
extension StreamViewController: StreamEditingDelegate {
    public func cellDoubleTapped(cell: UICollectionViewCell, location: CGPoint) {
        if let path = collectionView.indexPathForCell(cell),
            post = dataSource.postForIndexPath(path),
            footerPath = dataSource.footerIndexPathForPost(post)
        {
            if let window = cell.window {
                let fullDuration: NSTimeInterval = 0.4
                let halfDuration: NSTimeInterval = fullDuration / 2

                let imageView = UIImageView(image: InterfaceImage.GiantHeart.normalImage)
                imageView.contentMode = .ScaleAspectFit
                imageView.frame = window.bounds
                imageView.center = location
                imageView.alpha = 0
                imageView.transform = CGAffineTransformMakeScale(0.5, 0.5)
                let grow: () -> Void = { imageView.transform = CGAffineTransformMakeScale(1, 1) }
                let remove: (Bool) -> Void = { _ in imageView.removeFromSuperview() }
                let fadeIn: () -> Void = { imageView.alpha = 0.5 }
                let fadeOut: (Bool) -> Void = { _ in animate(duration: halfDuration, completion: remove) { imageView.alpha = 0 } }
                animate(duration: halfDuration, completion: fadeOut, animations: fadeIn)
                animate(duration: fullDuration, completion: remove, animations: grow)
                window.addSubview(imageView)
            }

            if !post.loved {
                let footerCell = collectionView.cellForItemAtIndexPath(footerPath) as? StreamFooterCell
                postbarController?.lovesButtonTapped(footerCell, indexPath: footerPath)
            }
        }
    }

    public func cellLongPressed(cell: UICollectionViewCell) {
        if let indexPath = collectionView.indexPathForCell(cell),
            post = dataSource.postForIndexPath(indexPath),
            currentUser = currentUser
        where currentUser.isOwnPost(post)
        {
            createPostDelegate?.editPost(post, fromController: self)
        }
        else if let indexPath = collectionView.indexPathForCell(cell),
            comment = dataSource.commentForIndexPath(indexPath),
            currentUser = currentUser
            where currentUser.isOwnComment(comment)
        {
            createPostDelegate?.editComment(comment, fromController: self)
        }
    }
}

// MARK: StreamViewController: StreamImageCellDelegate
extension StreamViewController: StreamImageCellDelegate {
    public func imageTapped(imageView: FLAnimatedImageView, cell: StreamImageCell) {
        let indexPath = collectionView.indexPathForCell(cell)
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
                    asset = imageAsset {
                Tracker.sharedTracker.viewedImage(asset, post: post)
            }
        }
    }
}

// MARK: StreamViewController: Commenting
extension StreamViewController {
    public func createCommentTapped(post: Post) {
        createPostDelegate?.createComment(post, text: nil, fromController: self)
    }
}

// MARK: StreamViewController: Open category
extension StreamViewController {
    public func categoryTapped(category: Category) {
        let vc = DiscoverViewController(category: category)
        vc.currentUser = currentUser
        navigationController?.pushViewController(vc, animated: true)
    }

    public func seeAllCategoriesTapped() {
        let vc = DiscoverAllCategoriesViewController()
        vc.currentUser = currentUser
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: StreamViewController: CategoryDelegate
extension StreamViewController: CategoryDelegate {

    public func categoryCellTapped(cell: UICollectionViewCell) {
        guard let
            indexPath = collectionView.indexPathForCell(cell),
            post = dataSource.jsonableForIndexPath(indexPath) as? Post,
            category = post.category
        else { return }

        categoryTapped(category)
    }
}

// MARK: StreamViewController: UserDelegate
extension StreamViewController: UserDelegate {

    public func userTappedText(cell: UICollectionViewCell) {
        guard streamKind.tappingTextOpensDetail,
            let indexPath = collectionView.indexPathForCell(cell)
        else { return }

        collectionView(collectionView, didSelectItemAtIndexPath: indexPath)
    }

    public func userTapped(user: User) {
        userTappedDelegate?.userTapped(user)
    }

    public func userTappedAuthor(cell: UICollectionViewCell) {
        guard let
            indexPath = collectionView.indexPathForCell(cell),
            user = dataSource.userForIndexPath(indexPath)
        else { return }

        userTapped(user)
    }

    public func userTappedReposter(cell: UICollectionViewCell) {
        guard let
            indexPath = collectionView.indexPathForCell(cell),
            reposter = dataSource.reposterForIndexPath(indexPath)
        else { return }

        userTapped(reposter)
    }

    public func userTappedUser(user: User) {
        userTapped(user)
    }

}

// MARK: StreamViewController: WebLinkDelegate
extension StreamViewController: WebLinkDelegate {

    public func webLinkTapped(type: ElloURI, data: String) {
        switch type {
        case .Confirm,
             .FaceMaker,
             .FreedomOfSpeech,
             .Invitations,
             .Invite,
             .Join,
             .Login,
             .NativeRedirect,
             .Onboarding,
             .PasswordResetError,
             .ProfileFollowers,
             .ProfileFollowing,
             .ProfileLoves,
             .RandomSearch,
             .RequestInvitations,
             .ResetMyPassword,
             .SearchPeople,
             .SearchPosts,
             .Unblock:
            break
        case .Downloads,
             .External,
             .ForgotMyPassword,
             .Manifesto,
             .RequestInvite,
             .RequestInvitation,
             .Subdomain,
             .WhoMadeThis,
             .WTF:
            postNotification(ExternalWebNotification, value: data)
        case .Discover,
             .DiscoverRandom,
             .DiscoverRecent,
             .DiscoverRelated,
             .DiscoverTrending,
             .ExploreRecommended,
             .ExploreRecent,
             .ExploreTrending:
            selectTab(.Discover)
        case .Category:
            selectTab(.Discover)

            if let nav = elloTabBarController?.selectedViewController as? UINavigationController,
                discoverViewController = nav.childViewControllers[0] as? DiscoverViewController
            {
                nav.popToRootViewControllerAnimated(false)
                discoverViewController.showCategory(data)
            }
        case .Email: break // this is handled in ElloWebViewHelper
        case .BetaPublicProfiles,
             .Enter,
             .Exit,
             .Root,
             .Explore:
            break // do nothing since we should already be in app
        case .Friends, .Following, .Noise, .Starred: selectTab(.Stream)
        case .Notifications: selectTab(.Notifications)
        case .Post,
             .PushNotificationComment,
             .PushNotificationPost:
            showPostDetail(data)
        case .Profile,
             .PushNotificationUser:
            showProfile(data)
        case .Search: showSearch(data)
        case .Settings: showSettings()
        }
    }

    private func showProfile(username: String) {
        let param = "~\(username)"
        if alreadyOnUserProfile(param) { return }
        let vc = ProfileViewController(userParam: param, username: username)
        vc.currentUser = currentUser
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showPostDetail(token: String) {
        let param = "~\(token)"
        if alreadyOnPostDetail(param) { return }
        let vc = PostDetailViewController(postParam: param)
        vc.currentUser = currentUser
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showSearch(terms: String) {
        if let searchVC = navigationController?.visibleViewController as? SearchViewController {
            searchVC.searchForPosts(terms)
        }
        else {
            let vc = SearchViewController()
            vc.currentUser = currentUser
            vc.searchForPosts(terms)
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    private func showSettings() {
        guard let
            settings = UIStoryboard(name: "Settings", bundle: .None).instantiateInitialViewController()
                as? SettingsContainerViewController
        else { return }

        settings.currentUser = currentUser
        navigationController?.pushViewController(settings, animated: true)
    }

    private func selectTab(tab: ElloTab) {
        elloTabBarController?.selectedTab = tab
    }
}

// MARK: StreamViewController: UICollectionViewDelegate
extension StreamViewController: UICollectionViewDelegate {

    public func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? DismissableCell {
            cell.didEndDisplay()
        }
    }

    public func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let tappedCell = collectionView.cellForItemAtIndexPath(indexPath)

        if let item = dataSource.visibleStreamCellItem(at: indexPath),
            paths = collectionView.indexPathsForSelectedItems()
        where
            tappedCell is CategoryCardCell && item.type == .SelectableCategoryCard
        {
            let selection = paths.flatMap { dataSource.jsonableForIndexPath($0) as? Category }
            selectedCategoryDelegate?.categoriesSelectionChanged(selection)
        }
    }

    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let tappedCell = collectionView.cellForItemAtIndexPath(indexPath)

        if tappedCell is StreamToggleCell {
            dataSource.toggleCollapsedForIndexPath(indexPath)
            reloadCells(now: true)
        }
        else if tappedCell is UserListItemCell {
            if let user = dataSource.userForIndexPath(indexPath) {
                userTapped(user)
            }
        }
        else if tappedCell is StreamSeeMoreCommentsCell {
            if let lastComment = dataSource.commentForIndexPath(indexPath),
                post = lastComment.loadedFromPost
            {
                postTappedDelegate?.postTapped(post, scrollToComment: lastComment)
            }
        }
        else if let post = dataSource.postForIndexPath(indexPath) {
            postTappedDelegate?.postTapped(post)
        }
        else if let item = dataSource.visibleStreamCellItem(at: indexPath),
            notification = item.jsonable as? Notification,
            postId = notification.postId
        {
            postTappedDelegate?.postTapped(postId: postId)
        }
        else if let item = dataSource.visibleStreamCellItem(at: indexPath),
            notification = item.jsonable as? Notification,
            user = notification.subject as? User
        {
            userTapped(user)
        }
        else if let comment = dataSource.commentForIndexPath(indexPath),
            post = comment.loadedFromPost
        {
            createCommentTapped(post)
        }
        else if let item = dataSource.visibleStreamCellItem(at: indexPath),
            category = dataSource.jsonableForIndexPath(indexPath) as? Category
        {
            if item.type == .SelectableCategoryCard {
                let paths = collectionView.indexPathsForSelectedItems()
                let selection = paths?.flatMap { dataSource.jsonableForIndexPath($0) as? Category }
                selectedCategoryDelegate?.categoriesSelectionChanged(selection ?? [Category]())
            }
            else {
                categoryTapped(category)
            }
        }
        else if let cellItemType = dataSource.visibleStreamCellItem(at: indexPath)?.type
        where cellItemType == .SeeAllCategories {
            seeAllCategoriesTapped()
        }
    }

    public func collectionView(collectionView: UICollectionView,
        shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
            guard let
                cellItemType = dataSource.visibleStreamCellItem(at: indexPath)?.type
            else { return false }

            return cellItemType.selectable
    }
}

// MARK: StreamViewController: UIScrollViewDelegate
extension StreamViewController: UIScrollViewDelegate {

    public func scrollViewDidScroll(scrollView: UIScrollView) {
        streamViewDelegate?.streamViewDidScroll(scrollView)
        if !noResultsLabel.hidden {
            noResultsTopConstraint.constant = -scrollView.contentOffset.y + defaultNoResultsTopConstant
            self.view.layoutIfNeeded()
        }

        if scrollToPaginateGuard {
            self.loadNextPage(scrollView)
        }
    }

    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        scrollToPaginateGuard = true
        streamViewDelegate?.streamViewWillBeginDragging(scrollView)
    }

    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate: Bool) {
        streamViewDelegate?.streamViewDidEndDragging(scrollView, willDecelerate: willDecelerate)
    }

    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        scrollToPaginateGuard = false
    }

    private func loadNextPage(scrollView: UIScrollView) {
        guard
            pagingEnabled &&
            scrollView.contentOffset.y + (self.view.frame.height * 1.666)
            > scrollView.contentSize.height
        else { return }

        guard
            !allOlderPagesLoaded &&
            responseConfig?.totalPagesRemaining != "0"
        else { return }

        guard let
            nextQueryItems = responseConfig?.nextQueryItems
        else { return }

        guard let lastCellItem = dataSource.visibleCellItems.last
            where lastCellItem.type != .StreamLoading
        else { return }

        let placeholderType = lastCellItem.placeholderType
        appendStreamCellItems([StreamCellItem(type: .StreamLoading)])

        scrollToPaginateGuard = false

        let scrollAPI = ElloAPI.InfiniteScroll(queryItems: nextQueryItems) { return self.streamKind.endpoint }
        streamService.loadStream(scrollAPI,
            streamKind: streamKind,
            success: {
                (jsonables, responseConfig) in
                self.scrollLoaded(jsonables, placeholderType: placeholderType)
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

    private func scrollLoaded(jsonables: [JSONAble] = [], placeholderType: StreamCellType.PlaceholderType? = nil) {
        guard
            let lastIndexPath = collectionView.lastIndexPathForSection(0)
        else { return }

        if jsonables.count > 0 {
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

    private func removeLoadingCell() {
        let lastIndexPath = NSIndexPath(forItem: dataSource.visibleCellItems.count - 1, inSection: 0)
        guard
            dataSource.visibleCellItems[lastIndexPath.row].type == .StreamLoading
        else { return }

        dataSource.removeItemsAtIndexPaths([lastIndexPath])
        reloadCells(now: true)
    }
}
