////
///  ElloTabBarController.swift
//

import SwiftyUserDefaults

enum ElloTab: Int {
    case discover
    case notifications
    case stream
    case profile
    case omnibar

    static let DefaultTab = ElloTab.stream

    var narrationDefaultKey: String {
        let defaultPrefix = "ElloTabBarControllerDidShowNarration"
        switch self {
        case .discover:      return "\(defaultPrefix)Discover"
        case .notifications: return "\(defaultPrefix)Notifications"
        case .stream:        return "\(defaultPrefix)Stream"
        case .profile:       return "\(defaultPrefix)Profile"
        case .omnibar:       return "\(defaultPrefix)Omnibar"
        }
    }

    var narrationTitle: String {
        switch self {
            case .discover:      return InterfaceString.Tab.PopupTitle.Discover
            case .notifications: return InterfaceString.Tab.PopupTitle.Notifications
            case .stream:        return InterfaceString.Tab.PopupTitle.Stream
            case .profile:       return InterfaceString.Tab.PopupTitle.Profile
            case .omnibar:       return InterfaceString.Tab.PopupTitle.Omnibar
        }
    }

    var narrationText: String {
        switch self {
            case .discover:      return InterfaceString.Tab.PopupText.Discover
            case .notifications: return InterfaceString.Tab.PopupText.Notifications
            case .stream:        return InterfaceString.Tab.PopupText.Stream
            case .profile:       return InterfaceString.Tab.PopupText.Profile
            case .omnibar:       return InterfaceString.Tab.PopupText.Omnibar
        }
    }

}

class ElloTabBarController: UIViewController, HasAppController, ControllerThatMightHaveTheCurrentUser {
    let tabBar = ElloTabBar()
    fileprivate var systemLoggedOutObserver: NotificationObserver?
    fileprivate var streamLoadedObserver: NotificationObserver?

    fileprivate var newContentService = NewContentService()
    fileprivate var foregroundObserver: NotificationObserver?
    fileprivate var backgroundObserver: NotificationObserver?
    fileprivate var newNotificationsObserver: NotificationObserver?
    fileprivate var newStreamContentObserver: NotificationObserver?

    fileprivate var visibleViewController = UIViewController()
    var parentAppController: AppViewController?

    fileprivate var notificationsDot: UIView?
    var newNotificationsAvailable: Bool {
        set { notificationsDot?.isHidden = !newValue }
        get {
            if let hidden = notificationsDot?.isHidden {
                return !hidden
            }
            return false
        }
    }
    fileprivate(set) var streamsDot: UIView?

    fileprivate var _tabBarHidden = false
    var tabBarHidden: Bool {
        get { return _tabBarHidden }
        set { setTabBarHidden(newValue, animated: false) }
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
    class func instantiateFromStoryboard() -> ElloTabBarController {
        return UIStoryboard.storyboardWithId(.elloTabBar) as! ElloTabBarController
    }
}

// MARK: View Lifecycle
extension ElloTabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
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
        var upAmount = CGFloat(0)
        if !tabBarHidden || isShowingNarration {
            upAmount = tabBar.frame.height
        }
        tabBar.frame = view.bounds.fromBottom().with(height: tabBar.frame.height).shift(up: upAmount)
    }

    func setTabBarHidden(_ hidden: Bool, animated: Bool) {
        _tabBarHidden = hidden

        animate(animated: animated) {
            self.positionTabBar()
        }
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

        let _ = Application.shared() // this is lame but we need Application to initialize to observe it's notifications

        systemLoggedOutObserver = NotificationObserver(notification: AuthenticationNotifications.invalidToken, block: systemLoggedOut)

        streamLoadedObserver = NotificationObserver(notification: StreamLoadedNotifications.streamLoaded) {
            [unowned self] streamKind in
            switch streamKind {
            case .notifications(category: nil):
                self.newNotificationsAvailable = false
            case .following:
                self.streamsDot?.isHidden = true
            default: break
            }
        }

        foregroundObserver = NotificationObserver(notification: Application.Notifications.WillEnterForeground) {
            [unowned self] _ in
            self.newContentService.startPolling()
        }

        backgroundObserver = NotificationObserver(notification: Application.Notifications.DidEnterBackground) {
            [unowned self] _ in
            self.newContentService.stopPolling()
        }

        newNotificationsObserver = NotificationObserver(notification: NewContentNotifications.newNotifications) {
            [unowned self] _ in
            self.newNotificationsAvailable = true
        }

        newStreamContentObserver = NotificationObserver(notification: NewContentNotifications.newStreamContent) {
            [unowned self] _ in
            self.streamsDot?.isHidden = false
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
            if let controller = controller as? ControllerThatMightHaveTheCurrentUser {
                controller.currentUser = currentUser
            }
        }
    }

    func systemLoggedOut(_ shouldAlert: Bool) {
        parentAppController?.forceLogOut(shouldAlert)
    }
}

// UITabBarDelegate
extension ElloTabBarController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let items = tabBar.items, let index = items.index(of: item) {
            if index == selectedTab.rawValue {
                if let navigationViewController = selectedViewController as? UINavigationController, navigationViewController.childViewControllers.count > 1
                {
                    _ = navigationViewController.popToRootViewController(animated: true)
                }
                else {
                    if let scrollView = findScrollView(selectedViewController.view) {
                        scrollView.setContentOffset(CGPoint(x: 0, y: -scrollView.contentInset.top), animated: true)
                    }

                    if shouldReloadFriendStream() {
                        postNotification(NewContentNotifications.reloadStreamContent, value: nil)
                    }
                    else if shouldReloadNotificationsStream() {
                        postNotification(NewContentNotifications.reloadNotifications, value: nil)
                        self.newNotificationsAvailable = false
                    }
                }
            }
            else {
                selectedTab = ElloTab(rawValue:index) ?? .stream
            }

            if selectedTab == .notifications {
                if let navigationViewController = selectedViewController as? UINavigationController,
                    let notificationsViewController = navigationViewController.childViewControllers[0] as? NotificationsViewController {
                    notificationsViewController.fromTabBar = true
                }
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

    func shouldReloadFriendStream() -> Bool {
        return selectedTab.rawValue == 2 && streamsDot?.isHidden == false
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
        notificationsDot = tabBar.addRedDotAtIndex(1)
        streamsDot = tabBar.addRedDotAtIndex(2)
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
                self.narrationView.pointerX = rect.midX
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
        animate() {
            self.narrationView.alpha = 1
            self.narrationView.frame = self.animateInFinalFrame()
        }
        isShowingNarration = true
    }

    fileprivate func animateOutNarrationView() {
        animate() {
            self.narrationView.alpha = 0
            self.narrationView.frame = self.animateInStartFrame()
        }
        isShowingNarration = false
    }

}
