////
///  ArtistInviteDetailController.swift
//

class ArtistInviteDetailController: StreamableViewController {
    override func trackerName() -> String? { return "ArtistInvite" }
    override func trackerProps() -> [String: Any]? { return ["id": artistInviteId] }
    override func trackerStreamInfo() -> (String, String?)? { return nil }

    let artistInviteId: String
    var artistInvite: ArtistInvite?
    var submitOnLoad = false { didSet { checkSubmitOnLoad() } }

    private var _mockScreen: ArtistInviteDetailScreenProtocol?
    var screen: ArtistInviteDetailScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return fetchScreen(_mockScreen) }
    }
    var generator: ArtistInviteDetailGenerator!

    convenience init(slug: String) {
        self.init(id: "~\(slug)")
    }

    init(id artistInviteId: String) {
        self.artistInviteId = artistInviteId
        super.init(nibName: nil, bundle: nil)

        generator = ArtistInviteDetailGenerator(
            artistInviteId: artistInviteId,
            currentUser: currentUser,
            destination: self)
        streamViewController.streamKind = generator.streamKind
        streamViewController.isPagingEnabled = false
        streamViewController.reloadClosure = { [weak self] in self?.generator?.load(reload: true) }
        streamViewController.initialLoadClosure = { [weak self] in self?.generator.load() }
    }

    convenience init(artistInvite: ArtistInvite) {
        self.init(id: artistInvite.id)
        self.setPrimary(jsonable: artistInvite)
        generator.artistInvite = artistInvite
   }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didSetCurrentUser() {
        super.didSetCurrentUser()
        generator.currentUser = currentUser
    }

    override func loadView() {
        let screen = ArtistInviteDetailScreen()
        screen.navigationBar.leftItems = [.back]
        screen.navigationBar.rightItems = [.share]

        view = screen
        viewContainer = screen.streamContainer
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkSubmitOnLoad()
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
        positionNavBar(screen.navigationBar, visible: true, withConstraint: screen.navigationBarTopConstraint, animated: animated)
        updateInsets()
    }

    override func hideNavBars(animated: Bool) {
        super.hideNavBars(animated: animated)
        positionNavBar(screen.navigationBar, visible: false, withConstraint: screen.navigationBarTopConstraint, animated: animated)
        updateInsets()
    }

    override func calculateDefaultTopInset() -> CGFloat {
        if Globals.isIphoneX {
            return 0
        }
        return super.calculateDefaultTopInset()
    }
}

extension ArtistInviteDetailController: StreamDestination {

    var isPagingEnabled: Bool {
        get { return streamViewController.isPagingEnabled }
        set { streamViewController.isPagingEnabled = newValue }
    }

    func replacePlaceholder(type: StreamCellType.PlaceholderType, items: [StreamCellItem], completion: @escaping Block) {
        streamViewController.replacePlaceholder(type: type, items: items, completion: completion)

        if type == .artistInvites {
            streamViewController.doneLoading()
        }
    }

    func setPlaceholders(items: [StreamCellItem]) {
        streamViewController.clearForInitialLoad(newItems: items)
    }

    func setPrimary(jsonable: Model) {
        guard let artistInvite = jsonable as? ArtistInvite else { return }

        self.artistInvite = artistInvite
        title = artistInvite.title

        checkSubmitOnLoad()
    }

    func setPagingConfig(responseConfig: ResponseConfig) {
        streamViewController.responseConfig = responseConfig
    }

    func primaryModelNotFound() {
        self.showGenericLoadFailure()
        self.streamViewController.doneLoading()
    }

}

extension ArtistInviteDetailController: ArtistInviteResponder {

    func checkSubmitOnLoad() {
        guard submitOnLoad, artistInvite != nil, isViewLoaded, view.superview != nil else { return }

        submitOnLoad = false
        tappedArtistInviteSubmitButton()
    }

    func tappedArtistInviteSubmissionsButton() {
        streamViewController.scrollTo(placeholderType: .artistInviteSelections)
    }

    func tappedArtistInviteSubmitButton() {
        guard let artistInvite = artistInvite else { return }
        guard let currentUser = currentUser else {
            appViewController?.showJoinScreen(artistInvite: artistInvite)
            return
        }

        if let submitURL = artistInvite.submitURL {
            UIApplication.shared.open(submitURL, options: [:], completionHandler: nil)
            return
        }

        let vc = OmnibarViewController()
        vc.artistInvite = artistInvite
        vc.currentUser = currentUser
        vc.onPostSuccess { _ in
            _ = self.navigationController?.popViewController(animated: true)
            self.screen.showSuccess()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ArtistInviteDetailController: RevealControllerResponder {

    func revealControllerTapped(info: Any) {
        guard
            let artistInvite = artistInvite,
            let stream = info as? ArtistInvite.Stream
        else { return }

        let vc = ArtistInviteAdminController(artistInvite: artistInvite, stream: stream)
        vc.currentUser = currentUser
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension ArtistInviteDetailController: HasShareButton {
    func shareButtonTapped(_ sender: UIView) {
        guard
            let artistInvite = artistInvite,
            let shareURL = URL(string: artistInvite.shareLink)
        else { return }

        Tracker.shared.artistInviteShared(slug: artistInvite.slug)
        showShareActivity(sender: sender, url: shareURL)
    }
}
