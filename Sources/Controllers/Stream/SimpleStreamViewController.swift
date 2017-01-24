////
///  SimpleStreamController.swift
//

import Foundation

class SimpleStreamViewController: StreamableViewController {
    override func trackerName() -> String? {
        return endpoint.trackerName
    }

    var navigationBar: ElloNavigationBar!
    let endpoint: ElloAPI

    required init(endpoint: ElloAPI, title: String) {
        self.endpoint = endpoint
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let streamKind = StreamKind.simpleStream(endpoint: endpoint, title: title ?? "")

        setupNavigationBar()
        setupNavigationItems(streamKind: streamKind)

        scrollLogic.navBarHeight = 44
        streamViewController.streamKind = streamKind
        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.loadInitialPage()
    }

    override func viewForStream() -> UIView {
        return view
    }

    override func didSetCurrentUser() {
        if isViewLoaded {
            streamViewController.currentUser = currentUser
        }
        super.didSetCurrentUser()
    }

    override func showNavBars() {
        super.showNavBars()
        positionNavBar(navigationBar, visible: true)
        updateInsets()
    }

    override func hideNavBars() {
        super.hideNavBars()
        positionNavBar(navigationBar, visible: false)
        updateInsets()
    }

    // MARK: Private

    fileprivate func updateInsets() {
        updateInsets(navBar: navigationBar, streamController: streamViewController)
    }

    fileprivate func setupNavigationBar() {
        navigationBar = ElloNavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: ElloNavigationBar.Size.height))
        navigationBar.autoresizingMask = [.flexibleBottomMargin, .flexibleWidth]
        view.addSubview(navigationBar)
    }

    fileprivate func setupNavigationItems(streamKind: StreamKind) {
        let backItem = UIBarButtonItem.backChevron(withController: self)
        elloNavigationItem.leftBarButtonItems = [backItem]
        elloNavigationItem.fixNavBarItemPadding()
        navigationBar.items = [elloNavigationItem]

        var rightBarButtonItems: [UIBarButtonItem] = []
        rightBarButtonItems.append(UIBarButtonItem.searchItem(controller: self))
        if streamKind.hasGridViewToggle {
            rightBarButtonItems.append(UIBarButtonItem.gridListItem(delegate: streamViewController, isGridView: streamKind.isGridView))
        }
        elloNavigationItem.rightBarButtonItems = rightBarButtonItems
    }

}
