////
///  BaseElloViewController.swift
//

@objc
protocol ControllerThatMightHaveTheCurrentUser {
    var currentUser: User? { get set }
}

class BaseElloViewController: UIViewController,
    HasAppController, HasBackButton, HasCloseButton,
    ControllerThatMightHaveTheCurrentUser
{
    override var prefersStatusBarHidden: Bool {
        let visible = appViewController?.statusBarShouldBeVisible ?? true
        return !visible
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }

    override var title: String? {
        didSet {
            if isViewLoaded {
                let elloNavigationBar: ElloNavigationBar? = view.findSubview()
                elloNavigationBar?.invalidateDefaultTitle()
            }
        }
    }

    func fetchScreen<T>(_ mock: T?) -> T {
        if !isViewLoaded && Globals.isSimulator && !Globals.isTesting { fatalError("should not be accessing 'screen' now") }
        return mock ?? self.view as! T
    }

    var currentUser: User? {
        didSet { didSetCurrentUser() }
    }

    var appViewController: AppViewController? { return findParentController() }
    var elloTabBarController: ElloTabBarController? { return findParentController() }
    var bottomBarController: BottomBarController? { return findParentController() }
    var updatesBottomBar = true
    var navigationBarsVisible: Bool? {
        return bottomBarController?.navigationBarsVisible
    }

    // This is an odd one, `super.next` is not accessible in a closure that
    // captures self so we stuff it in a computed variable
    var superNext: UIResponder? {
        return super.next
    }

    var relationshipController: RelationshipController?

    override var next: UIResponder? {
        return relationshipController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupRelationshipController()
    }

    private func setupRelationshipController() {
        let chainableController = ResponderChainableController(
            controller: self,
            next: { [weak self] in
                return self?.superNext
            }
        )

        let relationshipController = RelationshipController(responderChainable: chainableController)
        relationshipController.currentUser = self.currentUser
        self.relationshipController = relationshipController
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNavBars(animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackScreenAppeared()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // updateNavBars(animated: false)
    }

    override func trackScreenAppeared() {
        super.trackScreenAppeared()

        if currentUser == nil {
            Tracker.shared.loggedOutScreenAppeared(self)
        }
    }

    func updateNavBars(animated: Bool) {
        guard let navigationBarsVisible = navigationBarsVisible else { return }

        postNotification(StatusBarNotifications.statusBarVisibility, value: navigationBarsVisible)
        if navigationBarsVisible {
            showNavBars(animated: animated)
        }
        else {
            hideNavBars(animated: animated)
        }
    }

    func showNavBars(animated: Bool) {
        guard updatesBottomBar else { return }
        bottomBarController?.setNavigationBarsVisible(true, animated: animated)
    }

    func hideNavBars(animated: Bool) {
        guard updatesBottomBar else { return }
        bottomBarController?.setNavigationBarsVisible(false, animated: animated)
    }

    func didSetCurrentUser() {
        relationshipController?.currentUser = currentUser

        for childController in childViewControllers {
            (childController as? ControllerThatMightHaveTheCurrentUser)?.currentUser = currentUser
        }

        (presentedViewController as? ControllerThatMightHaveTheCurrentUser)?.currentUser = currentUser
    }

    func showShareActivity(sender: UIView, url shareURL: URL, image: UIImage? = nil) {
        var items: [Any] = [shareURL]
        if let image = image {
            items.append(image)
        }

        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: [SafariActivity()])
        if UI_USER_INTERFACE_IDIOM() == .phone {
            activityVC.modalPresentationStyle = .fullScreen
            present(activityVC, animated: true) { }
        }
        else {
            activityVC.modalPresentationStyle = .popover
            activityVC.popoverPresentationController?.sourceView = sender
            present(activityVC, animated: true) { }
        }
    }

    func isRootViewController() -> Bool {
        guard let navigationController = navigationController else { return true }
        return navigationController.viewControllers.first == self
    }

    // called from ElloTabBarController
    func goingBackNow(proceed: @escaping Block) {
        proceed()
    }

    func backButtonTapped() {
        guard
            let navigationController = navigationController, navigationController.childViewControllers.count > 1
        else { return }

        _ = navigationController.popViewController(animated: true)
    }

    func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
