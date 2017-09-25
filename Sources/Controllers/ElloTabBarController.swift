////
///  ElloTabBarController.swift
//

import SwiftyUserDefaults

enum ElloTab: Int {
    case home
    case discover
    case omnibar
    case notifications
    case profile

    static let DefaultTab: ElloTab = .home
    static let ToolTipsResetForTwoPointOhKey = "ToolTipsResetForTwoPointOhKey"

    static func resetToolTips() {
        GroupDefaults[ElloTab.home.narrationDefaultKey] = nil
        GroupDefaults[ElloTab.discover.narrationDefaultKey] = nil
        GroupDefaults[ElloTab.notifications.narrationDefaultKey] = nil
        GroupDefaults[ElloTab.profile.narrationDefaultKey] = nil
        GroupDefaults[ElloTab.omnibar.narrationDefaultKey] = nil
    }

    var pointerXoffset: CGFloat {
        switch self {
            case .discover:      return -8
            case .notifications: return 8
            default: return 0
        }
    }

    var insets: UIEdgeInsets {
        switch self {
            case .discover:      return UIEdgeInsets(top: 6, left: -8, bottom: -6, right: 8)
            case .notifications: return UIEdgeInsets(top: 5, left: 8, bottom: -5, right: -8)
            default:             return UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        }
    }

    var redDotMargins: CGPoint {
        switch self {
        case .notifications: return CGPoint(x: 8, y: 9)
        default:             return CGPoint(x: 0, y: 9)
        }
    }

    var narrationDefaultKey: String {
        let defaultPrefix = "ElloTabBarControllerDidShowNarration"
        switch self {
            case .home:     return "\(defaultPrefix)Stream"
            case .discover:      return "\(defaultPrefix)Discover"
            case .omnibar:       return "\(defaultPrefix)Omnibar"
            case .notifications: return "\(defaultPrefix)Notifications"
            case .profile:       return "\(defaultPrefix)Profile"
        }
    }

    var narrationTitle: String {
        switch self {
            case .home:     return InterfaceString.Tab.PopupTitle.Following
            case .discover:      return InterfaceString.Tab.PopupTitle.Discover
            case .omnibar:       return InterfaceString.Tab.PopupTitle.Omnibar
            case .notifications: return InterfaceString.Tab.PopupTitle.Notifications
            case .profile:       return InterfaceString.Tab.PopupTitle.Profile
        }
    }

    var narrationText: String {
        switch self {
            case .home:     return InterfaceString.Tab.PopupText.Following
            case .discover:      return InterfaceString.Tab.PopupText.Discover
            case .omnibar:       return InterfaceString.Tab.PopupText.Omnibar
            case .notifications: return InterfaceString.Tab.PopupText.Notifications
            case .profile:       return InterfaceString.Tab.PopupText.Profile
        }
    }

}

class ElloTabBarController: UIViewController, HasAppController, ControllerThatMightHaveTheCurrentUser, BottomBarController {
    override func trackerName() -> String? { return nil }

    let tabBar = ElloTabBar()
    fileprivate var systemLoggedOutObserver: NotificationObserver?
    fileprivate var streamLoadedObserver: NotificationObserver?

    fileprivate var newContentService = NewContentService()
    fileprivate var foregroundObserver: NotificationObserver?
    fileprivate var backgroundObserver: NotificationObserver?
    fileprivate var newNotificationsObserver: NotificationObserver?
    fileprivate var newStreamContentObserver: NotificationObserver?

    fileprivate var visibleViewController = UIViewController()

    var appViewController: AppViewController? {
        return findViewController { vc in vc is AppViewController } as? AppViewController
    }

    fileprivate(set) var notificationsDot: UIView?
    var newNotificationsAvailable: Bool {
        set { notificationsDot?.isHidden = !newValue }
        get {
            if let hidden = notificationsDot?.isHidden {
                return !hidden
            }
            return false
        }
    }
    fileprivate(set) var homeDot: UIView?

    // MARK: BottomBarController
    fileprivate var _bottomBarVisible = true
    var bottomBarVisible: Bool {
        return _bottomBarVisible
    }
    var bottomBarHeight: CGFloat { return ElloTabBar.Size.height }
    var navigationBarsVisible: Bool? {
        return bottomBarVisible
    }

    var bottomBarView: UIView {
        return tabBar
    }

    fileprivate(set) var previousTab: ElloTab = .DefaultTab
    var selectedTab: ElloTab = .DefaultTab {
        willSet {
            if selectedTab != previousTab {
                previousTab = selectedTab
            }
        }
        didSet {
            updateVisibleViewController()
        }
    }

    var selectedViewController: UIViewController {
        get { return childViewControllers[selectedTab.rawValue] }
        set(controller) {
            let index = (childViewControllers ).index(of: controller)
            selectedTab = index.flatMap { ElloTab(rawValue: $0) } ?? .DefaultTab
        }
    }

    var currentUser: User? {
        didSet { didSetCurrentUser() }
    }
    var profileResponseConfig: ResponseConfig?

    var narrationView = NarrationView()
    var isShowingNarration = false
    var shouldShowNarration: Bool {
        get { return !ElloTabBarController.didShowNarration(selectedTab) }
        set { ElloTabBarController.didShowNarration(selectedTab, !newValue) }
    }

    required init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ElloTabBarController {

    class func didShowNarration(_ tab: ElloTab) -> Bool {
        return GroupDefaults[tab.narrationDefaultKey].bool ?? false
    }

    class func didShowNarration(_ tab: ElloTab, _ value: Bool) {
        GroupDefaults[tab.narrationDefaultKey] = value
    }

}

// MARK: View Lifecycle
extension ElloTabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        resetToolTipsForTwoPointOh()
        setupControllers()
        view.isOpaque = true
        view.addSubview(tabBar)
        tabBar.delegate = self
        modalTransitionStyle = .crossDissolve

        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissNarrationView))
        narrationView.isUserInteractionEnabled = true
        narrationView.addGestureRecognizer(gesture)

        updateTabBarItems()
        updateVisibleViewController()
        addDots()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateNarrationTitle(animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        positionTabBar()
        selectedViewController.view.frame = view.bounds
    }

    fileprivate func positionTabBar() {
        let upAmount: CGFloat
        if bottomBarVisible || isShowingNarration {
            upAmount = ElloTabBar.Size.height
        }
        else {
            upAmount = 0
        }
        tabBar.frame = view.bounds.fromBottom().with(height: ElloTabBar.Size.height).shift(up: upAmount)
    }

    func setNavigationBarsVisible(_ visible: Bool, animated: Bool) {
        guard _bottomBarVisible != visible else { return }

        _bottomBarVisible = visible
        postNotification(StatusBarNotifications.statusBarVisibility, value: visible)

        animate(animated: animated) {
            self.positionTabBar()
        }
    }

    func setupControllers() {
        let home = HomeViewController(usage: .loggedIn)
        let discover = CategoryViewController(slug: Category.featured.slug, name: Category.featured.name)
        discover.category = Category.featured
        let omnibar = OmnibarViewController()
        let notifications = NotificationsViewController()
        let profile = ProfileViewController(currentUser: currentUser!)
        omnibar.canGoBack = false

        self.addChildViewController(embed(home))
        self.addChildViewController(embed(discover))
        self.addChildViewController(embed(omnibar))
        self.addChildViewController(embed(notifications))
        self.addChildViewController(embed(profile))
    }

    func embed(_ controller: UIViewController) -> UIViewController {
        let nav = ElloNavigationController(rootViewController: controller)
        nav.currentUser = currentUser
        return nav
    }
}

// listen for system logged out event
extension ElloTabBarController {

    func activateTabBar() {
        setupNotificationObservers()
        newContentService.startPolling()
    }

    func deactivateTabBar() {
        removeNotificationObservers()
        newContentService.stopPolling()
    }

    fileprivate func setupNotificationObservers() {

        _ = Application.shared() // this is lame but we need Application to initialize to observe it's notifications

        systemLoggedOutObserver = NotificationObserver(notification: AuthenticationNotifications.invalidToken, block: systemLoggedOut)

        streamLoadedObserver = NotificationObserver(notification: StreamLoadedNotifications.streamLoaded) { [weak self] streamKind in
            switch streamKind {
            case .notifications(category: nil):
                self?.newNotificationsAvailable = false
            case .following:
                self?.homeDot?.isHidden = true
            default: break
            }
        }

        foregroundObserver = NotificationObserver(notification: Application.Notifications.WillEnterForeground) { [weak self] _ in
            self?.newContentService.startPolling()
        }

        backgroundObserver = NotificationObserver(notification: Application.Notifications.DidEnterBackground) { [weak self] _ in
            self?.newContentService.stopPolling()
        }

        newNotificationsObserver = NotificationObserver(notification: NewContentNotifications.newNotifications) { [weak self] in
            self?.newNotificationsAvailable = true
        }

        newStreamContentObserver = NotificationObserver(notification: NewContentNotifications.newFollowingContent) { [weak self] in
            self?.homeDot?.isHidden = false
        }

    }

    fileprivate func removeNotificationObservers() {
        systemLoggedOutObserver?.removeObserver()
        streamLoadedObserver?.removeObserver()
        newNotificationsObserver?.removeObserver()
        backgroundObserver?.removeObserver()
        foregroundObserver?.removeObserver()
        newStreamContentObserver?.removeObserver()
    }

}

extension ElloTabBarController {

    func didSetCurrentUser() {
        for controller in childViewControllers {
            guard let controller = controller as? ControllerThatMightHaveTheCurrentUser else { return }
            controller.currentUser = currentUser
        }
    }

    func systemLoggedOut(_ shouldAlert: Bool) {
        appViewController?.forceLogOut(shouldAlert)
    }
}

// UITabBarDelegate
extension ElloTabBarController: UITabBarDelegate {

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard
            let items = tabBar.items,
            let index = items.index(of: item)
        else { return }

        if index == selectedTab.rawValue {
            if let navigationViewController = selectedViewController as? UINavigationController, navigationViewController.childViewControllers.count > 1
            {
                _ = navigationViewController.popToRootViewController(animated: true)
            }
            else {
                if let scrollView = findScrollView(selectedViewController.view) {
                    scrollView.setContentOffset(CGPoint(x: 0, y: -scrollView.contentInset.top), animated: true)
                }

                if shouldReloadFollowingStream() {
                    postNotification(NewContentNotifications.reloadFollowingContent, value: ())
                }
                else if shouldReloadNotificationsStream() {
                    postNotification(NewContentNotifications.reloadNotifications, value: ())
                    self.newNotificationsAvailable = false
                }
            }
        }
        else {
            selectedTab = ElloTab(rawValue:index) ?? .home
        }

        if selectedTab == .notifications {
            if let navigationViewController = selectedViewController as? UINavigationController,
                let notificationsViewController = navigationViewController.childViewControllers[0] as? NotificationsViewController {
                notificationsViewController.fromTabBar = true
            }
        }
    }

    func findScrollView(_ view: UIView) -> UIScrollView? {
        if let found = view as? UIScrollView, found.scrollsToTop
        {
            return found
        }

        for subview in view.subviews {
            if let found = findScrollView(subview) {
                return found
            }
        }

        return nil
    }
}

// MARK: Child View Controller handling
extension ElloTabBarController {

    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize size: CGSize) -> CGSize {
        return view.frame.size
    }
}

private extension ElloTabBarController {

    func resetToolTipsForTwoPointOh() {
        guard GroupDefaults[ElloTab.ToolTipsResetForTwoPointOhKey].bool == nil else { return }
        GroupDefaults[ElloTab.ToolTipsResetForTwoPointOhKey] = true

        ElloTab.resetToolTips()
    }

    func shouldReloadFollowingStream() -> Bool {
        return selectedTab == .home && homeDot?.isHidden == false
    }

    func shouldReloadNotificationsStream() -> Bool {
        if let navigationController = selectedViewController as? UINavigationController, navigationController.childViewControllers.count == 1 {
            return selectedTab == .notifications && newNotificationsAvailable
        }
        return false
    }

    func updateTabBarItems() {
        let controllers = childViewControllers
        tabBar.items = controllers.map { controller in
            let tabBarItem = controller.tabBarItem
            if tabBarItem?.selectedImage != nil && tabBarItem?.selectedImage?.renderingMode != .alwaysOriginal {
                tabBarItem?.selectedImage = tabBarItem?.selectedImage?.withRenderingMode(.alwaysOriginal)
            }
            return tabBarItem!
        }
    }

    func updateVisibleViewController() {
        let currentViewController = visibleViewController
        let nextViewController = selectedViewController

        nextTick {
            if currentViewController.parent != self {
                self.showViewController(nextViewController)
                self.prepareNarration()
            }
            else if currentViewController != nextViewController {
                self.transitionControllers(currentViewController, nextViewController)
            }
        }

        visibleViewController = nextViewController
    }

    func hideViewController(_ hideViewController: UIViewController) {
        if hideViewController.parent == self {
            hideViewController.view.removeFromSuperview()
        }
    }

    func showViewController(_ showViewController: UIViewController) {
        tabBar.selectedItem = tabBar.items?[selectedTab.rawValue]
        view.insertSubview(showViewController.view, belowSubview: tabBar)
        showViewController.view.frame = tabBar.frame.fromBottom().grow(up: view.frame.height - tabBar.frame.height)
        showViewController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

    func transitionControllers(_ hideViewController: UIViewController, _ showViewController: UIViewController) {
        transitionControllers(from: hideViewController,
            to: showViewController,
            animations: {
                self.hideViewController(hideViewController)
                self.showViewController(showViewController)
            },
            completion: { _ in
                self.prepareNarration()
            })
    }

}

extension ElloTabBarController {

    fileprivate func addDots() {
        notificationsDot = tabBar.addRedDotFor(tab: .notifications)
        homeDot = tabBar.addRedDotFor(tab: .home)
    }

    fileprivate func prepareNarration() {
        if shouldShowNarration {
            if !isShowingNarration {
                animateInNarrationView()
            }
            updateNarrationTitle()
        }
        else if isShowingNarration {
            animateOutNarrationView()
        }
    }

    func dismissNarrationView() {
        shouldShowNarration = false
        animateOutNarrationView()
    }

    fileprivate func updateNarrationTitle(_ animated: Bool = true) {
        animate(options: [.curveEaseOut, .beginFromCurrentState], animated: animated) {
            if let rect = self.tabBar.itemPositionsIn(self.narrationView).safeValue(self.selectedTab.rawValue) {
                self.narrationView.pointerX = rect.midX + self.selectedTab.pointerXoffset
            }
        }
        narrationView.title = selectedTab.narrationTitle
        narrationView.text = selectedTab.narrationText
    }

    fileprivate func animateInStartFrame() -> CGRect {
        let upAmount = CGFloat(20)
        let narrationHeight = NarrationView.Size.height
        let bottomMargin = ElloTabBar.Size.height - NarrationView.Size.pointer.height
        return CGRect(
            x: 0,
            y: view.frame.height - bottomMargin - narrationHeight - upAmount,
            width: view.frame.width,
            height: narrationHeight
            )
    }

    fileprivate func animateInFinalFrame() -> CGRect {
        let narrationHeight = NarrationView.Size.height
        let bottomMargin = ElloTabBar.Size.height - NarrationView.Size.pointer.height
        return CGRect(
            x: 0,
            y: view.frame.height - bottomMargin - narrationHeight,
            width: view.frame.width,
            height: narrationHeight
            )
    }

    fileprivate func animateInNarrationView() {
        narrationView.alpha = 0
        narrationView.frame = animateInStartFrame()
        view.addSubview(narrationView)
        updateNarrationTitle(false)
        animate {
            self.narrationView.alpha = 1
            self.narrationView.frame = self.animateInFinalFrame()
        }
        isShowingNarration = true
    }

    fileprivate func animateOutNarrationView() {
        animate {
            self.narrationView.alpha = 0
            self.narrationView.frame = self.animateInStartFrame()
        }
        isShowingNarration = false
    }

}
