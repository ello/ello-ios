////
///  StreamContainerViewController.swift
//

import SwiftyUserDefaults

let CurrentStreamKey = "Ello.StreamContainerViewController.CurrentStream"

public class StreamContainerViewController: StreamableViewController {
    private var loggedPromptEventForThisSession = false
    private var reloadStreamContentObserver: NotificationObserver?
    private var friendsViewController: StreamViewController?
    private var appBackgroundObserver: NotificationObserver?
    private var appForegroundObserver: NotificationObserver?

    public let streamValues: [StreamKind] = [.Following, .Starred]
    private lazy var streamLoaded: [Bool] = self.defaultSreamLoadedValues() // needs to hold same number of 'false's as streamValues

    // moved into a separate function to save compile time
    private func defaultSreamLoadedValues() -> [Bool] {
        return [false, false]
    }

    public var currentStreamIndex: Int {
        get {
            return GroupDefaults[CurrentStreamKey].int ?? 0
        }
        set(newValue) {
            GroupDefaults[CurrentStreamKey] = newValue
        }
    }

    enum Notifications: String {
        case StreamDetailTapped = "StreamDetailTappedNotification"
    }

    override public var tabBarItem: UITabBarItem? {
        get { return UITabBarItem.item(.CircBig) }
        set { self.tabBarItem = newValue }
    }

    @IBOutlet weak public var scrollView: UIScrollView!
    weak public var navigationBar: ElloNavigationBar!
    @IBOutlet weak public var navigationBarTopConstraint: NSLayoutConstraint!

    public var streamsSegmentedControl: UISegmentedControl!
    public var streamControllerViews: [UIView] = []

    private var childStreamControllers: [StreamViewController] {
        return self.childViewControllers.filter { $0 is StreamViewController } as! [StreamViewController]
    }

    deinit {
        removeTemporaryNotificationObservers()
        removeNotificationObservers()
    }

    override public func backGestureAction() {
        hamburgerButtonTapped()
    }

    override func setupStreamController() { /* intentially left blank */ }

    override public func viewDidLoad() {
        super.viewDidLoad()
        addNotificationObservers()
        setupStreamsSegmentedControl()
        setupChildViewControllers()
        elloNavigationItem.titleView = streamsSegmentedControl
        elloNavigationItem.leftBarButtonItem = UIBarButtonItem(image: InterfaceImage.Burger.normalImage, style: .Done, target: self, action: #selector(StreamContainerViewController.hamburgerButtonTapped))
        addSearchButton()
        navigationBar.items = [elloNavigationItem]

        let index = currentStreamIndex
        let stream = streamValues[index]
        let initialController = childStreamControllers[index]
        scrollLogic.prevOffset = initialController.collectionView.contentOffset
        initialController.collectionView.scrollsToTop = true
        streamsSegmentedControl.selectedSegmentIndex = index
        initialController.loadInitialPage()
        streamLoaded[index] = true

        Tracker.sharedTracker.streamAppeared(stream.name)
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // Rotating the phone after opening a web page results in the
        // streamsSegmentedControl "flattening" to 1pt height.  So we just fix
        // it when the controller is shown again (e.g. when hiding the web page)
        streamsSegmentedControl.frame.size.height = 19
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        addTemporaryNotificationObservers()
        if !loggedPromptEventForThisSession {
            Rate.sharedRate.logEvent()
            loggedPromptEventForThisSession = true
        }
    }

    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        removeNotificationObservers()
    }

    private func updateInsets() {
        for controller in childStreamControllers {
            updateInsets(navBar: navigationBar, streamController: controller)
        }
    }

    override public func showNavBars(scrollToBottom: Bool) {
        super.showNavBars(scrollToBottom)
        positionNavBar(navigationBar, visible: true, withConstraint: navigationBarTopConstraint)
        updateInsets()

        if scrollToBottom {
            for controller in childStreamControllers {
                self.scrollToBottom(controller)
            }
        }
    }

    override public func hideNavBars() {
        super.hideNavBars()
        positionNavBar(navigationBar, visible: false, withConstraint: navigationBarTopConstraint)
        updateInsets()
    }

    public class func instantiateFromStoryboard() -> StreamContainerViewController {
        let navController = UIStoryboard.storyboardWithId(.StreamContainer) as! UINavigationController
        let streamsController = navController.topViewController
        return streamsController as! StreamContainerViewController
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let width: CGFloat = view.bounds.size.width
        let height: CGFloat = view.bounds.size.height

        for (index, view) in streamControllerViews.enumerate() {
            view.frame = CGRect(x: width * CGFloat(index), y: 0, width: width, height: height)
        }

        scrollView.contentSize = CGSize(width: width * CGFloat(streamValues.count), height: height)

        let selectedIndex = streamsSegmentedControl.selectedSegmentIndex
        let x = CGFloat(selectedIndex) * width
        let rect = CGRect(x: x, y: 0, width: width, height: height)
        scrollView.scrollRectToVisible(rect, animated: false)
    }

    private func setupChildViewControllers() {
        scrollView.scrollEnabled = false
        scrollView.scrollsToTop = false
        let width: CGFloat = scrollView.frame.size.width
        let height: CGFloat = scrollView.frame.size.height

        for (index, kind) in streamValues.enumerate() {
            let vc = StreamViewController.instantiateFromStoryboard()
            vc.currentUser = currentUser
            vc.streamKind = kind
            vc.createPostDelegate = self
            vc.postTappedDelegate = self
            vc.userTappedDelegate = self
            vc.streamViewDelegate = self
            vc.collectionView.scrollsToTop = false

            vc.willMoveToParentViewController(self)

            let x = CGFloat(index) * width
            let frame = CGRect(x: x, y: 0, width: width, height: height)
            vc.view.frame = frame
            scrollView.addSubview(vc.view)
            streamControllerViews.append(vc.view)

            self.addChildViewController(vc)
            vc.didMoveToParentViewController(self)
            ElloHUD.showLoadingHudInView(vc.view)

            switch kind {
            case .Following:
                let noResultsTitle = InterfaceString.FollowingStream.NoResultsTitle
                let noResultsBody = InterfaceString.FollowingStream.NoResultsBody
                friendsViewController = vc
                vc.noResultsMessages = (title: noResultsTitle, body: noResultsBody)
            case .Starred:
                let noResultsTitle = InterfaceString.StarredStream.NoResultsTitle
                let noResultsBody = InterfaceString.StarredStream.NoResultsBody
                vc.noResultsMessages = (title: noResultsTitle, body: noResultsBody)
            default:
                break
            }
        }
    }

    private func setupStreamsSegmentedControl() {
        let control = ElloSegmentedControl(items: streamValues.map{ $0.name })
        control.style = .Compact
        control.addTarget(self, action: #selector(StreamContainerViewController.streamSegmentTapped(_:)), forControlEvents: .ValueChanged)
        control.frame.size.height = 19.0
        control.layer.borderWidth = 1.0
        control.selectedSegmentIndex = 0
        control.tintColor = .blackColor()
        streamsSegmentedControl = control
    }

    private func showSegmentIndex(index: Int) {
        for controller in childStreamControllers {
            controller.collectionView.scrollsToTop = false
        }

        childStreamControllers[index].collectionView.scrollsToTop = true

        let width = view.bounds.size.width
        let height = view.bounds.size.height
        let x = CGFloat(index) * width
        let rect = CGRect(x: x, y: 0, width: width, height: height)
        scrollView.scrollRectToVisible(rect, animated: true)

        currentStreamIndex = index
        let stream = streamValues[currentStreamIndex]
        Tracker.sharedTracker.streamAppeared(stream.name)

        if !streamLoaded[index] {
            streamLoaded[index] = true
            childStreamControllers[index].loadInitialPage()
        }
    }

    // MARK: - IBActions
    let drawerAnimator = DrawerAnimator()

    @IBAction func hamburgerButtonTapped() {
        let drawer = DrawerViewController()
        drawer.currentUser = currentUser

        drawer.transitioningDelegate = drawerAnimator
        drawer.modalPresentationStyle = .Custom

        self.presentViewController(drawer, animated: true, completion: nil)
    }

    @IBAction func streamSegmentTapped(sender: UISegmentedControl) {
        showSegmentIndex(sender.selectedSegmentIndex)
    }
}

public extension StreamContainerViewController {

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
            if let vc = self.friendsViewController {
                ElloHUD.showLoadingHudInView(vc.view)
                vc.loadInitialPage()
            }
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
