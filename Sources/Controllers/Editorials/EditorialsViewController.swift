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

        streamViewController.streamKind = .following
        // streamViewController.initialLoadClosure = { [unowned self] in self.loadCategory() }
        // streamViewController.reloadClosure = { [unowned self] in self.reloadCurrentCategory() }
        // streamViewController.toggleClosure = { [unowned self] isGridView in self.toggleGrid(isGridView) }
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
