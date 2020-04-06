////
///  EditorialsViewController.swift
//

class EditorialsViewController: StreamableViewController {
    override func trackerName() -> String? { return "Editorials" }
    override func trackerProps() -> [String: Any]? { return nil }
    override func trackerStreamInfo() -> (String, String?)? { return nil }

    private var _mockScreen: EditorialsScreenProtocol?
    var screen: EditorialsScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return fetchScreen(_mockScreen) }
    }
    var generator: EditorialsGenerator!

    typealias Usage = HomeViewController.Usage

    private let usage: Usage

    init(usage: Usage) {
        self.usage = usage
        super.init(nibName: nil, bundle: nil)

        title = InterfaceString.Editorials.NavbarTitle
        generator = EditorialsGenerator(
            currentUser: currentUser,
            destination: self
        )
        streamViewController.streamKind = generator.streamKind
        streamViewController.initialLoadClosure = { [weak self] in self?.loadEditorials() }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didSetCurrentUser() {
        super.didSetCurrentUser()
        generator.currentUser = currentUser
    }

    override func loadView() {
        let screen = EditorialsScreen(usage: usage)
        screen.delegate = self

        if usage == .loggedIn {
            screen.navigationBar.leftItems = [.burger]
        }

        screen.navigationBar.title = ""

        view = screen
        viewContainer = screen.streamContainer
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        streamViewController.showLoadingSpinner()
        streamViewController.loadInitialPage()
    }

    private func updateInsets() {
        updateInsets(navBar: screen.navigationBar)
    }

    override func showNavBars(animated: Bool) {
        super.showNavBars(animated: animated)
        positionNavBar(
            screen.navigationBar,
            visible: true,
            withConstraint: screen.navigationBarTopConstraint,
            animated: animated
        )
        updateInsets()
    }

    override func hideNavBars(animated: Bool) {
        super.hideNavBars(animated: animated)
        positionNavBar(
            screen.navigationBar,
            visible: false,
            withConstraint: screen.navigationBarTopConstraint,
            animated: animated
        )
        updateInsets()
    }
}

extension EditorialsViewController: EditorialCellResponder {
    func editorialTapped(cellContent: EditorialCellContent) {
        guard
            let jsonable = streamViewController.jsonable(forCell: cellContent.editorialCell),
            let editorial = jsonable as? Editorial
        else { return }

        switch editorial.kind {
        case .internal:
            guard let url = editorial.url else { return }
            postNotification(InternalWebNotification, value: url.absoluteString)
        case .external, .sponsored:
            guard let url = editorial.url else { return }
            postNotification(ExternalWebNotification, value: url.absoluteString)
        case .post:
            guard let post = editorial.post else { return }
            postTapped(post)
        case .postStream,
            .invite,
            .join,
            .unknown:
            break
        }
    }
}

extension EditorialsViewController: EditorialPostStreamResponder {
    func editorialTapped(index: Int, cell: EditorialCell) {
        guard
            let jsonable = streamViewController.jsonable(forCell: cell),
            let editorialPosts = (jsonable as? Editorial)?.posts,
            let post = editorialPosts.safeValue(index)
        else { return }

        postTapped(post)
    }
}

extension EditorialsViewController: EditorialToolsResponder {
    func submitInvite(cell: UICollectionViewCell, emails emailString: String) {
        guard
            let jsonable = streamViewController.jsonable(forCell: cell),
            let editorial = jsonable as? Editorial
        else { return }

        editorial.invite = (emails: "", sent: Globals.now)
        let emails: [String] = emailString.replacingOccurrences(of: "\n", with: ",").split(",").map
        { $0.trimmed() }
        InviteService().sendInvitations(emails).ignoreErrors()
    }

    func submitJoin(cell: UICollectionViewCell, email: String, username: String, password: String) {
        guard currentUser == nil else { return }

        if Validator.hasValidSignUpCredentials(email: email, username: username, password: password, isTermsChecked: true)
        {
            UserService().join(
                email: email,
                username: username,
                password: password
            )
                .done { user in
                    Tracker.shared.joinSuccessful()
                    self.appViewController?.showOnboardingScreen(user)
                }
                .catch { error in
                    Tracker.shared.joinFailed()
                    self.showJoinViewController(
                        email: email,
                        username: username,
                        password: password
                    )
                }
        }
        else {
            showJoinViewController(email: email, username: username, password: password)
        }
    }

    func showJoinViewController(email: String, username: String, password: String) {
        let vc = JoinViewController(email: email, username: username, password: password)
        navigationController?.pushViewController(vc, animated: true)
    }

    func lovesTapped(post: Post, cell: EditorialPostCell) {
        streamViewController.postbarController?.toggleLove(cell, post: post, via: "editorial")
    }

    func commentTapped(post: Post, cell: EditorialPostCell) {
        postTapped(post)
    }

    func repostTapped(post: Post, cell: EditorialPostCell) {
        postTapped(post)
    }

    func shareTapped(post: Post, cell: EditorialPostCell) {
        streamViewController.postbarController?.shareButtonTapped(post: post, sourceView: cell)
    }
}

extension EditorialsViewController: StreamDestination {
    var isPagingEnabled: Bool {
        get { return streamViewController.isPagingEnabled }
        set { streamViewController.isPagingEnabled = newValue }
    }

    func loadEditorials() {
        streamViewController.isPagingEnabled = false
        generator.load()
    }

    func replacePlaceholder(
        type: StreamCellType.PlaceholderType,
        items: [StreamCellItem],
        completion: @escaping Block
    ) {
        if type == .pageHeader,
            let pageHeader = items.compactMap({ $0.jsonable as? PageHeader }).first,
            let trackingPostToken = pageHeader.postToken
        {
            let trackViews: ElloAPI = .promotionalViews(tokens: [trackingPostToken])
            ElloProvider.shared.request(trackViews).ignoreErrors()
        }

        streamViewController.replacePlaceholder(type: type, items: items) {
            if self.streamViewController.hasCellItems(for: .pageHeader)
                && !self.streamViewController.hasCellItems(for: .editorials)
            {
                self.streamViewController.replacePlaceholder(
                    type: .editorials,
                    items: [StreamCellItem(type: .streamLoading)]
                )
            }

            completion()
        }

        if type == .editorials {
            streamViewController.doneLoading()
        }
        else {
            streamViewController.hideLoadingSpinner()
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

extension EditorialsViewController: EditorialsScreenDelegate {
    func scrollToTop() {
        streamViewController.scrollToTop(animated: true)
    }
}
