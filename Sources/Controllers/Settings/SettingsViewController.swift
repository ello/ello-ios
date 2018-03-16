////
///  SettingsViewController.swift
//

class SettingsViewController: BaseElloViewController {
    private var _mockScreen: SettingsScreenProtocol?
    var screen: SettingsScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return fetchScreen(_mockScreen) }
    }

    let generator: SettingsGenerator
    var scrollLogic: ElloScrollLogic!
    var categories: [Category]?

    var autoCompleteVC = AutoCompleteViewController()
    var locationTextViewSelected = false {
        didSet {
            updateAutoCompleteFrame(animated: true)
        }
    }
    var locationAutoCompleteResultCount = 0 {
        didSet {
            updateAutoCompleteFrame(animated: false)
        }
    }

    private var keyboardWillShowObserver: NotificationObserver?
    private var keyboardDidHideObserver: NotificationObserver?
    private var keyboardWillHideObserver: NotificationObserver?
    private var blockedCountChangedNotification: NotificationObserver?
    private var mutedCountChangedNotification: NotificationObserver?

    init(currentUser: User) {
        generator = SettingsGenerator(currentUser: currentUser)
        super.init(nibName: nil, bundle: nil)

        scrollLogic = ElloScrollLogic(
                onShow: { [weak self] in self?.showNavBars(animated: true) },
                onHide: { [weak self] in self?.hideNavBars(animated: true) }
            )

        self.currentUser = currentUser
        generator.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        blockedCountChangedNotification?.removeObserver()
        mutedCountChangedNotification?.removeObserver()
    }

    override func loadView() {
        let screen = SettingsScreen()
        screen.delegate = self
        view = screen
    }

    override func didSetCurrentUser() {
        super.didSetCurrentUser()
        updateScreenFromUser()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        generator.load(reload: false)

        autoCompleteVC.delegate = self
        autoCompleteVC.view.alpha = 0

        updateScreenFromUser()

        blockedCountChangedNotification = NotificationObserver(notification: BlockedCountChangedNotification) { [unowned self] userId, delta in
            self.blockedMutedCountChanged(deltaBlocked: delta, deltaMuted: 0)
        }
        mutedCountChangedNotification = NotificationObserver(notification: MutedCountChangedNotification) { [unowned self] userId, delta in
            self.blockedMutedCountChanged(deltaBlocked: 0, deltaMuted: delta)
        }

        ElloHUD.showLoadingHudInView(self.view)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        keyboardWillShowObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillShow, block: self.keyboardWillShow)
        keyboardDidHideObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardDidHide, block: self.keyboardDidHide)
        keyboardWillHideObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillHide, block: self.keyboardWillHide)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        autoCompleteVC.view.removeFromSuperview()

        keyboardWillShowObserver?.removeObserver()
        keyboardWillShowObserver = nil
        keyboardDidHideObserver?.removeObserver()
        keyboardDidHideObserver = nil
        keyboardWillHideObserver?.removeObserver()
        keyboardWillHideObserver = nil
    }

    override func showNavBars(animated: Bool) {
        super.showNavBars(animated: animated)
        screen.showNavBars(animated: true)
    }

    override func hideNavBars(animated: Bool) {
        super.hideNavBars(animated: animated)
        screen.hideNavBars(animated: true)
    }

    override func closeButtonTapped() {
        if pendingChanges().count > 0 {
            let alertController = AlertViewController(message: InterfaceString.Settings.AbortChanges)

            let okCancelAction = AlertAction(style: .okCancel) { _ in
                super.backButtonTapped()
            }
            alertController.addAction(okCancelAction)

            self.present(alertController, animated: true, completion: nil)
        }
        else {
            super.backButtonTapped()
        }
    }

    override func backButtonTapped() {
        let profileUpdates = pendingChanges()
        guard profileUpdates.count > 0 else {
            super.backButtonTapped()
            return
        }

        saveAndExit(profileUpdates)
    }

    private func pendingChanges() -> [Profile.Property: Any] {
        var profileUpdates: [Profile.Property: Any] = [:]
        guard let currentUser = currentUser, let profile = currentUser.profile else { return profileUpdates }

        if !(currentUser.name =?= screen.name) {
            profileUpdates[.name] = screen.name ?? ""
        }

        if !(profile.shortBio =?= screen.bio) {
            profileUpdates[.bio] = screen.bio ?? ""
        }

        if !(currentUser.externalLinksString =?= screen.links) {
            profileUpdates[.links] = screen.links ?? ""
        }

        if !(currentUser.location =?= screen.location) {
            profileUpdates[.location] = screen.location ?? ""
        }

        return profileUpdates
    }

    private func saveAndExit(_ profileUpdates: [Profile.Property: Any]) {
        view.isUserInteractionEnabled = false
        ElloHUD.showLoadingHudInView(view)

        ProfileService().updateUserProfile(profileUpdates)
            .then { user -> Void in
                self.appViewController?.currentUser = user
                super.backButtonTapped()
            }
            .catch { error in
                if let error = (error as NSError).elloError,
                    let messages = error.attrs?.flatMap({ attr, messages in return messages })
                {
                    let errorMessage = messages.joined(separator: "\n")
                    self.screen.showError(errorMessage)
                }
                else {
                    self.screen.showError(InterfaceString.UnknownError)
                }

                self.view.isUserInteractionEnabled = true
            }
            .always {
                ElloHUD.hideLoadingHudInView(self.view)
            }
    }

    private func updateScreenFromUser() {
        guard let currentUser = currentUser,
            let profile = currentUser.profile,
            isViewLoaded
        else {
            return
        }

        screen.username = currentUser.username
        screen.email = profile.email
        screen.name = currentUser.name
        screen.bio = profile.shortBio
        screen.links = currentUser.externalLinksString
        screen.location = currentUser.location

        if let cachedImage: UIImage = TemporaryCache.load(.coverImage) {
            screen.setImage(.coverImage, image: cachedImage)
        }
        else if let imageURL = currentUser.coverImageURL(viewsAdultContent: true, animated: true) {
            screen.setImage(.coverImage, url: imageURL)
        }

        if let cachedImage: UIImage = TemporaryCache.load(.avatar) {
            screen.setImage(.avatar, image: cachedImage)
        }
        else if let imageURL = currentUser.avatar?.large?.url {
            screen.setImage(.avatar, url: imageURL)
        }

        screen.updateAllSettings(
            blockCount: profile.blockedCount,
            mutedCount: profile.mutedCount
            )
    }
}

extension SettingsViewController: SettingsScreenDelegate {
    func dismissController() {
        dismiss(animated: true, completion: nil)
    }

    func present(controller: UIViewController) {
        present(controller, animated: true, completion: nil)
    }

    func saveImage(_ imageRegion: ImageRegionData, property: Profile.ImageProperty) {
        ElloHUD.showLoadingHudInView(view)
        ProfileService().updateUserImage(property, imageRegion: imageRegion)
            .then { [weak self] url, _ -> Void in
                guard let `self` = self else { return }

                if let user = self.currentUser {
                    let asset = Asset(url: url)
                    user.coverImage = asset

                    postNotification(CurrentUserChangedNotification, value: user)
                }

                if imageRegion.isAnimatedGif {
                    self.screen.setImage(property, url: url)
                }
                else {
                    self.screen.setImage(property, image: imageRegion.image)
                }

                let message: String
                if property == .coverImage {
                    message = InterfaceString.Settings.CoverImageUploaded
                }
                else {
                    message = InterfaceString.Settings.AvatarUploaded
                }

                let alertController = AlertViewController(confirmation: message)
                self.present(alertController, animated: true, completion: nil)
            }
            .always {
                ElloHUD.hideLoadingHudInView(self.view)
            }
    }

    func logoutTapped() {
        Tracker.shared.tappedLogout()
        postNotification(AuthenticationNotifications.userLoggedOut, value: ())
    }

    func showCredentialsScreen() {
        guard let currentUser = currentUser else { return }
        let controller = SettingsCredentialsViewController(currentUser: currentUser)
        navigationController?.pushViewController(controller, animated: true)
    }

    func showDynamicSettings(_ settingsCategory: DynamicSettingCategory) {
        guard let currentUser = currentUser else { return }

        let controller: UIViewController
        switch settingsCategory.section {
        case .creatorType:
            guard
                let categoryIds = currentUser.profile?.creatorTypeCategoryIds,
                let categories = categories
            else { return }

            let creatorCategories = categoryIds.flatMap { id -> Category? in
                return categories.find { $0.id == id }
            }

            let creatorTypeController = OnboardingCreatorTypeViewController()
            creatorTypeController.delegate = self
            let creatorType: Profile.CreatorType
            if creatorCategories.count > 0 {
                creatorType = .artist(creatorCategories)
            }
            else {
                creatorType = .fan
            }
            creatorTypeController.creatorType = creatorType
            controller = creatorTypeController

        case .dynamicSettings, .accountDeletion:
            let dynamicSettingsController = DynamicSettingsViewController(category: settingsCategory)
            dynamicSettingsController.currentUser = currentUser
            controller = dynamicSettingsController

        case .blocked:
            let streamController = SimpleStreamViewController(endpoint: .currentUserBlockedList, title: InterfaceString.Settings.BlockedTitle)
            controller = streamController

        case .muted:
            let streamController = SimpleStreamViewController(endpoint: .currentUserMutedList, title: InterfaceString.Settings.MutedTitle)
            controller = streamController

        }

        (controller as? ControllerThatMightHaveTheCurrentUser)?.currentUser = currentUser

        navigationController?.pushViewController(controller, animated: true)
    }

    func locationChanged(isFirstResponder: Bool, text locationText: String) {
        locationTextViewSelected = isFirstResponder
        guard isFirstResponder else {
            updateAutoCompleteFrame(animated: true)
            return
        }

        autoCompleteVC.load(AutoCompleteMatch(type: .location, range: locationText.startIndex ..< locationText.endIndex, text: locationText)) { count in
            guard locationText == self.screen.location else { return }
            self.locationAutoCompleteResultCount = count
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollLogic.scrollViewDidScroll(scrollView)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollLogic.scrollViewWillBeginDragging(scrollView)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate: Bool) {
        scrollLogic.scrollViewDidEndDragging(scrollView, willDecelerate: willDecelerate)
    }
}

extension SettingsViewController {
    func keyboardWillShow(_ keyboard: Keyboard) {
        screen.keyboardUpdated(keyboard)
        updateAutoCompleteFrame(animated: true)
    }

    func keyboardDidHide(_ keyboard: Keyboard) {
        screen.keyboardUpdated(keyboard)
    }

    func keyboardWillHide(_ keyboard: Keyboard) {
        updateAutoCompleteFrame(animated: true)
    }
}

extension SettingsViewController: SettingsGeneratorDelegate {
    func blockedMutedCountChanged(deltaBlocked: Int, deltaMuted: Int) {
        currentUser?.profile?.blockedCount += deltaBlocked
        currentUser?.profile?.mutedCount += deltaMuted

        screen.updateAllSettings(
            blockCount: currentUser?.profile?.blockedCount ?? 0,
            mutedCount: currentUser?.profile?.mutedCount ?? 0
            )
    }

    func currentUserReloaded(_ currentUser: User) {
        self.appViewController?.currentUser = currentUser
        ElloHUD.hideLoadingHudInView(self.view)
    }

    func dynamicSettingsLoaded(_ settings: [DynamicSettingCategory]) {
        screen.updateDynamicSettings(settings,
            blockCount: currentUser?.profile?.blockedCount ?? 0,
            mutedCount: currentUser?.profile?.mutedCount ?? 0
            )
    }

    func categoriesLoaded(_ categories: [Category]) {
        self.categories = categories
        screen.categoriesEnabled = true
    }
}

extension SettingsViewController: DynamicSettingsDelegate {
    func dynamicSettingsUserChanged(_ user: User) {
        appViewController?.currentUser = user
    }
}

extension SettingsViewController: AutoCompleteDelegate {
    func updateAutoCompleteFrame(animated: Bool) {
        guard isViewLoaded else { return }

        if let window = view.window, autoCompleteVC.view.superview == nil {
            window.addSubview(autoCompleteVC.view)
        }

        let rowHeight: CGFloat = AutoCompleteCell.Size.height
        let maxHeight: CGFloat = 3.5 * rowHeight
        let height: CGFloat = min(maxHeight, CGFloat(locationAutoCompleteResultCount) * rowHeight)
        let inset = Keyboard.shared.keyboardBottomInset(inView: view) + height
        let y = view.frame.height - inset

        animateWithKeyboard(animated: animated) {
            self.autoCompleteVC.view.alpha = (self.locationTextViewSelected && self.locationAutoCompleteResultCount > 0) ? 1 : 0
            self.autoCompleteVC.view.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: height)
        }

        if locationTextViewSelected {
            screen.scrollToLocation()
        }
    }

    func autoComplete(_ controller: AutoCompleteViewController, itemSelected item: AutoCompleteItem) {
        guard let locationText = item.result.name else { return }

        screen.location = locationText
        screen.resignLocationField()
    }
}
