////
///  ProfileViewController.swift
//

import FLAnimatedImage


final class ProfileViewController: StreamableViewController {
    override func trackerName() -> String? { return "Profile" }
    override func trackerProps() -> [String: AnyObject]? {
        if let user = user {
            return ["username": user.username as AnyObject]
        }
        return nil
    }

    override var tabBarItem: UITabBarItem? {
        get { return UITabBarItem.item(.person) }
        set { self.tabBarItem = newValue }
    }

    var _mockScreen: ProfileScreenProtocol?
    var screen: ProfileScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return _mockScreen ?? self.view as! ProfileScreenProtocol }
    }

    var user: User?
    var headerItems: [StreamCellItem]?
    var responseConfig: ResponseConfig?
    var userParam: String
    var coverImageHeightStart: CGFloat?
    let initialStreamKind: StreamKind
    var currentUserChangedNotification: NotificationObserver?
    var relationshipChangedNotification: NotificationObserver?
    var deeplinkPath: String?
    var generator: ProfileGenerator?
    fileprivate var isSetup = false

    init(userParam: String, username: String? = nil) {
        self.userParam = userParam
        self.initialStreamKind = .userStream(userParam: self.userParam)
        super.init(nibName: nil, bundle: nil)

        if let username = username {
            title = "@\(username)"
        }

        if self.user == nil {
            if let user = ElloLinkedStore.sharedInstance.getObject(self.userParam, type: .usersType) as? User {
                self.user = user
            }
        }

        sharedInit()

        relationshipChangedNotification = NotificationObserver(notification: RelationshipChangedNotification) { [unowned self] user in
            if self.user?.id == user.id {
                self.updateRelationshipPriority(user.relationshipPriority)
            }
        }
    }

    // this should only be initialized this way for currentUser in tab nav
    init(user: User) {
        // this user must have the profile property assigned (since it is currentUser)
        self.user = user
        self.userParam = user.id
        self.initialStreamKind = .currentUserStream
        super.init(nibName: nil, bundle: nil)

        sharedInit()
        currentUserChangedNotification = NotificationObserver(notification: CurrentUserChangedNotification) { [unowned self] _ in
            self.updateCachedImages()
        }
    }

    fileprivate func sharedInit() {
        streamViewController.streamKind = initialStreamKind
        streamViewController.initialLoadClosure = { [weak self] in self?.loadProfile() }
        streamViewController.reloadClosure = { [weak self] in self?.reloadEntireProfile() }
        streamViewController.toggleClosure = { [weak self] isGridView in self?.toggleGrid(isGridView) }

        generator = ProfileGenerator(
            currentUser: currentUser,
            userParam: userParam,
            user: user,
            streamKind: initialStreamKind,
            destination: self
        )
    }

    deinit {
        currentUserChangedNotification?.removeObserver()
        currentUserChangedNotification = nil
        relationshipChangedNotification?.removeObserver()
        relationshipChangedNotification = nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if user == nil {
            screen.disableButtons()
        }
        view.clipsToBounds = true
        setupNavigationItems()
        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.loadInitialPage()
        screen.relationshipDelegate = streamViewController.dataSource.relationshipDelegate

        if let user = user {
            updateUser(user)
        }
    }

    override func loadView() {
        let screen = ProfileScreen()
        screen.delegate = self
        screen.navigationItem = elloNavigationItem
        self.view = screen
        viewContainer = screen.streamContainer
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let ratio: CGFloat = ProfileHeaderCellSizeCalculator.ratio
        let headerHeight: CGFloat = view.frame.width / ratio
        let scrollAdjustedHeight = headerHeight - streamViewController.collectionView.contentOffset.y
        let maxHeaderHeight = max(scrollAdjustedHeight, headerHeight)
        screen.updateHeaderHeightConstraints(max: maxHeaderHeight, scrollAdjusted: scrollAdjustedHeight)

        coverImageHeightStart = scrollAdjustedHeight
    }

    override func didSetCurrentUser() {
        generator?.currentUser = currentUser
        super.didSetCurrentUser()
    }

    override func showNavBars() {
        super.showNavBars()
        positionNavBar(screen.navigationBar, visible: true, withConstraint: screen.navigationBarTopConstraint)
        updateInsets()

        screen.showNavBars()
    }

    override func hideNavBars() {
        super.hideNavBars()
        positionNavBar(screen.navigationBar, visible: false, withConstraint: screen.navigationBarTopConstraint, animated: true)
        updateInsets()

        let offset = self.streamViewController.collectionView.contentOffset
        let currentUser = (self.user?.id == self.currentUser?.id && self.user?.id != nil)
        screen.hideNavBars(offset, isCurrentUser: currentUser)
    }

    fileprivate func updateInsets() {
        updateInsets(navBar: screen.topInsetView, streamController: streamViewController)
    }

    // MARK : private

    fileprivate func loadProfile() {
        generator?.load()
    }

    fileprivate func reloadEntireProfile() {
        screen.resetCoverImage()
        generator?.load(reload: true)
    }

    fileprivate func showUserLoadFailure() {
        let message = InterfaceString.GenericError
        let alertController = AlertViewController(message: message)
        let action = AlertAction(title: InterfaceString.OK, style: .dark) { _ in
            _ = self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(action)
        logPresentingAlert("ProfileViewController")
        present(alertController, animated: true, completion: nil)
    }

    fileprivate func setupNavigationItems() {
        let backItem = UIBarButtonItem.backChevron(withController: self)
        let gridListItem = UIBarButtonItem.gridListItem(delegate: streamViewController, isGridView: streamViewController.streamKind.isGridView)
        let shareItem = UIBarButtonItem(image: .share, target: self, action: #selector(ProfileViewController.sharePostTapped(_:)))
        let moreActionsItem = UIBarButtonItem(image: .dots, target: self, action: #selector(ProfileViewController.moreButtonTapped))
        let isCurrentUser = userParam == currentUser?.id || userParam == "~\(currentUser)"

        if !isRootViewController() {
            var leftBarButtonItems: [UIBarButtonItem] = []
            leftBarButtonItems.append(UIBarButtonItem.spacer(width: -17))
            leftBarButtonItems.append(backItem)
            if !isCurrentUser {
                leftBarButtonItems.append(UIBarButtonItem.spacer(width: -17))
                leftBarButtonItems.append(moreActionsItem)
            }
            elloNavigationItem.leftBarButtonItems = leftBarButtonItems
        }

        guard !isCurrentUser else {
            elloNavigationItem.rightBarButtonItems = [shareItem, gridListItem]
            return
        }

        guard
            let user = user,
            let currentUser = currentUser, user.id != currentUser.id else {
            elloNavigationItem.rightBarButtonItems = []
            return
        }

        var rightBarButtonItems: [UIBarButtonItem] = []
        if user.hasSharingEnabled {
            rightBarButtonItems.append(shareItem)
        }
        rightBarButtonItems.append(gridListItem)

        if !elloNavigationItem.areRightButtonsTheSame(rightBarButtonItems) {
            elloNavigationItem.rightBarButtonItems = rightBarButtonItems
        }
    }

    func moreButtonTapped() {
        guard let user = user else { return }

        let userId = user.id
        let userAtName = user.atName
        let prevRelationshipPriority = user.relationshipPriority
        streamViewController.relationshipController?.launchBlockModal(userId, userAtName: userAtName, relationshipPriority: prevRelationshipPriority) { newRelationshipPriority in
            user.relationshipPriority = newRelationshipPriority
        }
    }

    func sharePostTapped(_ sourceView: UIView) {
        guard let user = user,
            let shareLink = user.shareLink,
            let shareURL = URL(string: shareLink)
        else { return }

        Tracker.shared.userShared(user)
        let activityVC = UIActivityViewController(activityItems: [shareURL], applicationActivities: [SafariActivity()])
        if UI_USER_INTERFACE_IDIOM() == .phone {
            activityVC.modalPresentationStyle = .fullScreen
            logPresentingAlert(readableClassName())
            present(activityVC, animated: true) { }
        }
        else {
            activityVC.modalPresentationStyle = .popover
            activityVC.popoverPresentationController?.sourceView = sourceView
            logPresentingAlert(readableClassName())
            present(activityVC, animated: true) { }
        }
    }

    func toggleGrid(_ isGridView: Bool) {
        generator?.toggleGrid()
    }

}

extension ProfileViewController: ProfileScreenDelegate {
    func mentionTapped() {
        guard let user = user else { return }

        createPost(text: "\(user.atName) ", fromController: self)
    }

    func hireTapped() {
        guard let user = user else { return }

        Tracker.shared.tappedHire(user)
        let vc = HireViewController(user: user, type: .hire)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func editTapped() {
        onEditProfile()
    }

    func inviteTapped() {
        onInviteFriends()
    }

    func collaborateTapped() {
        guard let user = user else { return }

        Tracker.shared.tappedCollaborate(user)
        let vc = HireViewController(user: user, type: .collaborate)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: Check for cached coverImage and avatar (only for currentUser)
extension ProfileViewController {
    func cachedImage(_ key: CacheKey) -> UIImage? {
        guard user?.id == currentUser?.id else {
            return nil
        }
        return TemporaryCache.load(key)
    }

    func updateCachedImages() {
        guard let cachedImage = cachedImage(.coverImage) else {
            return
        }

        screen.coverImage = cachedImage
    }

    func updateUser(_ user: User) {
        screen.enableButtons()

        guard user.id == self.currentUser?.id else {
            screen.configureButtonsForNonCurrentUser(isHireable: user.isHireable, isCollaborateable: user.isCollaborateable)
            return
        }

        // only update the avatar and coverImage assets if there is nothing
        // in the cache.  If images are in the cache, that implies that the
        // image could still be unprocessed, so don't set the avatar or
        // coverImage to the old, stale value.
        if cachedImage(.avatar) == nil {
            self.currentUser?.avatar = user.avatar
        }

        if cachedImage(.coverImage) == nil {
            self.currentUser?.coverImage = user.coverImage
        }

        screen.configureButtonsForCurrentUser()
    }

    func updateRelationshipPriority(_ relationshipPriority: RelationshipPriority) {
        screen.updateRelationshipPriority(relationshipPriority)
        self.user?.relationshipPriority = relationshipPriority
    }
}

// MARK: ProfileViewController: PostsTappedResponder
extension ProfileViewController: PostsTappedResponder {
    func onPostsTapped() {
        let indexPath = IndexPath(item: 1, section: 0)
        guard streamViewController.dataSource.isValidIndexPath(indexPath) else { return }
        streamViewController.collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.top, animated: true)
    }
}

// MARK: ProfileHeaderResponder
extension ProfileViewController: ProfileHeaderResponder {

    func onCategoryBadgeTapped(_ cell: UICollectionViewCell) {
        guard
            let categories = user?.categories,
            let count = user?.categories?.count,
            count > 0
        else { return }

        let vc = ProfileCategoriesViewController(categories: categories)
        vc.currentUser = currentUser
        let navVC = ElloNavigationController(rootViewController: vc)
        navVC.modalTransitionStyle = .crossDissolve
        navVC.modalPresentationStyle = .custom
        navVC.transitioningDelegate = vc
        present(navVC, animated: true, completion: nil)
    }

    func onLovesTapped(_ cell: UICollectionViewCell) {
        guard let user = self.user else { return }

        let noResultsTitle: String
        let noResultsBody: String
        if user.id == currentUser?.id {
            noResultsTitle = InterfaceString.Loves.CurrentUserNoResultsTitle
            noResultsBody = InterfaceString.Loves.CurrentUserNoResultsBody
        }
        else {
            noResultsTitle = InterfaceString.Loves.NoResultsTitle
            noResultsBody = InterfaceString.Loves.NoResultsBody
        }

        streamViewController.showSimpleStream(
            boxedEndpoint: BoxedElloAPI(endpoint: .loves(userId: user.id)),
            title: InterfaceString.Loves.Title,
            noResultsMessages: NoResultsMessages(title: noResultsTitle, body: noResultsBody)
        )
    }

    func onFollowersTapped(_ cell: UICollectionViewCell) {
        guard let user = self.user else { return }

        let noResultsTitle: String
        let noResultsBody: String
        if user.id == currentUser?.id {
            noResultsTitle = InterfaceString.Followers.CurrentUserNoResultsTitle
            noResultsBody = InterfaceString.Followers.CurrentUserNoResultsBody
        }
        else {
            noResultsTitle = InterfaceString.Followers.NoResultsTitle
            noResultsBody = InterfaceString.Followers.NoResultsBody
        }

        streamViewController.showSimpleStream(
            boxedEndpoint: BoxedElloAPI(endpoint: .userStreamFollowers(userId: user.id)),
            title: InterfaceString.Followers.Title,
            noResultsMessages: NoResultsMessages(title: noResultsTitle, body: noResultsBody)
        )
    }

    func onFollowingTapped(_ cell: UICollectionViewCell) {
        guard let user = user else { return }

        let noResultsTitle: String
        let noResultsBody: String
        if user.id == currentUser?.id {
            noResultsTitle = InterfaceString.Following.CurrentUserNoResultsTitle
            noResultsBody = InterfaceString.Following.CurrentUserNoResultsBody
        }
        else {
            noResultsTitle = InterfaceString.Following.NoResultsTitle
            noResultsBody = InterfaceString.Following.NoResultsBody
        }

        streamViewController.showSimpleStream(
            boxedEndpoint: BoxedElloAPI(endpoint: .userStreamFollowing(userId: user.id)),
            title: InterfaceString.Following.Title,
            noResultsMessages: NoResultsMessages(title: noResultsTitle, body: noResultsBody)
        )
    }}


// MARK: ProfileViewController: EditProfileResponder
extension ProfileViewController: EditProfileResponder {

    func onEditProfile() {
        guard let settings = UIStoryboard(name: "Settings", bundle: .none).instantiateInitialViewController() as? SettingsContainerViewController else { return }
        settings.currentUser = currentUser
        navigationController?.pushViewController(settings, animated: true)
    }
}

// MARK: ProfileViewController: StreamViewDelegate
extension ProfileViewController {

    override func streamViewDidScroll(scrollView: UIScrollView) {
        if let start = coverImageHeightStart {
            screen.updateHeaderHeightConstraints(max: max(start - scrollView.contentOffset.y, start), scrollAdjusted: start - scrollView.contentOffset.y)
        }
        super.streamViewDidScroll(scrollView: scrollView)
    }
}

// MARK: ProfileViewController: StreamDestination
extension ProfileViewController:  StreamDestination {

    var pagingEnabled: Bool {
        get { return streamViewController.pagingEnabled }
        set { streamViewController.pagingEnabled = newValue }
    }

    func replacePlaceholder(type: StreamCellType.PlaceholderType, items: [StreamCellItem], completion: @escaping ElloEmptyCompletion) {
        streamViewController.replacePlaceholder(type, with: items) {
            if self.streamViewController.hasCellItems(for: .profileHeader) && !self.streamViewController.hasCellItems(for: .profilePosts) {
                self.streamViewController.replacePlaceholder(.profilePosts, with: [StreamCellItem(type: .streamLoading)]) {}
            }

            completion()
        }
    }

    func setPlaceholders(items: [StreamCellItem]) {
        streamViewController.clearForInitialLoad()
        streamViewController.appendStreamCellItems(items)
        setupNavigationItems()
    }

    func setPrimary(jsonable: JSONAble) {
        guard let user = jsonable as? User else { return }

        self.user = user
        updateUser(user)
        streamViewController.doneLoading()

        userParam = user.id
        title = user.atName

        setupNavigationItems()

        screen.updateRelationshipControl(user: user)

        if let cachedImage = cachedImage(.coverImage) {
            screen.coverImage = cachedImage
        }
        else if let coverImageURL = user.coverImageURL(viewsAdultContent: currentUser?.viewsAdultContent, animated: true)
        {
            screen.coverImageURL = coverImageURL
        }
    }

    func setPagingConfig(responseConfig: ResponseConfig) {
        streamViewController.responseConfig = responseConfig
    }

    func primaryJSONAbleNotFound() {
        if let deeplinkPath = self.deeplinkPath,
            let deeplinkURL = URL(string: deeplinkPath)
        {
            UIApplication.shared.openURL(deeplinkURL)
            self.deeplinkPath = nil
            _ = self.navigationController?.popViewController(animated: true)
        }
        else {
            self.showUserLoadFailure()
        }
        self.streamViewController.doneLoading()
    }
}
