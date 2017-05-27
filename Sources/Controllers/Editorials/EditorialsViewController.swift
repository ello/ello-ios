////
///  EditorialsViewController.swift
//

class EditorialsViewController: StreamableViewController, EditorialsScreenDelegate {
    override func trackerName() -> String? { return "Editorials" }
    override func trackerProps() -> [String: Any]? { return nil }
    override func trackerStreamInfo() -> (String, String?)? { return nil }

    private var _mockScreen: EditorialsScreenProtocol?
    var screen: EditorialsScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return _mockScreen ?? self.view as! EditorialsScreen }
    }
    var generator: EditorialsGenerator!

    init() {
        super.init(nibName: nil, bundle: nil)

        generator = EditorialsGenerator(
            currentUser: currentUser,
            destination: self)
        streamViewController.streamKind = generator.streamKind
        streamViewController.pagingEnabled = false
        streamViewController.initialLoadClosure = { [weak self] in self?.loadEditorials() }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didSetCurrentUser() {
        generator.currentUser = currentUser
        super.didSetCurrentUser()
    }

    override func loadView() {
        let screen = EditorialsScreen()
        screen.delegate = self

        self.view = screen
        viewContainer = screen.streamContainer
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.loadInitialPage()
    }

    fileprivate func updateInsets() {
        updateInsets(navBar: screen.navigationBar)
    }

    override func showNavBars() {
        super.showNavBars()
        positionNavBar(screen.navigationBar, visible: true, withConstraint: screen.navigationBarTopConstraint)
        updateInsets()
    }

    override func hideNavBars() {
        super.hideNavBars()
        positionNavBar(screen.navigationBar, visible: false, withConstraint: screen.navigationBarTopConstraint)
        updateInsets()
    }
}

extension EditorialsViewController: EditorialCellResponder {
    func editorialTapped(cell: EditorialCell) {
        guard
            let jsonable = streamViewController.jsonable(forCell: cell),
            let editorial = jsonable as? Editorial
        else { return }

        switch editorial.kind {
        case .external:
            guard let url = editorial.externalURL else { return }
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
            let editorial = jsonable as? Editorial,
            let editorialPosts = editorial.posts,
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

        editorial.invite = (emails: emailString, sent: true)
        streamViewController.reloadCells(now: true)

        let emails: [String] = emailString.replacingOccurrences(of: "\n", with: ",").split(",").map { $0.trimmed() }

        InviteService().sendInvitations(emails).ignoreErrors()
    }

    func submitJoin(cell: UICollectionViewCell, email: String, username: String, password: String) {
        guard currentUser == nil else { return }

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
        streamViewController.postbarController?.sharePost(post, sourceView: cell)
    }
}

extension EditorialsViewController: StreamDestination {

    var pagingEnabled: Bool {
        get { return streamViewController.pagingEnabled }
        set { streamViewController.pagingEnabled = newValue }
    }

    func loadEditorials() {
        generator.load()
    }

    func replacePlaceholder(type: StreamCellType.PlaceholderType, items: [StreamCellItem], completion: @escaping ElloEmptyCompletion) {
        streamViewController.replacePlaceholder(type: type, items: items, completion: completion)
        streamViewController.doneLoading()
    }

    func setPlaceholders(items: [StreamCellItem]) {
        streamViewController.clearForInitialLoad()
        streamViewController.appendStreamCellItems(items)
    }

    func setPrimary(jsonable: JSONAble) {
    }

    func setPagingConfig(responseConfig: ResponseConfig) {
        streamViewController.responseConfig = responseConfig
    }

    func primaryJSONAbleNotFound() {
        self.showGenericLoadFailure()
        self.streamViewController.doneLoading()
    }

}
