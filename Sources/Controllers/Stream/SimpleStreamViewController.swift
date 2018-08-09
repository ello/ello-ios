////
///  SimpleStreamController.swift
//

class SimpleStreamViewController: StreamableViewController {
    override func trackerName() -> String? {
        return endpoint.trackerName
    }

    var navigationBar: ElloNavigationBar!
    let endpoint: ElloAPI
    let streamKind: StreamKind

    required init(endpoint: ElloAPI, title: String) {
        self.endpoint = endpoint
        self.streamKind = .simpleStream(endpoint: endpoint, title: title)
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupNavigationBar()
        setupNavigationItems(streamKind: streamKind)

        streamViewController.streamKind = streamKind
        streamViewController.showLoadingSpinner()
        streamViewController.loadInitialPage()
    }

    override func viewForStream() -> UIView {
        return view
    }

    override func showNavBars(animated: Bool) {
        super.showNavBars(animated: animated)
        positionNavBar(navigationBar, visible: true, animated: animated)
        updateInsets()
    }

    override func hideNavBars(animated: Bool) {
        super.hideNavBars(animated: animated)
        positionNavBar(navigationBar, visible: false, animated: animated)
        updateInsets()
    }

    private func updateInsets() {
        updateInsets(navBar: navigationBar)
    }

    private func setupNavigationBar() {
        navigationBar = ElloNavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: ElloNavigationBar.Size.height))
        navigationBar.autoresizingMask = [.flexibleBottomMargin, .flexibleWidth]
        view.addSubview(navigationBar)
    }

    private func setupNavigationItems(streamKind: StreamKind) {
        navigationBar.leftItems = [.back]

        if streamKind.hasGridViewToggle {
            navigationBar.rightItems = [.gridList(isGrid: streamKind.isGridView)]
        }
    }

}
