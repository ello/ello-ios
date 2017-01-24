////
///  NotificationsViewController.swift
//


class NotificationsViewController: StreamableViewController, NotificationDelegate, NotificationsScreenDelegate {
    override func trackerName() -> String? { return "Notifications" }
    override func trackerProps() -> [String: AnyObject]? {
        if let category = categoryFilterType.category {
            return ["filter": category as AnyObject]
        }
        return nil
    }

    var generator: NotificationsGenerator?
    var hasNewContent = false
    var fromTabBar = false
    fileprivate var reloadNotificationsObserver: NotificationObserver?
    fileprivate var newAnnouncementsObserver: NotificationObserver?
    var categoryFilterType = NotificationFilterType.all
    var categoryStreamKind: StreamKind { return .notifications(category: categoryFilterType.category) }

    override var tabBarItem: UITabBarItem? {
        get { return UITabBarItem.item(.bolt) }
        set { self.tabBarItem = newValue }
    }

    override func loadView() {
        self.view = NotificationsScreen(frame: UIScreen.main.bounds)
    }

    var screen: NotificationsScreen {
        return self.view as! NotificationsScreen
    }

    var navigationNotificationObserver: NotificationObserver?

    init() {
        super.init(nibName: nil, bundle: nil)
        addNotificationObservers()

        generator = NotificationsGenerator(
            currentUser: currentUser,
            streamKind: categoryStreamKind,
            destination: self
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        navigationNotificationObserver?.removeObserver()
        reloadNotificationsObserver?.removeObserver()
        newAnnouncementsObserver?.removeObserver()
    }

    override func didSetCurrentUser() {
        generator?.currentUser = currentUser
        super.didSetCurrentUser()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false

        screen.delegate = self
        title = InterfaceString.Notifications.Title
        elloNavigationItem.rightBarButtonItem = UIBarButtonItem.searchItem(controller: self)

        scrollLogic.navBarHeight = 44

        initialLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if hasNewContent && fromTabBar {
            reload(showSpinner: true)
        }
        fromTabBar = false

        PushNotificationController.sharedController.updateBadgeNumber(0)
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let jsonables = streamViewController.dataSource.streamCellItems.map { $0.jsonable }
        track(jsonables: jsonables)
    }

    func initialLoad() {
        ElloHUD.showLoadingHudInView(streamViewController.view)
        generator?.load(reload: false)
    }

    func reload(showSpinner: Bool) {
        hasNewContent = false
        if showSpinner {
            ElloHUD.showLoadingHudInView(streamViewController.view)
        }

        generator?.load(reload: true)
        Tracker.shared.screenAppeared(self)
    }

    func reloadAnnouncements() {
        generator?.reloadAnnouncements()
    }

    override func setupStreamController() {
        super.setupStreamController()

        streamViewController.streamKind = categoryStreamKind
        streamViewController.announcementDelegate = self
        streamViewController.notificationDelegate = self
        streamViewController.initialLoadClosure = { [weak self] in self?.initialLoad() }
        streamViewController.reloadClosure = { [weak self] in self?.reload(showSpinner: false) }
    }

    override func showNavBars() {
        super.showNavBars()
        screen.animateNavigationBar(visible: true)
        updateInsets()
    }

    override func hideNavBars() {
        super.hideNavBars()
        screen.animateNavigationBar(visible: false)
        updateInsets()
    }

    // used to provide StreamableViewController access to the container it then
    // loads the StreamViewController's content into
    override func viewForStream() -> UIView {
        return self.screen.streamContainer
    }

    func activatedCategory(_ filterTypeStr: String) {
        let filterType = NotificationFilterType(rawValue: filterTypeStr)!
        activatedCategory(filterType)
    }

    func activatedCategory(_ filterType: NotificationFilterType) {
        screen.selectFilterButton(filterType)
        categoryFilterType = filterType

        generator?.streamKind = categoryStreamKind
        streamViewController.streamKind = categoryStreamKind
        streamViewController.hideNoResults()
        streamViewController.removeAllCellItems()
        streamViewController.loadInitialPage()

        Tracker.shared.screenAppeared(self)
    }

    func commentTapped(_ comment: ElloComment) {
        if let post = comment.loadedFromPost {
            postTapped(post)
        }
        else {
            postTapped(postId: comment.postId)
        }
    }

    func respondToNotification(_ components: [String]) {
        var popToRoot: Bool = true
        if let path = components.safeValue(0) {
            switch path {
            case "posts":
                if let id = components.safeValue(1) {
                    popToRoot = false
                    postTapped(postId: id)
                }
            case "users":
                if let id = components.safeValue(1) {
                    popToRoot = false
                    userParamTapped(id, username: nil)
                }
            default:
                break
            }
        }

        if popToRoot {
            _ = navigationController?.popToRootViewController(animated: true)
        }

        reload(showSpinner: true)
    }

}

private extension NotificationsViewController {

    func addNotificationObservers() {
        navigationNotificationObserver = NotificationObserver(notification: NavigationNotifications.showingNotificationsTab) { [weak self] components in
            guard let `self` = self else { return }
            self.respondToNotification(components)
        }

        reloadNotificationsObserver = NotificationObserver(notification: NewContentNotifications.reloadNotifications) {
            [weak self] _ in
            guard let `self` = self else { return }
            if self.navigationController?.childViewControllers.count == 1 {
                self.reload(showSpinner: true)
            }
            else {
                self.hasNewContent = true
            }
        }

        newAnnouncementsObserver = NotificationObserver(notification: NewContentNotifications.newAnnouncements) {
            [weak self] _ in
            guard let `self` = self else { return }
            self.reloadAnnouncements()
        }
    }

    func updateInsets() {
        updateInsets(navBar: screen.filterBar, streamController: streamViewController)
    }
}

// MARK: NotificationsViewController: StreamDestination
extension NotificationsViewController: StreamDestination {

    var pagingEnabled: Bool {
        get { return streamViewController.pagingEnabled }
        set { streamViewController.pagingEnabled = newValue }
    }

    func replacePlaceholder(type: StreamCellType.PlaceholderType, items: [StreamCellItem], completion: @escaping ElloEmptyCompletion) {
        if type == .announcements {
            let jsonables = items.map { $0.jsonable }
            track(jsonables: jsonables)
        }

        streamViewController.replacePlaceholder(type, with: items, completion: completion)
    }

    func setPlaceholders(items: [StreamCellItem]) {
        streamViewController.clearForInitialLoad()
        streamViewController.appendStreamCellItems(items)
    }

    func setPrimary(jsonable: JSONAble) {
        self.streamViewController.doneLoading()
    }

    func setPagingConfig(responseConfig: ResponseConfig) {
        streamViewController.responseConfig = responseConfig
    }

    func primaryJSONAbleNotFound() {
        self.streamViewController.doneLoading()
    }
}

// MARK: NotificationsViewController: AnnouncementDelegate
extension NotificationsViewController: AnnouncementDelegate {
    func markAnnouncementAsRead(announcement: Announcement) {
        Tracker.shared.announcementDismissed(announcement)
        generator?.markAnnouncementAsRead(announcement)
        postNotification(JSONAbleChangedNotification, value: (announcement, .delete))
    }

    public func track(jsonables: [JSONAble]) {
        let announcements: [Announcement] = jsonables.flatMap { $0 as? Announcement }
        for announcement in announcements {
            Tracker.shared.announcementViewed(announcement)
        }
    }
}
