////
///  LoggedOutViewController.swift
//

import SnapKit


protocol BottomBarController: class {
    var navigationBarsVisible: Bool? { get }
    var bottomBarVisible: Bool { get }
    var bottomBarHeight: CGFloat { get }
    var bottomBarView: UIView { get }
    func setNavigationBarsVisible(_ visible: Bool, animated: Bool)
}


class LoggedOutViewController: BaseElloViewController, BottomBarController {
    private var _navigationBarsVisible: Bool = true
    override var navigationBarsVisible: Bool? { return _navigationBarsVisible }
    let bottomBarVisible: Bool = true
    var bottomBarHeight: CGFloat { return screen.bottomBarHeight }
    var bottomBarView: UIView { return screen.bottomBarView }
    var childView: UIView?

    private var _mockScreen: LoggedOutScreenProtocol?
    var screen: LoggedOutScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return fetchScreen(_mockScreen) }
    }

    private var userActionAttemptedObserver: NotificationObserver?

    func setNavigationBarsVisible(_ visible: Bool, animated: Bool) {
        _navigationBarsVisible = visible
    }

    override func addChild(_ childController: UIViewController) {
        super.addChild(childController)
        childView = childController.view
        if isViewLoaded {
            screen.setControllerView(childController.view)
        }
    }

    override func loadView() {
        let screen = LoggedOutScreen()
        screen.delegate = self
        view = screen
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let childView = childView {
            screen.setControllerView(childView)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNotificationObservers()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeNotificationObservers()
    }
}

extension LoggedOutViewController {

    func setupNotificationObservers() {
        userActionAttemptedObserver = NotificationObserver(
            notification: LoggedOutNotifications.userActionAttempted
        ) { [weak self] action in
            switch action {
            case .relationshipChange:
                Tracker.shared.loggedOutRelationshipAction()
            case .postTool:
                Tracker.shared.loggedOutPostTool()
            case .artistInviteSubmit:
                Tracker.shared.loggedOutArtistInviteSubmit()
            }
            self?.screen.showJoinText()
        }
    }

    func removeNotificationObservers() {
        userActionAttemptedObserver?.removeObserver()
    }

}

extension LoggedOutViewController: LoggedOutProtocol {
    func showLoginScreen() {
        Tracker.shared.loginButtonTapped()
        appViewController?.showLoginScreen()
    }

    func showJoinScreen() {
        Tracker.shared.joinButtonTapped()
        appViewController?.showJoinScreen()
    }
}
