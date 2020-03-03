////
///  StreamableViewController.swift
//

import PromiseKit
import SnapKit


class StreamableViewController: BaseElloViewController {
    weak var viewContainer: UIView!
    private var showing = false
    let streamViewController = StreamViewController()
    let tapToShowTop = UIControl()
    let tapToShowBottom = UIControl()

    struct Size {
        static let tapToShowHeight: CGFloat = 20
    }

    override func didSetCurrentUser() {
        super.didSetCurrentUser()
        if isViewLoaded {
            streamViewController.currentUser = currentUser
        }
    }

    func setupStreamController() {
        streamViewController.currentUser = currentUser
        streamViewController.streamViewDelegate = self

        streamViewController.willMove(toParent: self)
        let containerForStream = viewForStream()
        containerForStream.addSubview(streamViewController.view)
        streamViewController.view.frame = containerForStream.bounds
        streamViewController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addChild(streamViewController)
        streamViewController.didMove(toParent: self)
    }

    var scrollLogic: ElloScrollLogic!

    func viewForStream() -> UIView {
        return viewContainer
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showing = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showing = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let streamView = viewForStream()
        if streamView.superview != view && streamView != view {
            view.addSubview(streamView)
        }

        setupStreamController()
        scrollLogic = ElloScrollLogic(
            onShow: { [weak self] in self?.showNavBars(animated: true) },
            onHide: { [weak self] in self?.hideNavBars(animated: true) }
        )

        for tapToShow in [tapToShowTop, tapToShowBottom] {
            streamView.addSubview(tapToShow)
            tapToShow.isUserInteractionEnabled = false
            tapToShow.addTarget(self, action: #selector(tapToShowTapped), for: .touchUpInside)
        }

        tapToShowTop.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view)
            make.height.equalTo(Size.tapToShowHeight)
        }
        tapToShowBottom.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalTo(view)
            make.height.equalTo(Size.tapToShowHeight)
        }
    }

    func trackerStreamInfo() -> (String, String?)? {
        return nil
    }

    override func trackScreenAppeared() {
        super.trackScreenAppeared()

        guard let (streamKind, streamId) = trackerStreamInfo() else { return }
        let posts = streamViewController.collectionViewDataSource.visibleCellItems.compactMap {
            streamCellItem in
            return streamCellItem.jsonable as? Post
        }
        PostService().sendPostViews(
            posts: posts,
            streamId: streamId,
            streamKind: streamKind,
            userId: currentUser?.id
        )

        let comments = streamViewController.collectionViewDataSource.visibleCellItems.compactMap {
            streamCellItem -> ElloComment? in
            guard streamCellItem.type != .createComment else { return nil }
            return streamCellItem.jsonable as? ElloComment
        }
        if let post = posts.first, streamKind == "post", comments.count > 0 {
            PostService().sendPostViews(
                comments: comments,
                streamId: post.id,
                streamKind: "comment",
                userId: currentUser?.id
            )
        }
    }

    override func updateNavBars(animated: Bool) {
        super.updateNavBars(animated: animated)
        if let navigationBarsVisible = navigationBarsVisible {
            scrollLogic.isShowing = navigationBarsVisible
        }
    }

    override func showNavBars(animated: Bool) {
        guard updatesBottomBar else { return }
        super.showNavBars(animated: animated)
        tapToShowTop.isUserInteractionEnabled = true
        tapToShowBottom.isUserInteractionEnabled = true
    }

    override func hideNavBars(animated: Bool) {
        guard updatesBottomBar else { return }
        super.hideNavBars(animated: animated)
        tapToShowTop.isUserInteractionEnabled = true
        tapToShowBottom.isUserInteractionEnabled = true
    }

    func updateInsets(navBar: UIView?, navigationBarsVisible visible: Bool? = nil) {
        updateInsets(maxY: navBar?.frame.maxY ?? 0, navigationBarsVisible: visible)
    }

    func calculateDefaultTopInset() -> CGFloat {
        if Globals.isIphoneX {
            return 44
        }
        else {
            return 0
        }
    }

    func updateInsets(maxY: CGFloat, navigationBarsVisible _visible: Bool? = nil) {
        let topBarVisible = _visible ?? bottomBarController?.navigationBarsVisible ?? false
        let topInset: CGFloat
        if topBarVisible {
            topInset = max(0, maxY)
        }
        else {
            topInset = max(calculateDefaultTopInset(), maxY)
        }

        let bottomBarVisible = _visible ?? bottomBarController?.bottomBarVisible ?? false
        let bottomInset: CGFloat
        if bottomBarVisible {
            bottomInset = bottomBarController?.bottomBarHeight ?? 0
        }
        else {
            bottomInset = 0
        }

        var contentInset = streamViewController.contentInset
        contentInset.top = topInset
        contentInset.bottom = bottomInset
        streamViewController.contentInset = contentInset
    }

    func positionNavBar(
        _ navBar: UIView,
        visible: Bool,
        withConstraint navigationBarTopConstraint: Constraint? = nil,
        animated: Bool
    ) {
        let upAmount: CGFloat
        if visible {
            upAmount = 0
        }
        else {
            upAmount = navBar.frame.size.height + 1
        }

        if let navigationBarTopConstraint = navigationBarTopConstraint {
            navigationBarTopConstraint.update(offset: -upAmount)
        }

        animate(animated: animated) {
            navBar.frame.origin.y = -upAmount
        }

        if let elloNavBar = navBar as? ElloNavigationBar {
            elloNavBar.showBackButton = !visible
        }

        if showing {
            postNotification(StatusBarNotifications.statusBarVisibility, value: visible)
        }
    }

    func streamViewInfiniteScroll() -> Promise<[Model]>? {
        return nil
    }
}

extension StreamableViewController {
    @objc
    func tapToShowTapped() {
        scrollLogic.isShowing = true
        showNavBars(animated: true)
    }
}

extension StreamableViewController: StreamViewDelegate {
    @objc
    func streamViewStreamCellItems(
        jsonables: [Model],
        defaultGenerator generator: StreamCellItemGenerator
    ) -> [StreamCellItem]? {
        return nil
    }

    @objc
    func streamWillPullToRefresh() {
    }

    @objc
    func streamViewDidScroll(scrollView: UIScrollView) {
        scrollLogic.scrollViewDidScroll(scrollView)
    }

    @objc
    func streamViewWillBeginDragging(scrollView: UIScrollView) {
        scrollLogic.scrollViewWillBeginDragging(scrollView)
    }

    @objc
    func streamViewDidEndDragging(scrollView: UIScrollView, willDecelerate: Bool) {
        scrollLogic.scrollViewDidEndDragging(scrollView, willDecelerate: willDecelerate)
    }
}

extension StreamableViewController: HasGridListButton {
    func gridListToggled(_ sender: UIButton) {
        streamViewController.gridListToggled(sender)
    }
}
