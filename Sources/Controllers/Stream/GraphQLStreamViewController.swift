////
///  SimpleStreamController.swift
//

import SnapKit
import PromiseKit


class GraphQLStreamViewController: StreamableViewController {
    override func trackerName() -> String? {
        return streamKind.name
    }

    override func trackerStreamInfo() -> (String, String?)? {
        return trackerInfo
    }

    var navigationBar: ElloNavigationBar!
    var navigationBarTopConstraint: Constraint!
    let streamKind: StreamKind
    let initialRequest: (() -> Promise<(PageConfig, [Post])>)
    let nextPageRequest: ((String) -> Promise<(PageConfig, [Post])>)
    let trackerInfo: (String, String?)?
    private var pageConfig: PageConfig?

    required init(
        streamKind: StreamKind,
        title: String,
        initialRequest: @escaping (() -> Promise<(PageConfig, [Post])>),
        nextPageRequest: @escaping ((String) -> Promise<(PageConfig, [Post])>),
        trackerInfo: (String, String?)? = nil
        )
    {
        self.streamKind = streamKind
        self.initialRequest = initialRequest
        self.nextPageRequest = nextPageRequest
        self.trackerInfo = trackerInfo
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
        streamViewController.initialLoadClosure = { [weak self] in
            guard let `self` = self else { return }
            self.initialRequest()
                .done { pageConfig, posts in
                    self.pageConfig = pageConfig
                    self.streamViewController.showInitialModels(posts)
                }
                .ignoreErrors()
        }
        streamViewController.showLoadingSpinner()
        streamViewController.loadInitialPage()
    }

    override func viewForStream() -> UIView {
        return view
    }

    override func showNavBars(animated: Bool) {
        super.showNavBars(animated: animated)
        positionNavBar(navigationBar, visible: true, withConstraint: navigationBarTopConstraint, animated: animated)
        updateInsets()
    }

    override func hideNavBars(animated: Bool) {
        super.hideNavBars(animated: animated)
        positionNavBar(navigationBar, visible: false, withConstraint: navigationBarTopConstraint, animated: animated)
        updateInsets()
    }

    private func updateInsets() {
        updateInsets(navBar: navigationBar)
    }

    private func setupNavigationBar() {
        navigationBar = ElloNavigationBar()
        view.addSubview(navigationBar)

        navigationBar.snp.makeConstraints { make in
            navigationBarTopConstraint = make.top.equalTo(view).constraint
            make.leading.trailing.equalTo(view)
        }
        navigationBar.layoutIfNeeded()
    }

    private func setupNavigationItems(streamKind: StreamKind) {
        navigationBar.leftItems = [.back]

        if streamKind.hasGridViewToggle {
            navigationBar.rightItems = [.gridList(isGrid: streamKind.isGridView)]
        }
    }

    override func streamViewInfiniteScroll() -> Promise<[Model]>? {
        guard
            let pageConfig = pageConfig,
            let next = pageConfig.next
        else { return .value([]) }

        return nextPageRequest(next)
            .map { pageConfig, posts -> [Model] in
                self.pageConfig = pageConfig
                return posts
            }
            .recover { error -> Promise<[Model]> in
                self.pageConfig = nil
                throw error
            }
    }

}
