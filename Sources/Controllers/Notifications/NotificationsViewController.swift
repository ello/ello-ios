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

        screen.delegate = self
        title = InterfaceString.Notifications.Title
        elloNavigationItem.rightBarButtonItem = UIBarButtonItem.searchItem(controller: self)

        scrollLogic.navBarHeight = 44

        reload()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if hasNewContent && fromTabBar {
            reload()
        }
        fromTabBar = false

        PushNotificationController.sharedController.updateBadgeNumber(0)
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let jsonables = streamViewController.dataSource.streamCellItems.map { $0.jsonable }
        track(jsonables: jsonables)
    }

    func initialLoad() {
        ElloHUD.showLoadingHudInView(streamViewController.view)
        generator?.load(reload: false)
    }

    func reload() {
        ElloHUD.showLoadingHudInView(streamViewController.view)
        hasNewContent = false

        generator?.streamKind = categoryStreamKind
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
        streamViewController.reloadClosure = { [weak self] in self?.reload() }
    }

    override func showNavBars(_ scrollToBottom: Bool) {
        super.showNavBars(scrollToBottom)
        screen.animateNavigationBar(visible: true)
        updateInsets()

        if scrollToBottom {
            self.scrollToBottom(streamViewController)
        }
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

        streamViewController.streamKind = categoryStreamKind
        streamViewController.hideNoResults()
        streamViewController.removeAllCellItems()

        reload()
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

        reload()
    }

}

private extension NotificationsViewController {

    func addNotificationObservers() {
        navigationNotificationObserver = NotificationObserver(notification: NavigationNotifications.showingNotificationsTab) { [weak self] components in
            guard let sself = self else { return }
            sself.respondToNotification(components)
        }

        reloadNotificationsObserver = NotificationObserver(notification: NewContentNotifications.reloadNotifications) {
            [weak self] _ in
            guard let sself = self else { return }
            if sself.navigationController?.childViewControllers.count == 1 {
                sself.reload()
            }
            else {
                sself.hasNewContent = true
            }
        }

        newAnnouncementsObserver = NotificationObserver(notification: NewContentNotifications.newAnnouncements) {
            [weak self] _ in
            guard let sself = self else { return }
            sself.reloadAnnouncements()
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
        streamViewController.appendUnsizedCellItems(items, withWidth: view.frame.width) { _ in }
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
            Tracker.sharedTracker.announcementViewed(announcement)
        }
    }
}
