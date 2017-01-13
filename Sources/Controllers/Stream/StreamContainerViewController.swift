////
///  StreamContainerViewController.swift
//

import SwiftyUserDefaults

let CurrentStreamKey = "Ello.StreamContainerViewController.CurrentStream"

class StreamContainerViewController: StreamableViewController {
    override func trackerName() -> String? { return "Stream" }
    override func trackerProps() -> [String: AnyObject]? {
        let stream = streamValues[currentStreamIndex]
        return ["kind": stream.name as AnyObject]
    }

    fileprivate var loggedPromptEventForThisSession = false
    fileprivate var reloadStreamContentObserver: NotificationObserver?
    fileprivate var appBackgroundObserver: NotificationObserver?
    fileprivate var appForegroundObserver: NotificationObserver?

    let streamValues: [StreamKind] = [.following, .starred]
    fileprivate var streamLoaded: [Bool] = [false, false] // needs to hold same number of 'false's as streamValues

    var currentStreamIndex: Int {
        get {
            return GroupDefaults[CurrentStreamKey].int ?? 0
        }
        set(newValue) {
            GroupDefaults[CurrentStreamKey] = newValue
        }
    }

    enum Notifications: String {
        case streamDetailTapped = "StreamDetailTappedNotification"
    }

    override var tabBarItem: UITabBarItem? {
        get { return UITabBarItem.item(.circBig) }
        set { self.tabBarItem = newValue }
    }

    @IBOutlet weak var scrollView: UIScrollView!
    weak var navigationBar: ElloNavigationBar!
    @IBOutlet weak var navigationBarTopConstraint: NSLayoutConstraint!

    var streamsSegmentedControl: UISegmentedControl!
    var streamControllerViews: [UIView] = []

    fileprivate var childStreamControllers: [StreamViewController] {
        return self.childViewControllers.filter { $0 is StreamViewController } as! [StreamViewController]
    }

    deinit {
        removeTemporaryNotificationObservers()
        removeNotificationObservers()
    }

    override func backGestureAction() {
        hamburgerButtonTapped()
    }

    override func setupStreamController() { /* intentially left blank */ }

    override func viewDidLoad() {
        super.viewDidLoad()
        addNotificationObservers()
        setupStreamsSegmentedControl()
        setupChildViewControllers()
        updateInsets()

        let index = currentStreamIndex
        let stream = streamValues[index]
        let initialController = childStreamControllers[index]
        setupNavigationBar(controller: initialController)

        initialController.collectionView.scrollsToTop = true
        streamsSegmentedControl.selectedSegmentIndex = index
        initialController.loadInitialPage()
        streamLoaded[index] = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Rotating the phone after opening a web page results in the
        // streamsSegmentedControl "flattening" to 1pt height.  So we just fix
        // it when the controller is shown again (e.g. when hiding the web page)
        streamsSegmentedControl.frame.size.height = 19
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        addTemporaryNotificationObservers()
        if !loggedPromptEventForThisSession {
            Rate.sharedRate.logEvent()
            loggedPromptEventForThisSession = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeNotificationObservers()
    }

    func reload(streamKind: StreamKind) {
        let controller: StreamViewController?
        switch streamKind {
        case .following:
            controller = childStreamControllers[0]
        case .starred:
            controller = childStreamControllers[1]
        default:
            controller = nil
        }

        if let controller = controller, controller == childStreamControllers[currentStreamIndex] {
            ElloHUD.showLoadingHudInView(controller.view)
            controller.loadInitialPage()
            Tracker.shared.screenAppeared(self)
        }
    }

    fileprivate func updateInsets() {
        for controller in childStreamControllers {
            updateInsets(navBar: navigationBar, streamController: controller)
        }
    }

    override func showNavBars(_ scrollToBottom: Bool) {
        super.showNavBars(scrollToBottom)
        positionNavBar(navigationBar, visible: true, withConstraint: navigationBarTopConstraint)
        updateInsets()

        if scrollToBottom {
            for controller in childStreamControllers {
                self.scrollToBottom(controller)
            }
        }
    }

    override func hideNavBars() {
        super.hideNavBars()
        positionNavBar(navigationBar, visible: false, withConstraint: navigationBarTopConstraint)
        updateInsets()
    }

    class func instantiateFromStoryboard() -> StreamContainerViewController {
        let navController = UIStoryboard.storyboardWithId(.streamContainer) as! UINavigationController
        let streamsController = navController.topViewController
        return streamsController as! StreamContainerViewController
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let width: CGFloat = view.bounds.size.width
        let height: CGFloat = view.bounds.size.height

        for (index, view) in streamControllerViews.enumerated() {
            view.frame = CGRect(x: width * CGFloat(index), y: 0, width: width, height: height)
        }

        scrollView.contentSize = CGSize(width: width * CGFloat(streamValues.count), height: height)

        let selectedIndex = streamsSegmentedControl.selectedSegmentIndex
        let x = CGFloat(selectedIndex) * width
        let rect = CGRect(x: x, y: 0, width: width, height: height)
        scrollView.scrollRectToVisible(rect, animated: false)
    }

    fileprivate func setupNavigationBar(controller: StreamViewController) {
        elloNavigationItem.titleView = streamsSegmentedControl
        elloNavigationItem.leftBarButtonItem = UIBarButtonItem(image: InterfaceImage.burger.normalImage, style: .done, target: self, action: #selector(StreamContainerViewController.hamburgerButtonTapped))
        let searchItem = UIBarButtonItem.searchItem(controller: self)
        let gridListItem = UIBarButtonItem.gridListItem(delegate: controller, isGridView: controller.streamKind.isGridView)
        elloNavigationItem.rightBarButtonItems = [
            searchItem,
            gridListItem,
        ]
        navigationBar.items = [elloNavigationItem]
    }

    fileprivate func setupChildViewControllers() {
        scrollView.isScrollEnabled = false
        scrollView.scrollsToTop = false
        let width: CGFloat = scrollView.frame.size.width
        let height: CGFloat = scrollView.frame.size.height

        for (index, kind) in streamValues.enumerated() {
            let vc = StreamViewController.instantiateFromStoryboard()
            vc.currentUser = currentUser
            vc.streamKind = kind
            vc.createPostDelegate = self
            vc.postTappedDelegate = self
            vc.userTappedDelegate = self
            vc.streamViewDelegate = self
            vc.collectionView.scrollsToTop = false

            vc.willMove(toParentViewController: self)

            let x = CGFloat(index) * width
            let frame = CGRect(x: x, y: 0, width: width, height: height)
            vc.view.frame = frame
            scrollView.addSubview(vc.view)
            streamControllerViews.append(vc.view)

            self.addChildViewController(vc)
            vc.didMove(toParentViewController: self)
            ElloHUD.showLoadingHudInView(vc.view)
        }
    }

    fileprivate func setupStreamsSegmentedControl() {
        let control = ElloSegmentedControl(items: streamValues.map{ $0.name })
        control.style = .compact
        control.addTarget(self, action: #selector(StreamContainerViewController.streamSegmentTapped(_:)), for: .valueChanged)
        control.frame.size.height = 19.0
        control.layer.borderWidth = 1.0
        control.selectedSegmentIndex = 0
        control.tintColor = .black
        streamsSegmentedControl = control
    }

    fileprivate func showSegmentIndex(_ index: Int) {
        for controller in childStreamControllers {
            controller.collectionView.scrollsToTop = false
        }

        let currentController = childStreamControllers[index]
        currentController.collectionView.scrollsToTop = true

        let width = view.bounds.size.width
        let height = view.bounds.size.height
        let x = CGFloat(index) * width
        let rect = CGRect(x: x, y: 0, width: width, height: height)
        scrollView.scrollRectToVisible(rect, animated: true)

        currentStreamIndex = index
        let stream = streamValues[currentStreamIndex]
        Tracker.shared.screenAppeared(self)

        setupNavigationBar(controller: currentController)

        if !streamLoaded[index] {
            streamLoaded[index] = true
            currentController.loadInitialPage()
        }
    }

    // MARK: - IBActions
    let drawerAnimator = DrawerAnimator()

    @IBAction func hamburgerButtonTapped() {
        let drawer = DrawerViewController()
        drawer.currentUser = currentUser

        drawer.transitioningDelegate = drawerAnimator
        drawer.modalPresentationStyle = .custom

        self.present(drawer, animated: true, completion: nil)
    }

    @IBAction func streamSegmentTapped(_ sender: UISegmentedControl) {
        showSegmentIndex(sender.selectedSegmentIndex)
    }
}

extension StreamContainerViewController {

    func showFriends() {
        showSegmentIndex(0)
        streamsSegmentedControl.selectedSegmentIndex = 0
    }

    func showNoise() {
        showSegmentIndex(1)
        streamsSegmentedControl.selectedSegmentIndex = 1
    }
}

private extension StreamContainerViewController {

    func addTemporaryNotificationObservers() {
        reloadStreamContentObserver = NotificationObserver(notification: NewContentNotifications.reloadStreamContent) {
            [unowned self] _ in
            self.reload(streamKind: .following)
        }
    }

    func removeTemporaryNotificationObservers() {
        reloadStreamContentObserver?.removeObserver()
    }

    func addNotificationObservers() {
        appBackgroundObserver = NotificationObserver(notification: Application.Notifications.DidEnterBackground) {
            [unowned self] _ in
            self.loggedPromptEventForThisSession = false
        }
    }

    func removeNotificationObservers() {
        appBackgroundObserver?.removeObserver()
    }
}
