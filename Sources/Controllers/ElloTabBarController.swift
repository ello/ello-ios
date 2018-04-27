////
///  ElloTabBarController.swift
//

import SwiftyUserDefaults
import PINRemoteImage


class ElloTabBarController: BaseElloViewController, BottomBarController {
    override func trackerName() -> String? { return nil }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return visibleViewController?.preferredStatusBarStyle ?? .default
    }

    let tabBar = ElloTabBar()
    var newNotificationsAvailable: Bool {
        set { notificationsDot?.isVisible = newValue }
        get {
            if let hidden = notificationsDot?.isHidden {
                return !hidden
            }
            return false
        }
    }

    var bottomBarVisible: Bool {
        return _bottomBarVisible
    }
    var bottomBarHeight: CGFloat { return ElloTabBar.Size.height }
    override var navigationBarsVisible: Bool? {
        return bottomBarVisible
    }

    var bottomBarView: UIView {
        return tabBar
    }

    var selectedTab: ElloTab = .defaultTab {
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
            selectedTab = index.flatMap { ElloTab(rawValue: $0) } ?? .defaultTab
        }
    }

    var profileResponseConfig: ResponseConfig?

    var narrationView = NarrationView()
    var isShowingNarration = false
    var shouldShowNarration: Bool {
        get { return !ElloTabBarController.didShowNarration(selectedTab) }
        set { ElloTabBarController.didShowNarration(selectedTab, !newValue) }
    }

    private var systemLoggedOutObserver: NotificationObserver?
    private var streamLoadedObserver: NotificationObserver?
    private var foregroundObserver: NotificationObserver?
    private var backgroundObserver: NotificationObserver?
    private var newNotificationsObserver: NotificationObserver?
    private var newStreamContentObserver: NotificationObserver?

    private var newContentService = NewContentService()
    private var visibleViewController: UIViewController?
    private(set) var notificationsDot: UIView?
    private(set) var homeDot: UIView?

    private var _bottomBarVisible = true
    private(set) var previousTab: ElloTab = .defaultTab
    required init() {
        super.init(nibName: nil, bundle: nil)

        tabBar.tabs = [
            .home,
            .discover,
            .omnibar,
            .notifications,
            .profile,
        ]
        tabBar.selectedTab = .defaultTab
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didSetCurrentUser() {
        super.didSetCurrentUser()

        if let currentUserImage: UIImage = TemporaryCache.load(.avatar) {
            tabBar.resetImages(profile: currentUserImage)
        }
        else if let imageURL = currentUser?.avatar?.large?.url {
            PINRemoteImageManager.shared().downloadImage(with: imageURL, options: [])  { [weak self] result in
                guard let `self` = self else { return }
                nextTick {
                    self.tabBar.resetImages(profile: result.image)
                }
            }
        }
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

extension ElloTabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupControllers()
        view.isOpaque = true
        view.addSubview(tabBar)
        tabBar.delegate = self
        modalTransitionStyle = .crossDissolve

        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissNarrationView))
        narrationView.isUserInteractionEnabled = true
        narrationView.addGestureRecognizer(gesture)

        addDots()
        updateVisibleViewController()
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

    private func positionTabBar() {
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
        let homeController = HomeViewController(usage: .loggedIn)
        homeController.currentUser = currentUser
        let categoriesController = CategoryViewController(currentUser: currentUser)
        let omnibar = OmnibarViewController()
        omnibar.currentUser = currentUser
        omnibar.canGoBack = false
        let notificationsController = NotificationsViewController()
        notificationsController.currentUser = currentUser
        let profileController = ProfileViewController(currentUser: currentUser!)

        self.addChildViewController(embed(homeController))
        self.addChildViewController(embed(categoriesController))
        self.addChildViewController(embed(omnibar))
        self.addChildViewController(embed(notificationsController))
        self.addChildViewController(embed(profileController))
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

    private func setupNotificationObservers() {

        _ = Application.shared() // this is lame but we need Application to initialize to observe it's notifications

        systemLoggedOutObserver = NotificationObserver(notification: AuthenticationNotifications.invalidToken) { [weak self] _ in
            self?.systemLoggedOut()
        }

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
            self?.homeDot?.isVisible = true
        }

    }

    private func removeNotificationObservers() {
        systemLoggedOutObserver?.removeObserver()
        streamLoadedObserver?.removeObserver()
        newNotificationsObserver?.removeObserver()
        backgroundObserver?.removeObserver()
        foregroundObserver?.removeObserver()
        newStreamContentObserver?.removeObserver()
    }

}

extension ElloTabBarController {

    func systemLoggedOut() {
        appViewController?.forceLogOut()
    }
}

extension ElloTabBarController: ElloTabBarDelegate {

    func tabBar(_ tabBar: ElloTabBar, didSelect item: ElloTab) {
        guard
            let index = tabBar.tabs.index(of: item)
        else { return }

        if index == selectedTab.rawValue {
            if let navigationViewController = selectedViewController as? UINavigationController,
                navigationViewController.childViewControllers.count > 1
            {
                let pop: Block = { _ = navigationViewController.popToRootViewController(animated: true) }
                if let viewController = navigationViewController.visibleViewController as? BaseElloViewController {
                    viewController.goingBackNow(proceed: pop)
                }
                else {
                    pop()
                }
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
            selectedTab = ElloTab(rawValue: index) ?? .home
        }

        if selectedTab == .notifications,
            let navigationViewController = selectedViewController as? UINavigationController,
            let notificationsViewController = navigationViewController.childViewControllers[0] as? NotificationsViewController
        {
            notificationsViewController.fromTabBar = true
        }
    }

    func findScrollView(_ view: UIView) -> UIScrollView? {
        if let found = view as? UIScrollView,
            found.scrollsToTop
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

    func shouldReloadFollowingStream() -> Bool {
        return selectedTab == .home && homeDot?.isHidden == false
    }

    func shouldReloadNotificationsStream() -> Bool {
        if let navigationController = selectedViewController as? UINavigationController, navigationController.childViewControllers.count == 1 {
            return selectedTab == .notifications && newNotificationsAvailable
        }
        return false
    }

    func updateVisibleViewController() {
        let currentViewController: UIViewController? = visibleViewController
        let nextViewController = selectedViewController

        nextTick {
            if let currentViewController = currentViewController,
                currentViewController != nextViewController,
                currentViewController.parent == self
            {
                self.transitionControllers(currentViewController, nextViewController)
            }
            else {
                self.showViewController(nextViewController)
                self.prepareNarration()
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
        tabBar.selectedTab = selectedTab
        showViewController.view.frame = tabBar.frame.fromBottom().grow(up: view.frame.height - tabBar.frame.height)
        showViewController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        showViewController.view.layoutIfNeeded()
        view.insertSubview(showViewController.view, belowSubview: tabBar)
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

    private func addDots() {
        notificationsDot = tabBar.addRedDotFor(tab: .notifications)
        homeDot = tabBar.addRedDotFor(tab: .home)
    }

    private func prepareNarration() {
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

    @objc
    func dismissNarrationView() {
        shouldShowNarration = false
        animateOutNarrationView()
    }

    private func updateNarrationTitle(_ animated: Bool = true) {
        animate(options: [.curveEaseOut, .beginFromCurrentState], animated: animated) {
            if let rect = self.tabBar.buttonFrames.safeValue(self.selectedTab.rawValue) {
                self.narrationView.pointerX = rect.midX
            }
        }
        narrationView.title = selectedTab.narrationTitle
        narrationView.text = selectedTab.narrationText
    }

    private func animateInStartFrame() -> CGRect {
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

    private func animateInFinalFrame() -> CGRect {
        let narrationHeight = NarrationView.Size.height
        let bottomMargin = ElloTabBar.Size.height - NarrationView.Size.pointer.height
        return CGRect(
            x: 0,
            y: view.frame.height - bottomMargin - narrationHeight,
            width: view.frame.width,
            height: narrationHeight
            )
    }

    private func animateInNarrationView() {
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

    private func animateOutNarrationView() {
        animate {
            self.narrationView.alpha = 0
            self.narrationView.frame = self.animateInStartFrame()
        }
        isShowingNarration = false
    }

}
