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
        get { return _mockScreen ?? self.view as! StreamableScreen }
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

        self.view = screen
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
            let badgeJSONAble = Badge(badge: badge, categories: user.categories)
            let item = StreamCellItem(jsonable: badgeJSONAble, type: .badge)
            return item
        }
        streamViewController.appendStreamCellItems(items)
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

    private func updateInsets() {
        updateInsets(navBar: screen.navigationBar)
    }

}
