////
///  BadgesViewController.swift
//

class BadgesViewController: StreamableViewController {
    override func trackerName() -> String? { return "Badges" }
    override func trackerProps() -> [String: Any]? { return ["user_id": user.id] }

    let user: User

    var _mockScreen: StreamableScreenProtocol?
    var screen: StreamableScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return fetchScreen(_mockScreen) }
    }

    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)

        title = InterfaceString.Profile.Badges
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let screen = BadgesScreen()
        screen.navigationBar.leftItems = [.back]

        view = screen
        viewContainer = screen.streamContainer
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        streamViewController.streamKind = .unknown
        streamViewController.initialLoadClosure = {}
        streamViewController.reloadClosure = {}
        streamViewController.toggleClosure = { _ in }
        streamViewController.isPullToRefreshEnabled = false
        streamViewController.isPagingEnabled = false

        let items: [StreamCellItem] = user.badges.map { badge in
            let badgeModel = Badge(badge: badge, categories: user.categories)
            return StreamCellItem(jsonable: badgeModel, type: .badge)
        }
        streamViewController.appendStreamCellItems(items)
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

    private func updateInsets() {
        updateInsets(navBar: screen.navigationBar)
    }

}
