////
///  NotificationsViewController.swift
//


public class NotificationsViewController: StreamableViewController, NotificationDelegate, NotificationsScreenDelegate {

    var hasNewContent = false
    var fromTabBar = false
    private var reloadNotificationsObserver: NotificationObserver?
    public var categoryFilterType = NotificationFilterType.All

    override public var tabBarItem: UITabBarItem? {
        get { return UITabBarItem.item(.Bolt) }
        set { self.tabBarItem = newValue }
    }

    override public func loadView() {
        self.view = NotificationsScreen(frame: UIScreen.mainScreen().bounds)
    }

    var screen: NotificationsScreen {
        return self.view as! NotificationsScreen
    }

    var navigationNotificationObserver: NotificationObserver?

    required public override init(nibName: String?, bundle: NSBundle?) {
        super.init(nibName: nibName, bundle: bundle)
        addNotificationObservers()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        navigationNotificationObserver?.removeObserver()
        reloadNotificationsObserver?.removeObserver()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        screen.delegate = self
        self.title = InterfaceString.Notifications.Title
        addSearchButton()

        scrollLogic.prevOffset = streamViewController.collectionView.contentOffset
        scrollLogic.navBarHeight = 44

        reload()
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true

        if hasNewContent && fromTabBar {
            reload()
        }
        fromTabBar = false

        PushNotificationController.sharedController.updateBadgeNumber(0)
    }

    func reload() {
        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.loadInitialPage()
        hasNewContent = false
    }

    override func setupStreamController() {
        super.setupStreamController()

        streamViewController.streamKind = .Notifications(category: categoryFilterType.category)
        streamViewController.notificationDelegate = self
    }

    override public func showNavBars(scrollToBottom: Bool) {
        super.showNavBars(scrollToBottom)
        screen.animateNavigationBar(visible: true)
        updateInsets()

        if scrollToBottom {
            self.scrollToBottom(streamViewController)
        }
    }

    override public func hideNavBars() {
        super.hideNavBars()
        screen.animateNavigationBar(visible: false)
        updateInsets()
    }


    // used to provide StreamableViewController access to the container it then
    // loads the StreamViewController's content into
    override func viewForStream() -> UIView {
        return self.screen.streamContainer
    }

    public func activatedCategory(filterTypeStr: String) {
        let filterType = NotificationFilterType(rawValue: filterTypeStr)!
        activatedCategory(filterType)
    }

    public func activatedCategory(filterType: NotificationFilterType) {
        screen.selectFilterButton(filterType)
        streamViewController.streamKind = .Notifications(category: filterType.category)
        streamViewController.hideNoResults()
        streamViewController.removeAllCellItems()
        reload()
    }

    public func commentTapped(comment: ElloComment) {
        if let post = comment.loadedFromPost {
            postTapped(post)
        }
        else {
            postTapped(postId: comment.postId)
        }
    }

    public func respondToNotification(components: [String]) {
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
            navigationController?.popToRootViewControllerAnimated(true)
        }

        reload()
    }

}

private extension NotificationsViewController {

    func addNotificationObservers() {
        navigationNotificationObserver = NotificationObserver(notification: NavigationNotifications.showingNotificationsTab) { [unowned self] components in
            self.respondToNotification(components)
        }

        reloadNotificationsObserver = NotificationObserver(notification: NewContentNotifications.reloadNotifications) {
            [unowned self] _ in
            if self.navigationController?.childViewControllers.count == 1 {
                self.reload()
            }
            else {
                self.hasNewContent = true
            }
        }
    }

    func updateInsets() {
        updateInsets(navBar: screen.filterBar, streamController: streamViewController)
    }
}
