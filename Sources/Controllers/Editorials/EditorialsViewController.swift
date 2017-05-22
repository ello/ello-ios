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

    init() {
        super.init(nibName: nil, bundle: nil)

        streamViewController.streamKind = .editorials
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        ElloProvider.oneTimeProvider = ElloProvider.StubbingProvider()
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

extension EditorialsViewController: EditorialResponder {
    func submitInvite(cell: UICollectionViewCell, emails emailString: String) {
        guard
            let jsonable = streamViewController.jsonable(forCell: cell),
            let editorial = jsonable as? Editorial
        else { return }

        editorial.invite = (emails: emailString, sent: true)
        streamViewController.reloadCells(now: true)

        let emails: [String] = emailString.replacingOccurrences(of: "\n", with: ",").split(",").map { $0.trimmed() }

        InviteService().invitations(emails)
            .onSuccess { _ in }
            .onFail { _ in }
    }

    func submitJoin(cell: UICollectionViewCell, email: String, username: String, password: String) {
        guard currentUser == nil else { return }

        let vc = JoinViewController(email: email, username: username, password: password)
        navigationController?.pushViewController(vc, animated: true)
    }
}
