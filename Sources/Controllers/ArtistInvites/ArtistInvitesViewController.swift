////
///  ArtistInvitesViewController.swift
//

class ArtistInvitesViewController: StreamableViewController {
    override func trackerName() -> String? { return "ArtistInvites" }
    override func trackerProps() -> [String: Any]? { return nil }
    override func trackerStreamInfo() -> (String, String?)? { return nil }

    private var _mockScreen: StreamableScreenProtocol?
    var screen: StreamableScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return fetchScreen(_mockScreen) }
    }
    var generator: ArtistInvitesGenerator!

    typealias Usage = HomeViewController.Usage

    private let usage: Usage

    init(usage: Usage) {
        self.usage = usage
        super.init(nibName: nil, bundle: nil)

        title = InterfaceString.ArtistInvites.Title
        generator = ArtistInvitesGenerator(
            currentUser: currentUser,
            destination: self)
        streamViewController.streamKind = generator.streamKind
        streamViewController.reloadClosure = { [weak self] in self?.generator?.load(reload: true) }
        streamViewController.initialLoadClosure = { [weak self] in self?.loadArtistInvites() }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didSetCurrentUser() {
        super.didSetCurrentUser()
        generator.currentUser = currentUser
        if currentUser != nil, isViewLoaded {
            screen.navigationBar.leftItems = [.burger]
        }
    }

    override func loadView() {
        let screen = ArtistInvitesScreen(usage: usage)
        screen.delegate = self

        screen.navigationBar.title = ""
        if currentUser != nil {
            screen.navigationBar.leftItems = [.burger]
        }

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
        positionNavBar(screen.navigationBar, visible: true, withConstraint: screen.navigationBarTopConstraint, animated: animated)
        updateInsets()
    }

    override func hideNavBars(animated: Bool) {
        super.hideNavBars(animated: animated)
        positionNavBar(screen.navigationBar, visible: false, withConstraint: screen.navigationBarTopConstraint, animated: animated)
        updateInsets()
    }
}

extension ArtistInvitesViewController: StreamDestination {

    var isPagingEnabled: Bool {
        get { return streamViewController.isPagingEnabled }
        set { streamViewController.isPagingEnabled = newValue }
    }

    func loadArtistInvites() {
        streamViewController.isPagingEnabled = false
        generator.load()
    }

    func replacePlaceholder(type: StreamCellType.PlaceholderType, items: [StreamCellItem], completion: @escaping Block) {
        if type == .pageHeader,
            let pageHeader = items.compactMap({ $0.jsonable as? PageHeader }).first,
            let trackingPostToken = pageHeader.postToken
        {
            let trackViews: ElloAPI = .promotionalViews(tokens: [trackingPostToken])
            ElloProvider.shared.request(trackViews).ignoreErrors()
        }

        streamViewController.replacePlaceholder(type: type, items: items) {
            if self.streamViewController.hasCellItems(for: .pageHeader) && !self.streamViewController.hasCellItems(for: .artistInvites) {
                self.streamViewController.replacePlaceholder(type: .artistInvites, items: [StreamCellItem(type: .streamLoading)])
            }

            completion()
        }

        if type == .artistInvites {
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

extension ArtistInvitesViewController: ArtistInvitesScreenDelegate {
    func scrollToTop() {
        streamViewController.scrollToTop(animated: true)
    }
}
