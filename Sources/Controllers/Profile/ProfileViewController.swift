////
///  ProfileViewController.swift
//

import PromiseKit
import FLAnimatedImage


final class ProfileViewController: StreamableViewController {
    override func trackerName() -> String? { return "Profile" }
    override func trackerProps() -> [String: Any]? {
        if let user = user {
            return ["username": user.username]
        }
        return nil
    }
    override func trackerStreamInfo() -> (String, String?)? {
        guard let streamId = user?.id else { return nil }
        return ("user", streamId)
    }

    private var _mockScreen: ProfileScreenProtocol?
    var screen: ProfileScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return fetchScreen(_mockScreen) }
    }

    var user: User?
    var headerItems: [StreamCellItem]?
    var userParam: String
    var coverImageHeightStart: CGFloat?
    var currentUserChangedNotification: NotificationObserver?
    var relationshipChangedNotification: NotificationObserver?
    var deeplinkPath: String?
    var generator: ProfileGenerator?
    private var isSetup = false

    init(userParam: String, username: String? = nil) {
        self.userParam = userParam
        super.init(nibName: nil, bundle: nil)

        if let username = username {
            title = "@\(username)"
        }

        if let user = ElloLinkedStore.shared.getObject(self.userParam, type: .usersType) as? User {
            self.user = user
        }

        sharedInit()

        relationshipChangedNotification = NotificationObserver(notification: RelationshipChangedNotification) { [unowned self] user in
            if self.user?.id == user.id {
                self.updateRelationshipPriority(user.relationshipPriority)
            }
        }
    }

    // this should only be initialized this way for currentUser in tab nav
    init(currentUser: User) {
        // this user must have the profile property assigned (since it is currentUser)
        user = currentUser
        userParam = currentUser.id
        super.init(nibName: nil, bundle: nil)

        self.currentUser = currentUser
        title = currentUser.atName
        sharedInit()
        currentUserChangedNotification = NotificationObserver(notification: CurrentUserChangedNotification) { [weak self] user in
            self?.updateCachedImages(user: user)
        }
    }

    private func sharedInit() {
        streamViewController.streamKind = .userStream(userParam: userParam)
        streamViewController.initialLoadClosure = { [weak self] in self?.loadProfile() }
        streamViewController.reloadClosure = { [weak self] in self?.reloadEntireProfile() }
        streamViewController.toggleClosure = { [weak self] isGridView in self?.toggleGrid(isGridView) }

        generator = ProfileGenerator(
            currentUser: currentUser,
            userParam: userParam,
            user: user,
            destination: self
        )
    }

    deinit {
        currentUserChangedNotification?.removeObserver()
        currentUserChangedNotification = nil
        relationshipChangedNotification?.removeObserver()
        relationshipChangedNotification = nil
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let screen = ProfileScreen()
        screen.delegate = self
        screen.clipsToBounds = true
        screen.hasRoleAdminButton = currentUser?.canModifyAnyCategoryRole ?? false
        view = screen
        viewContainer = screen.streamContainer
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupNavigationItems()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if user == nil {
            screen.disableButtons()
        }
        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.loadInitialPage()

        if let user = user {
            updateUser(user)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let ratio: CGFloat = ProfileHeaderAvatarCell.Size.ratio
        let headerHeight: CGFloat = view.frame.width / ratio
        let scrollAdjustedHeight = headerHeight - streamViewController.collectionView.contentOffset.y
        let maxHeaderHeight = max(scrollAdjustedHeight, headerHeight)
        screen.updateHeaderHeightConstraints(max: maxHeaderHeight, scrollAdjusted: scrollAdjustedHeight)

        coverImageHeightStart = scrollAdjustedHeight
    }

    override func didSetCurrentUser() {
        super.didSetCurrentUser()
        generator?.currentUser = currentUser
        if user?.id == currentUser?.id && isViewLoaded {
            reloadEntireProfile()
        }
    }

    override func showNavBars(animated: Bool) {
        super.showNavBars(animated: animated)
        positionNavBar(screen.navigationBar, visible: true, withConstraint: screen.navigationBarTopConstraint, animated: animated)
        screen.showNavBars(animated: animated)
        updateInsets()
    }

    override func hideNavBars(animated: Bool) {
        super.hideNavBars(animated: animated)
        positionNavBar(screen.navigationBar, visible: false, withConstraint: screen.navigationBarTopConstraint, animated: animated)

        let offset = self.streamViewController.collectionView.contentOffset
        let currentUser = (self.user?.id == self.currentUser?.id && self.user?.id != nil)
        screen.hideNavBars(offset, isCurrentUser: currentUser)
        updateInsets()
    }

    private func updateInsets() {
        updateInsets(navBar: screen.topInsetView)
    }

    private func loadProfile() {
        generator?.load()
    }

    private func reloadEntireProfile() {
        if isViewLoaded {
            screen.resetCoverImage()
        }
        generator?.load(reload: true)
    }

    private func setupNavigationItems() {
        let gridListItem = ElloNavigationBar.Item.gridList(isGrid: streamViewController.streamKind.isGridView)
        let isCurrentUser = userParam == currentUser?.id || userParam == currentUser.map { "~\($0.username)" }

        var leftItems: [ElloNavigationBar.Item] = []
        if !isRootViewController() {
            leftItems.append(.back)
            screen.hasBackButton = true

            if !isCurrentUser, currentUser != nil {
                leftItems.append(.more)
            }
        }
        screen.navigationBar.leftItems = leftItems

        if isCurrentUser {
            screen.navigationBar.rightItems = [.share, gridListItem]
        }
        else if
            let user = user,
            user.id != currentUser?.id
        {
            var rightItems: [ElloNavigationBar.Item] = []
            if user.hasSharingEnabled {
                rightItems.append(.share)
            }
            rightItems.append(gridListItem)

            screen.navigationBar.rightItems = rightItems
        }
        else {
            screen.navigationBar.rightItems = []
        }
    }

    func toggleGrid(_ isGridView: Bool) {
        generator?.toggleGrid()
    }

    override func streamViewDidScroll(scrollView: UIScrollView) {
        if let start = coverImageHeightStart {
            screen.updateHeaderHeightConstraints(max: max(start - scrollView.contentOffset.y, start), scrollAdjusted: start - scrollView.contentOffset.y)
        }
        super.streamViewDidScroll(scrollView: scrollView)
    }

    override func streamViewInfiniteScroll() -> Promise<[Model]>? {
        return generator?.loadNextPage()
    }
}

extension ProfileViewController: ProfileScreenDelegate {
    func mentionTapped() {
        guard currentUser != nil else {
            postNotification(LoggedOutNotifications.userActionAttempted, value: .postTool)
            return
        }
        guard let user = user else { return }

        let text = "\(user.atName) "
        createPost(text: text, fromController: self)
    }

    func hireTapped() {
        guard currentUser != nil else {
            postNotification(LoggedOutNotifications.userActionAttempted, value: .postTool)
            return
        }
        guard let user = user else { return }

        Tracker.shared.tappedHire(user)
        let vc = HireViewController(user: user, type: .hire)
        vc.currentUser = currentUser
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func editTapped() {
        guard currentUser != nil else {
            postNotification(LoggedOutNotifications.userActionAttempted, value: .postTool)
            return
        }
        onEditProfile()
    }

    func inviteTapped() {
        let responder: InviteResponder? = findResponder()
        responder?.onInviteFriends()
    }

    func collaborateTapped() {
        guard currentUser != nil else {
            postNotification(LoggedOutNotifications.userActionAttempted, value: .postTool)
            return
        }
        guard let user = user else { return }

        Tracker.shared.tappedCollaborate(user)
        let vc = HireViewController(user: user, type: .collaborate)
        vc.currentUser = currentUser
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func roleAdminTapped() {
        guard
            let user = user, let currentUser = currentUser,
            currentUser.canModifyAnyCategoryRole
        else { return }

        postNotification(StatusBarNotifications.statusBarVisibility, value: true)
        showNavBars(animated: true)
        let vc = RoleAdminViewController(user: user)
        vc.currentUser = currentUser
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ProfileViewController {
    func cachedImage(_ key: Profile.ImageProperty) -> UIImage? {
        guard user?.id == currentUser?.id else {
            return nil
        }
        return TemporaryCache.load(key)
    }

    func updateCachedImages(user: User) {
        guard isViewLoaded else { return }

        if let cachedCoverImage = cachedImage(.coverImage) {
            screen.coverImage = cachedCoverImage
        }
        else if let coverImageURL = user.coverImageURL(viewsAdultContent: currentUser?.viewsAdultContent, animated: true) {
            screen.coverImageURL = coverImageURL
        }
    }

    func updateUser(_ user: User) {
        guard isViewLoaded else { return }
        screen.enableButtons()
        screen.hasRoleAdminButton = currentUser?.canModifyAnyCategoryRole ?? false

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

extension ProfileViewController: PostsTappedResponder {
    func onPostsTapped() {
        guard
            let indexPath = streamViewController.collectionViewDataSource.firstIndexPath(forPlaceholderType: .streamItems)
        else { return }

        streamViewController.collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.top, animated: true)
    }
}

extension ProfileViewController: ProfileHeaderResponder {

    func onCategoryBadgeTapped() {
        guard
            let categories = user?.categories,
            let count = user?.categories?.count,
            count > 0,
            let badge = Badge.lookup(slug: "featured")
        else { return }

        Tracker.shared.badgeOpened(badge.slug)
        let vc = ProfileCategoriesViewController(categories: categories)
        vc.presentingVC = self
        presentModal(vc)
    }

    func onBadgeTapped(_ badgeName: String) {
        guard let badge = Badge.lookup(slug: badgeName) else { return }

        Tracker.shared.badgeOpened(badge.slug)
        let vc = ProfileBadgeViewController(badge: badge)
        presentModal(vc)
    }

    private func presentModal(_ vc: BaseElloViewController) {
        vc.currentUser = currentUser
        // vc.presentingVC = self
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = vc as? UIViewControllerTransitioningDelegate
        present(vc, animated: true, completion: nil)
    }

    func onMoreBadgesTapped() {
        guard
            let user = self.user,
            user.badges.count > 3
        else { return }

        let badgesViewController = BadgesViewController(user: user)
        badgesViewController.currentUser = currentUser
        navigationController?.pushViewController(badgesViewController, animated: true)
    }

    func onLovesTapped() {
        guard let username = user?.username else { return }

        let vc = LovesViewController(username: username)
        vc.currentUser = currentUser
        navigationController?.pushViewController(vc, animated: true)
    }

    func onFollowersTapped() {
        guard let user = self.user else { return }

        streamViewController.showSimpleStream(
            boxedEndpoint: BoxedElloAPI(endpoint: .userStreamFollowers(userId: user.id)),
            title: InterfaceString.Followers.Title
        )
    }

    func onFollowingTapped() {
        guard let user = user else { return }

        streamViewController.showSimpleStream(
            boxedEndpoint: BoxedElloAPI(endpoint: .userStreamFollowing(userId: user.id)),
            title: InterfaceString.Following.Title
        )
    }}


extension ProfileViewController: EditProfileResponder {

    func onEditProfile() {
        guard let currentUser = currentUser else {
            postNotification(LoggedOutNotifications.userActionAttempted, value: .postTool)
            return
        }

        let settingsViewController = SettingsViewController(currentUser: currentUser)
        navigationController?.pushViewController(settingsViewController, animated: true)
    }
}

extension ProfileViewController: StreamDestination {

    var isPagingEnabled: Bool {
        get { return streamViewController.isPagingEnabled }
        set { streamViewController.isPagingEnabled = newValue }
    }

    func replacePlaceholder(type: StreamCellType.PlaceholderType, items: [StreamCellItem], completion: @escaping Block) {
        streamViewController.replacePlaceholder(type: type, items: items) {
            if self.streamViewController.hasCellItems(for: .profileHeader) && !self.streamViewController.hasCellItems(for: .streamItems) {
                self.streamViewController.replacePlaceholder(type: .streamItems, items: [StreamCellItem(type: .streamLoading)])
            }

            completion()
        }
    }

    func setPlaceholders(items: [StreamCellItem]) {
        streamViewController.clearForInitialLoad(newItems: items)
        setupNavigationItems()
    }

    func setPrimary(jsonable: Model) {
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
        else if let coverImageURL = user.coverImageURL(viewsAdultContent: currentUser?.viewsAdultContent, animated: true) {
            screen.coverImageURL = coverImageURL
        }
    }

    func setPagingConfig(responseConfig: ResponseConfig) {
        streamViewController.responseConfig = responseConfig
    }

    func primaryModelNotFound() {
        if let deeplinkPath = self.deeplinkPath,
            let deeplinkURL = URL(string: deeplinkPath)
        {
            UIApplication.shared.openURL(deeplinkURL)
            self.deeplinkPath = nil
            _ = self.navigationController?.popViewController(animated: true)
        }
        else {
            self.showGenericLoadFailure()
        }
        self.streamViewController.doneLoading()
    }
}

extension ProfileViewController: HasMoreButton {
    func moreButtonTapped() {
        guard currentUser != nil else {
            postNotification(LoggedOutNotifications.userActionAttempted, value: .postTool)
            return
        }
        guard let user = user else { return }

        let userId = user.id
        let userAtName = user.atName
        let prevRelationshipPriority = RelationshipPriorityWrapper(priority: user.relationshipPriority)

        let responder: RelationshipResponder? = findResponder()
        responder?.launchBlockModal(
            userId,
            userAtName: userAtName,
            relationshipPriority: prevRelationshipPriority
        ) { newRelationshipPriority in
            user.relationshipPriority = newRelationshipPriority.priority
        }
    }
}

extension ProfileViewController: HasShareButton {
    func shareButtonTapped(_ sender: UIView) {
        guard
            let user = user,
            let shareURL = URL(string: user.shareLink)
        else { return }

        Tracker.shared.userShared(user)
        showShareActivity(sender: sender, url: shareURL)
    }
}
