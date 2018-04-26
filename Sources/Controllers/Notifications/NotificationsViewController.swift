////
///  NotificationsViewController.swift
//


class NotificationsViewController: StreamableViewController, NotificationsScreenDelegate {
    override func trackerName() -> String? { return "Notifications" }
    override func trackerProps() -> [String: Any]? {
        if let category = categoryFilterType.category {
            return ["filter": category]
        }
        return nil
    }

    var generator: NotificationsGenerator?
    var hasNewContent = false
    var fromTabBar = false
    private var reloadNotificationsObserver: NotificationObserver?
    private var newAnnouncementsObserver: NotificationObserver?
    var categoryFilterType = NotificationFilterType.all
    var categoryStreamKind: StreamKind { return .notifications(category: categoryFilterType.category) }

    override func loadView() {
        self.view = NotificationsScreen(frame: UIScreen.main.bounds)
    }

    private var _mockScreen: NotificationsScreenProtocol?
    var screen: NotificationsScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return fetchScreen(_mockScreen) }
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        addNotificationObservers()

        generator = NotificationsGenerator(
            currentUser: currentUser,
            streamKind: categoryStreamKind,
            destination: self
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        reloadNotificationsObserver?.removeObserver()
        newAnnouncementsObserver?.removeObserver()
    }

    override func didSetCurrentUser() {
        super.didSetCurrentUser()
        generator?.currentUser = currentUser
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false

        screen.delegate = self
        title = InterfaceString.Notifications.Title

        initialLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if hasNewContent && fromTabBar {
            reload(showSpinner: true)
        }
        fromTabBar = false

        PushNotificationController.shared.updateBadgeNumber(0)
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let jsonables = streamViewController.collectionViewDataSource.visibleCellItems.map { $0.jsonable }
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
    }

    func reloadAnnouncements() {
        generator?.reloadAnnouncements()
    }

    override func setupStreamController() {
        super.setupStreamController()

        streamViewController.streamKind = categoryStreamKind
        streamViewController.initialLoadClosure = { [weak self] in self?.initialLoad() }
        streamViewController.reloadClosure = { [weak self] in self?.reload(showSpinner: false) }
    }

    override func showNavBars(animated: Bool) {
        super.showNavBars(animated: animated)
        screen.navBarVisible = true
        positionNavBar(screen.filterBar, visible: true, animated: animated)
        updateInsets()
    }

    override func hideNavBars(animated: Bool) {
        super.hideNavBars(animated: animated)
        screen.navBarVisible = false
        positionNavBar(screen.filterBar, visible: false, animated: animated)
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
        streamViewController.removeAllCellItems()
        streamViewController.loadInitialPage()

        trackScreenAppeared()
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

extension NotificationsViewController: NotificationResponder {
    func commentTapped(_ comment: ElloComment) {
        if let post = comment.loadedFromPost {
            postTapped(post)
        }
        else {
            postTapped(postId: comment.postId)
        }
    }

    func artistInviteTapped(_ artistInvite: ArtistInvite) {
        let vc = ArtistInviteDetailController(artistInvite: artistInvite)
        vc.currentUser = currentUser
        navigationController?.pushViewController(vc, animated: true)
    }


    // userTapped(_ user: _) defined in StreamableViewController
    // postTapped(_ post: _) defined in StreamableViewController
}

private extension NotificationsViewController {

    func addNotificationObservers() {
        reloadNotificationsObserver = NotificationObserver(notification: NewContentNotifications.reloadNotifications) { [weak self] in
            guard let `self` = self else { return }
            if self.navigationController?.childViewControllers.count == 1 {
                self.reload(showSpinner: true)
            }
            else {
                self.hasNewContent = true
            }
        }

        newAnnouncementsObserver = NotificationObserver(notification: NewContentNotifications.newAnnouncements) { [weak self] in
            guard let `self` = self else { return }
            self.reloadAnnouncements()
        }
    }

    func updateInsets() {
        updateInsets(navBar: screen.filterBar)
    }
}

extension NotificationsViewController: StreamDestination {

    var isPagingEnabled: Bool {
        get { return streamViewController.isPagingEnabled }
        set { streamViewController.isPagingEnabled = newValue }
    }

    func replacePlaceholder(type: StreamCellType.PlaceholderType, items: [StreamCellItem], completion: @escaping Block) {
        if type == .announcements {
            let jsonables = items.map { $0.jsonable }
            track(jsonables: jsonables)
        }
        else if type == .notifications {
            streamViewController.doneLoading()
        }

        streamViewController.replacePlaceholder(type: type, items: items, completion: completion)
    }

    func setPlaceholders(items: [StreamCellItem]) {
        streamViewController.clearForInitialLoad(newItems: items)
    }

    func setPrimary(jsonable: Model) {
    }

    func setPagingConfig(responseConfig: ResponseConfig) {
        streamViewController.responseConfig = responseConfig
    }

    func primaryModelNotFound() {
        self.streamViewController.doneLoading()
    }
}

extension NotificationsViewController: AnnouncementResponder {
    func markAnnouncementAsRead(announcement: Announcement) {
        Tracker.shared.announcementDismissed(announcement)
        generator?.markAnnouncementAsRead(announcement)
        postNotification(ModelChangedNotification, value: (announcement, .delete))
    }

    public func track(jsonables: [Model]) {
        let announcements: [Announcement] = jsonables.compactMap { $0 as? Announcement }
        for announcement in announcements {
            Tracker.shared.announcementViewed(announcement)
        }
    }
}
