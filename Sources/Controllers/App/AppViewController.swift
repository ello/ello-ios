////
///  AppViewController.swift
//

import SwiftyUserDefaults
import Crashlytics


struct NavigationNotifications {
    static let showingNotificationsTab = TypedNotification<[String]>(name: "co.ello.NavigationNotification.NotificationsTab")
}

struct StatusBarNotifications {
    static let statusBarShouldHide = TypedNotification<(Bool)>(name: "co.ello.StatusBarNotifications.statusBarShouldHide")
}


@objc
protocol HasAppController {
    var parentAppController: AppViewController? { get set }
}


class AppViewController: BaseElloViewController {
    var mockScreen: AppScreenProtocol?
    var screen: AppScreenProtocol { return mockScreen ?? (self.view as! AppScreenProtocol) }

    var visibleViewController: UIViewController?
    fileprivate var userLoggedOutObserver: NotificationObserver?
    fileprivate var receivedPushNotificationObserver: NotificationObserver?
    fileprivate var externalWebObserver: NotificationObserver?
    fileprivate var apiOutOfDateObserver: NotificationObserver?
    fileprivate var statusBarShouldHideObserver: NotificationObserver?

    fileprivate var pushPayload: PushPayload?

    fileprivate var deepLinkPath: String?

    var statusBarShouldHide = false

    func hideStatusBar(_ hide: Bool) {
        statusBarShouldHide = hide
        animate {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }

    override var prefersStatusBarHidden: Bool {
        return statusBarShouldHide
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }

    override func loadView() {
        self.view = AppScreen()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotificationObservers()
    }

    deinit {
        removeNotificationObservers()
    }

    var isStartup = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if isStartup {
            isStartup = false
            checkIfLoggedIn()
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        postNotification(Application.Notifications.ViewSizeWillChange, value: size)
    }

    override func didSetCurrentUser() {
        super.didSetCurrentUser()
        ElloWebBrowserViewController.currentUser = currentUser

        if let vc = visibleViewController as? ControllerThatMightHaveTheCurrentUser {
            vc.currentUser = currentUser
        }
    }

// MARK: - Private

    fileprivate func checkIfLoggedIn() {
        let authToken = AuthToken()
        let introDisplayed = GroupDefaults["IntroDisplayed"].bool ?? false

        if authToken.isPasswordBased {
            self.loadCurrentUser()
        }
        else if !introDisplayed {
            present(IntroViewController(), animated: false) {
                GroupDefaults["IntroDisplayed"] = true
                self.showStartupScreen()
            }
        }
        else {
            self.showLoginScreen(animated: false)
        }
    }

    func loadCurrentUser(_ failure: ElloErrorCompletion? = nil) {
        let failureCompletion: ElloErrorCompletion
        if let failure = failure {
            failureCompletion = failure
        }
        else {
            screen.animateLogo()
            failureCompletion = { _ in
                self.showStartupScreen()
                self.screen.stopAnimatingLogo()
            }
        }

        ProfileService().loadCurrentUser(
            success: { user in

                JWT.refresh()

                self.screen.stopAnimatingLogo()
                self.currentUser = user

                let shouldShowOnboarding = Onboarding.shared().showOnboarding(user)
                if shouldShowOnboarding {
                    self.showOnboardingScreen(user)
                }
                else {
                    self.showMainScreen(user)
                }
            },
            failure: { (error, _) in
                failureCompletion(error)
            })
    }

    fileprivate func setupNotificationObservers() {
        userLoggedOutObserver = NotificationObserver(notification: AuthenticationNotifications.userLoggedOut) { [weak self] in
            self?.userLoggedOut()
        }
        receivedPushNotificationObserver = NotificationObserver(notification: PushNotificationNotifications.interactedWithPushNotification) { [weak self] payload in
            self?.receivedPushNotification(payload)
        }
        externalWebObserver = NotificationObserver(notification: ExternalWebNotification) { [weak self] url in
            self?.showExternalWebView(url)
        }
        apiOutOfDateObserver = NotificationObserver(notification: ErrorStatusCode.status410.notification) { [weak self] error in
            let message = InterfaceString.App.OldVersion
            let alertController = AlertViewController(message: message)

            let action = AlertAction(title: InterfaceString.OK, style: .dark, handler: nil)
            alertController.addAction(action)

            self?.present(alertController, animated: true, completion: nil)
            self?.apiOutOfDateObserver?.removeObserver()
            postNotification(AuthenticationNotifications.invalidToken, value: false)
        }

        statusBarShouldHideObserver = NotificationObserver(notification: StatusBarNotifications.statusBarShouldHide) { [weak self] (hide) in
            self?.hideStatusBar(hide)
        }
    }

    fileprivate func removeNotificationObservers() {
        userLoggedOutObserver?.removeObserver()
        receivedPushNotificationObserver?.removeObserver()
        externalWebObserver?.removeObserver()
        apiOutOfDateObserver?.removeObserver()
        statusBarShouldHideObserver?.removeObserver()
    }
}


// MARK: Screens
extension AppViewController {

    fileprivate func showStartupScreen(_ completion: @escaping ElloEmptyCompletion = {}) {
        guard !((visibleViewController as? UINavigationController)?.visibleViewController is StartupViewController) else { return }

        let startupController = StartupViewController()
        startupController.parentAppController = self
        let nav = ElloNavigationController(rootViewController: startupController)
        nav.isNavigationBarHidden = true
        swapViewController(nav, completion: completion)
        Tracker.shared.screenAppeared(startupController)
    }

    func showJoinScreen(animated: Bool, invitationCode: String? = nil) {
        guard let nav = visibleViewController as? UINavigationController else {
            showStartupScreen() { self.showJoinScreen(animated: animated) }
            return
        }

        if !(nav.visibleViewController is StartupViewController) {
            _ = nav.popToRootViewController(animated: false)
        }
        guard let startupController = nav.visibleViewController as? StartupViewController else { return }

        pushPayload = .none
        let joinController = JoinViewController()
        joinController.parentAppController = self
        joinController.invitationCode = invitationCode
        nav.setViewControllers([startupController, joinController], animated: animated)
    }

    func showLoginScreen(animated: Bool) {
        showStartupScreen()
        guard let nav = visibleViewController as? UINavigationController else { return }

        if !(nav.visibleViewController is StartupViewController) {
            _ = nav.popToRootViewController(animated: false)
        }
        guard let startupController = nav.visibleViewController as? StartupViewController else { return }

        pushPayload = .none
        let loginController = LoginViewController()
        loginController.parentAppController = self
        nav.setViewControllers([startupController, loginController], animated: animated)
    }

    func showOnboardingScreen(_ user: User) {
        currentUser = user

        let vc = OnboardingViewController()
        vc.parentAppController = self
        vc.currentUser = user

        swapViewController(vc) {}
    }

    func doneOnboarding() {
        Onboarding.shared().updateVersionToLatest()
        self.showMainScreen(currentUser!)
    }

    func showMainScreen(_ user: User) {
        Tracker.shared.identify(user)

        let vc = ElloTabBarController.instantiateFromStoryboard()
        ElloWebBrowserViewController.elloTabBarController = vc
        vc.currentUser = user

        swapViewController(vc) {
            if let payload = self.pushPayload {
                self.navigateToDeepLink(payload.applicationTarget)
                self.pushPayload = .none
            }
            if let deepLinkPath = self.deepLinkPath {
                self.navigateToDeepLink(deepLinkPath)
                self.deepLinkPath = .none
            }

            vc.activateTabBar()
            if let alert = PushNotificationController.sharedController.requestPushAccessIfNeeded() {
                vc.present(alert, animated: true, completion: .none)
            }
        }
    }
}

extension AppViewController {

    func showExternalWebView(_ url: String) {
        if let externalURL = URL(string: url), ElloWebViewHelper.bypassInAppBrowser(externalURL) {
            UIApplication.shared.openURL(externalURL)
        }
        else {
            let externalWebController = ElloWebBrowserViewController.navigationControllerWithWebBrowser()
            present(externalWebController, animated: true, completion: nil)

            if let externalWebView = externalWebController.rootWebBrowser() {
                externalWebView.tintColor = UIColor.greyA()
                externalWebView.loadURLString(url)
            }
        }
        Tracker.shared.webViewAppeared(url)
    }

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        // Unsure why WKWebView calls this controller - instead of it's own parent controller
        if let vc = presentedViewController {
            vc.present(viewControllerToPresent, animated: flag, completion: completion)
        } else {
            super.present(viewControllerToPresent, animated: flag, completion: completion)
        }
    }

}

// MARK: Screen transitions
extension AppViewController {

    func swapViewController(_ newViewController: UIViewController, completion: @escaping ElloEmptyCompletion) {
        newViewController.view.alpha = 0

        visibleViewController?.willMove(toParentViewController: nil)
        newViewController.willMove(toParentViewController: self)

        prepareToShowViewController(newViewController)

        if let tabBarController = visibleViewController as? ElloTabBarController {
            tabBarController.deactivateTabBar()
        }

        UIView.animate(withDuration: 0.2, animations: {
            self.visibleViewController?.view.alpha = 0
            newViewController.view.alpha = 1
            self.screen.hide()
        }, completion: { _ in
            self.visibleViewController?.view.removeFromSuperview()
            self.visibleViewController?.removeFromParentViewController()

            self.addChildViewController(newViewController)
            if let childController = newViewController as? HasAppController {
                childController.parentAppController = self
            }

            newViewController.didMove(toParentViewController: self)

            self.visibleViewController = newViewController
            completion()
        })
    }

    func removeViewController(_ completion: @escaping ElloEmptyCompletion = {}) {
        if presentingViewController != nil {
            dismiss(animated: false, completion: .none)
        }
        self.hideStatusBar(false)

        if let visibleViewController = visibleViewController {
            visibleViewController.willMove(toParentViewController: nil)

            if let tabBarController = visibleViewController as? ElloTabBarController {
                tabBarController.deactivateTabBar()
            }

            UIView.animate(withDuration: 0.2, animations: {
                self.showStartupScreen()
                visibleViewController.view.alpha = 0
            }, completion: { _ in
                visibleViewController.view.removeFromSuperview()
                visibleViewController.removeFromParentViewController()
                self.visibleViewController = nil
                completion()
            })
        }
        else {
            showStartupScreen()
            completion()
        }
    }

    fileprivate func prepareToShowViewController(_ newViewController: UIViewController) {
        let controller = (newViewController as? UINavigationController)?.topViewController ?? newViewController
        Tracker.shared.screenAppeared(controller)

        view.addSubview(newViewController.view)
        newViewController.view.frame = self.view.bounds
        newViewController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

}


// MARK: Logout events
extension AppViewController {
    func userLoggedOut() {
        logOutCurrentUser()

        if isLoggedIn() {
            removeViewController()
        }
    }

    func forceLogOut(_ shouldAlert: Bool) {
        logOutCurrentUser()

        if isLoggedIn() {
            removeViewController() {
                if shouldAlert {
                    let message = InterfaceString.App.LoggedOut
                    let alertController = AlertViewController(message: message)

                    let action = AlertAction(title: InterfaceString.OK, style: .dark, handler: nil)
                    alertController.addAction(action)

                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }

    func isLoggedIn() -> Bool {
        if let visibleViewController = visibleViewController, visibleViewController is ElloTabBarController
        {
            return true
        }
        return false
    }

    fileprivate func logOutCurrentUser() {
        PushNotificationController.sharedController.deregisterStoredToken()
        ElloProvider.shared.logout()
        GroupDefaults[CurrentStreamKey] = nil
        UIApplication.shared.applicationIconBadgeNumber = 0
        URLCache.shared.removeAllCachedResponses()
        TemporaryCache.clear()
        var cache = InviteCache()
        cache.clear()
        currentUser = nil
    }
}

// MARK: Push Notification Handling
extension AppViewController {
    func receivedPushNotification(_ payload: PushPayload) {
        if self.visibleViewController is ElloTabBarController {
            navigateToDeepLink(payload.applicationTarget)
        } else {
            self.pushPayload = payload
        }
    }
}

// MARK: URL Handling
extension AppViewController {
    func navigateToDeepLink(_ path: String) {
        Tracker.shared.deepLinkVisited(path)

        let (type, data) = ElloURI.match(path)

        guard type.shouldLoadInApp else {
            if let pathURL = URL(string: path) {
                UIApplication.shared.openURL(pathURL)
            }
            return
        }

        guard !stillLoggingIn() else {
            self.deepLinkPath = path
            return
        }

        guard isLoggedIn() else {
            switch type {
            case .invite:
                showJoinScreen(animated: false, invitationCode: data)
            case .join:
                showJoinScreen(animated: false)
            case .login:
                showLoginScreen(animated: false)
            default:
                presentLoginOrSafariAlert(path)
            }
            return
        }

        guard let vc = self.visibleViewController as? ElloTabBarController else {
            return
        }

        switch type {
        case .invite, .join, .login:
            break
        case .exploreRecommended,
             .exploreRecent,
             .exploreTrending:
            showDiscoverScreen(vc)
        case .discover:
            showDiscoverScreen(vc)
        case .discoverRandom,
             .discoverRecent,
             .discoverRelated,
             .discoverTrending,
             .category:
            showCategoryScreen(vc, slug: data)
        case .invitations:
            showInvitationScreen(vc)
        case .enter, .exit, .root, .explore:
            break
        case .friends,
             .following,
             .noise,
             .starred:
            showStreamContainerScreen(vc: vc, type: type)
        case .notifications:
            showNotificationsScreen(vc, category: data)
        case .onboarding:
            if let user = currentUser {
                showOnboardingScreen(user)
            }
        case .post:
            showPostDetailScreen(data, path: path)
        case .pushNotificationComment,
             .pushNotificationPost:
            showPostDetailScreen(data, path: path, isSlug: false)
        case .profile:
            showProfileScreen(data, path: path)
        case .pushNotificationUser:
            showProfileScreen(data, path: path, isSlug: false)
        case .profileFollowers:
            showProfileFollowersScreen(data)
        case .profileFollowing:
            showProfileFollowingScreen(data)
        case .profileLoves:
            showProfileLovesScreen(data)
        case .search,
             .searchPeople,
             .searchPosts:
            showSearchScreen(data)
        case .settings:
            showSettingsScreen()
        case .wtf:
            showExternalWebView(path)
        default:
            if let pathURL = URL(string: path) {
                UIApplication.shared.openURL(pathURL)
            }
        }
    }

    fileprivate func stillLoggingIn() -> Bool {
        let authToken = AuthToken()
        return !isLoggedIn() && authToken.isPasswordBased
    }

    fileprivate func presentLoginOrSafariAlert(_ path: String) {
        guard !isLoggedIn() else {
            return
        }

        let alertController = AlertViewController(message: path)

        let yes = AlertAction(title: InterfaceString.App.LoginAndView, style: .dark) { _ in
            self.deepLinkPath = path
            self.showLoginScreen(animated: true)
        }
        alertController.addAction(yes)

        let viewBrowser = AlertAction(title: InterfaceString.App.OpenInSafari, style: .light) { _ in
            if let pathURL = URL(string: path) {
                UIApplication.shared.openURL(pathURL)
            }
        }
        alertController.addAction(viewBrowser)

        self.present(alertController, animated: true, completion: nil)
    }

    fileprivate func showInvitationScreen(_ vc: ElloTabBarController) {
        vc.selectedTab = .discover

        let responder = target(forAction: #selector(InviteResponder.onInviteFriends), withSender: self) as? InviteResponder
        responder?.onInviteFriends()
    }

    fileprivate func showDiscoverScreen(_ vc: ElloTabBarController) {
        guard
            let navVC = vc.selectedViewController as? ElloNavigationController, !(navVC.visibleViewController is DiscoverAllCategoriesViewController)
        else { return }

        let vc = DiscoverAllCategoriesViewController()
        vc.currentUser = currentUser
        pushDeepLinkViewController(vc)
    }

    fileprivate func showCategoryScreen(_ vc: ElloTabBarController, slug: String) {
        guard
            let navVC = vc.selectedViewController as? ElloNavigationController, !DeepLinking.alreadyOnCurrentCategory(navVC: navVC, slug: slug)
        else { return }

        Tracker.shared.categoryOpened(slug)
        let vc = CategoryViewController(slug: slug)
        vc.currentUser = currentUser
        pushDeepLinkViewController(vc)
    }


    fileprivate func showStreamContainerScreen(vc: ElloTabBarController, type: ElloURI) {
        vc.selectedTab = .stream

        guard
            let navVC = vc.selectedViewController as? ElloNavigationController,
            let streamVC = navVC.visibleViewController as? StreamContainerViewController
        else { return }

        streamVC.currentUser = currentUser

        switch type {
        case .noise, .starred: streamVC.showNoise()
        case .friends, .following: streamVC.showFriends()
        default: break
        }
    }

    fileprivate func showNotificationsScreen(_ vc: ElloTabBarController, category: String) {
        vc.selectedTab = .notifications
        guard
            let navVC = vc.selectedViewController as? ElloNavigationController,
            let notificationsVC = navVC.visibleViewController as? NotificationsViewController
        else { return }

        let notificationFilterType = NotificationFilterType.fromCategory(category)
        notificationsVC.categoryFilterType = notificationFilterType
        notificationsVC.activatedCategory(notificationFilterType)
        notificationsVC.currentUser = currentUser
    }

    fileprivate func showProfileScreen(_ userParam: String, path: String, isSlug: Bool = true) {
        let param = isSlug ? "~\(userParam)" : userParam
        let profileVC = ProfileViewController(userParam: param)
        profileVC.deeplinkPath = path
        profileVC.currentUser = currentUser
        pushDeepLinkViewController(profileVC)
    }

    fileprivate func showPostDetailScreen(_ postParam: String, path: String, isSlug: Bool = true) {
        let param = isSlug ? "~\(postParam)" : postParam
        let postDetailVC = PostDetailViewController(postParam: param)
        postDetailVC.deeplinkPath = path
        postDetailVC.currentUser = currentUser
        pushDeepLinkViewController(postDetailVC)
    }

    fileprivate func showProfileFollowersScreen(_ username: String) {
        let endpoint = ElloAPI.userStreamFollowers(userId: "~\(username)")
        let noResultsTitle: String
        let noResultsBody: String
        if username == currentUser?.username {
            noResultsTitle = InterfaceString.Followers.CurrentUserNoResultsTitle
            noResultsBody = InterfaceString.Followers.CurrentUserNoResultsBody
        }
        else {
            noResultsTitle = InterfaceString.Followers.NoResultsTitle
            noResultsBody = InterfaceString.Followers.NoResultsBody
        }
        let followersVC = SimpleStreamViewController(endpoint: endpoint, title: "@" + username + "'s " + InterfaceString.Followers.Title)
        followersVC.streamViewController.noResultsMessages = (title: noResultsTitle, body: noResultsBody)
        followersVC.currentUser = currentUser
        pushDeepLinkViewController(followersVC)
    }

    fileprivate func showProfileFollowingScreen(_ username: String) {
        let endpoint = ElloAPI.userStreamFollowing(userId: "~\(username)")
        let noResultsTitle: String
        let noResultsBody: String
        if username == currentUser?.username {
            noResultsTitle = InterfaceString.Following.CurrentUserNoResultsTitle
            noResultsBody = InterfaceString.Following.CurrentUserNoResultsBody
        }
        else {
            noResultsTitle = InterfaceString.Following.NoResultsTitle
            noResultsBody = InterfaceString.Following.NoResultsBody
        }
        let vc = SimpleStreamViewController(endpoint: endpoint, title: "@" + username + "'s " + InterfaceString.Following.Title)
        vc.streamViewController.noResultsMessages = (title: noResultsTitle, body: noResultsBody)
        vc.currentUser = currentUser
        pushDeepLinkViewController(vc)
    }

    fileprivate func showProfileLovesScreen(_ username: String) {
        let endpoint = ElloAPI.loves(userId: "~\(username)")
        let noResultsTitle: String
        let noResultsBody: String
        if username == currentUser?.username {
            noResultsTitle = InterfaceString.Loves.CurrentUserNoResultsTitle
            noResultsBody = InterfaceString.Loves.CurrentUserNoResultsBody
        }
        else {
            noResultsTitle = InterfaceString.Loves.NoResultsTitle
            noResultsBody = InterfaceString.Loves.NoResultsBody
        }
        let vc = SimpleStreamViewController(endpoint: endpoint, title: "@" + username + "'s " + InterfaceString.Loves.Title)
        vc.streamViewController.noResultsMessages = (title: noResultsTitle, body: noResultsBody)
        vc.currentUser = currentUser
        pushDeepLinkViewController(vc)
    }

    fileprivate func showSearchScreen(_ terms: String) {
        let search = SearchViewController()
        search.currentUser = currentUser
        if !terms.isEmpty {
            search.searchForPosts(terms.urlDecoded().replacingOccurrences(of: "+", with: " ", options: NSString.CompareOptions.literal, range: nil))
        }
        pushDeepLinkViewController(search)
    }

    fileprivate func showSettingsScreen() {
        if let settings = UIStoryboard(name: "Settings", bundle: .none).instantiateInitialViewController() as? SettingsContainerViewController {
            settings.currentUser = currentUser
            pushDeepLinkViewController(settings)
        }
    }

    fileprivate func pushDeepLinkViewController(_ vc: UIViewController) {
        guard
            let tabController = self.visibleViewController as? ElloTabBarController,
            let navController = tabController.selectedViewController as? UINavigationController
        else { return }

        if let topNavVC = topViewController(self)?.navigationController {
            topNavVC.pushViewController(vc, animated: true)
        }
        else {
            navController.pushViewController(vc, animated: true)
        }
    }

    fileprivate func selectTab(_ tab: ElloTab) {
        ElloWebBrowserViewController.elloTabBarController?.selectedTab = tab
    }


}

extension AppViewController {

    func topViewController(_ base: UIViewController?) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}

var isShowingDebug = false
var debugController = DebugController()

extension AppViewController {

    override var canBecomeFirstResponder: Bool {
        #if DEBUG
            return true
        #else
            return AuthToken().isStaff
        #endif
    }

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            if isShowingDebug {
                closeTodoController()
            }
            else {
                isShowingDebug = true
                let ctlr = debugController
                ctlr.title = "Debugging"

                let nav = UINavigationController(rootViewController: ctlr)
                let bar = UIView(frame: CGRect(x: 0, y: -20, width: view.frame.width, height: 20))
                bar.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
                bar.backgroundColor = .black
                nav.navigationBar.addSubview(bar)

                let closeItem = UIBarButtonItem.closeButton(target: self, action: #selector(AppViewController.closeTodoControllerTapped))
                ctlr.navigationItem.leftBarButtonItem = closeItem

                present(nav, animated: true, completion: nil)
            }
        }
    }

    func closeTodoControllerTapped() {
        closeTodoController()
    }

    func closeTodoController(completion: (() -> Void)? = nil) {
        isShowingDebug = false
        dismiss(animated: true, completion: completion)
    }

}
