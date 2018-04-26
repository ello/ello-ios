////
///  ArtistInviteAdminController.swift
//

class ArtistInviteAdminController: StreamableViewController {
    override func trackerName() -> String? { return "ArtistInviteAdmin" }
    override func trackerProps() -> [String: Any]? { return ["id": artistInvite.id] }
    override func trackerStreamInfo() -> (String, String?)? { return nil }

    var artistInvite: ArtistInvite

    private var _mockScreen: ArtistInviteAdminScreenProtocol?
    var screen: ArtistInviteAdminScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return fetchScreen(_mockScreen) }
    }
    var generator: ArtistInviteAdminGenerator!

    init(artistInvite: ArtistInvite, stream: ArtistInvite.Stream) {
        self.artistInvite = artistInvite
        super.init(nibName: nil, bundle: nil)

        title = InterfaceString.ArtistInvites.AdminTitle

        generator = ArtistInviteAdminGenerator(
            artistInvite: artistInvite,
            stream: stream,
            currentUser: currentUser,
            destination: self)
        streamViewController.streamKind = generator.streamKind
        streamViewController.isPagingEnabled = false
        streamViewController.reloadClosure = { [weak self] in self?.generator?.load(reload: true) }
        streamViewController.initialLoadClosure = { [weak self] in self?.generator.load() }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didSetCurrentUser() {
        super.didSetCurrentUser()
        generator.currentUser = currentUser
    }

    override func loadView() {
        let screen = ArtistInviteAdminScreen()
        screen.delegate = self
        screen.selectedSubmissionsStatus = generator.stream.submissionsStatus

        screen.navigationBar.title = ""
        screen.navigationBar.leftItems = [.back]

        view = screen
        viewContainer = screen.streamContainer
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        ElloHUD.showLoadingHudInView(streamViewController.view)
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

}

extension ArtistInviteAdminController: ArtistInviteAdminScreenDelegate {

    func tappedUnapprovedSubmissions() {
        loadStream(artistInvite.unapprovedSubmissionsStream)
    }

    func tappedApprovedSubmissions() {
        loadStream(artistInvite.approvedSubmissionsStream)
    }

    func tappedSelectedSubmissions() {
        loadStream(artistInvite.selectedSubmissionsStream)
    }

    func tappedDeclinedSubmissions() {
        loadStream(artistInvite.declinedSubmissionsStream)
    }

    private func loadStream(_ stream: ArtistInvite.Stream?) {
        guard let stream = stream else { return }

        screen.selectedSubmissionsStatus = stream.submissionsStatus
        replacePlaceholder(type: .streamItems, items: [StreamCellItem(type: .streamLoading)])
        generator.stream = stream
        streamViewController.scrollToTop(animated: true)
        streamViewController.streamKind = generator.streamKind
        streamViewController.loadInitialPage(reload: true)
    }
}

extension ArtistInviteAdminController: ArtistInviteAdminResponder {
    func tappedArtistInviteAction(cell: ArtistInviteAdminControlsCell, action: ArtistInviteSubmission.Action) {
        let collectionView = streamViewController.collectionView

        guard
            let indexPath = collectionView.indexPath(for: cell),
            let streamCellItem = streamViewController.collectionViewDataSource.streamCellItem(at: indexPath)
        else { return }

        ElloHUD.showLoadingHudInView(streamViewController.view)
        ArtistInviteService().performAction(action: action)
            .done { newSubmission in
                streamCellItem.jsonable = newSubmission
                collectionView.reloadItems(at: [indexPath])
            }
            .ensure {
                ElloHUD.hideLoadingHudInView(self.streamViewController.view)
            }
            .ignoreErrors()
    }
}

extension ArtistInviteAdminController: StreamDestination {

    var isPagingEnabled: Bool {
        get { return streamViewController.isPagingEnabled }
        set { streamViewController.isPagingEnabled = newValue }
    }

    func replacePlaceholder(type: StreamCellType.PlaceholderType, items: [StreamCellItem], completion: @escaping Block) {
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
