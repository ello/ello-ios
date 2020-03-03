////
///  FollowingViewController.swift
//

import PromiseKit


class FollowingViewController: StreamableViewController {
    override func trackerName() -> String? { return "Stream" }
    override func trackerProps() -> [String: Any]? {
        return ["kind": "Following"]
    }
    override func trackerStreamInfo() -> (String, String?)? {
        return ("following", nil)
    }

    private var reloadFollowingContentObserver: NotificationObserver?
    private var appBackgroundObserver: NotificationObserver?
    private var appForegroundObserver: NotificationObserver?
    private var newFollowingContentObserver: NotificationObserver?

    private var _mockScreen: FollowingScreenProtocol?
    var screen: FollowingScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return fetchScreen(_mockScreen) }
    }
    var generator: FollowingGenerator!

    required init() {
        super.init(nibName: nil, bundle: nil)
        self.title = ""
        generator = FollowingGenerator(destination: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        removeNotificationObservers()
    }

    override func loadView() {
        let screen = FollowingScreen()
        screen.delegate = self

        view = screen
        viewContainer = screen.streamContainer
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        streamViewController.initialLoadClosure = { [weak self] in self?.loadFollowing() }
        streamViewController.streamKind = .following
        setupNavigationItems(streamKind: .following)

        streamViewController.showLoadingSpinner()
        streamViewController.loadInitialPage()

        addNotificationObservers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        addTemporaryNotificationObservers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeTemporaryNotificationObservers()
    }

    private func updateInsets() {
        updateInsets(maxY: max(screen.navigationBar.frame.maxY - 14, 0))
    }

    override func showNavBars(animated: Bool) {
        super.showNavBars(animated: animated)
        positionNavBar(screen.navigationBar, visible: true, animated: animated)
        updateInsets()
    }

    override func hideNavBars(animated: Bool) {
        super.hideNavBars(animated: animated)
        positionNavBar(screen.navigationBar, visible: false, animated: animated)
        updateInsets()
    }

    override func streamWillPullToRefresh() {
        super.streamWillPullToRefresh()

        screen.newPostsButtonVisible = false
    }

    override func streamViewInfiniteScroll() -> Promise<[Model]>? {
        return generator.loadNextPage()
    }
}

extension FollowingViewController {
    private func setupNavigationItems(streamKind: StreamKind) {
        screen.navigationBar.leftItems = [.burger]
        screen.navigationBar.rightItems = [.gridList(isGrid: streamKind.isGridView)]
    }

    private func addTemporaryNotificationObservers() {
        reloadFollowingContentObserver = NotificationObserver(
            notification: NewContentNotifications.reloadFollowingContent
        ) { [weak self] in
            guard let `self` = self else { return }

            self.streamViewController.showLoadingSpinner()
            self.screen.newPostsButtonVisible = false
            self.streamViewController.loadInitialPage(reload: true)
        }
    }

    private func removeTemporaryNotificationObservers() {
        reloadFollowingContentObserver?.removeObserver()
    }

    private func addNotificationObservers() {
        newFollowingContentObserver = NotificationObserver(
            notification: NewContentNotifications.newFollowingContent
        ) { [weak self] in
            guard let `self` = self else { return }

            self.screen.newPostsButtonVisible = true
        }
    }

    private func removeNotificationObservers() {
        newFollowingContentObserver?.removeObserver()
        appBackgroundObserver?.removeObserver()
    }
}

extension FollowingViewController: StreamDestination {
    var isPagingEnabled: Bool {
        get { return streamViewController.isPagingEnabled }
        set { streamViewController.isPagingEnabled = newValue }
    }

    func loadFollowing() {
        streamViewController.isPagingEnabled = false
        generator.load()
    }

    func replacePlaceholder(
        type: StreamCellType.PlaceholderType,
        items: [StreamCellItem],
        completion: @escaping Block
    ) {
        streamViewController.replacePlaceholder(type: type, items: items, completion: completion)

        if type == .streamItems {
            streamViewController.doneLoading()
        }
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
        self.showGenericLoadFailure()
        self.streamViewController.doneLoading()
    }
}

extension FollowingViewController: FollowingScreenDelegate {
    func scrollToTop() {
        streamViewController.scrollToTop(animated: true)
    }

    func loadNewPosts() {
        let scrollView = streamViewController.collectionView
        scrollView.setContentOffset(CGPoint(x: 0, y: -scrollView.contentInset.top), animated: true)
        postNotification(NewContentNotifications.reloadFollowingContent, value: ())

        screen.newPostsButtonVisible = false
    }
}
