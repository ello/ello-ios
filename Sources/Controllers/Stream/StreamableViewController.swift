////
///  StreamableViewController.swift
//

import PromiseKit


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
        if isViewLoaded {
            streamViewController.currentUser = currentUser
        }
        super.didSetCurrentUser()
    }

    func setupStreamController() {
        streamViewController.currentUser = currentUser
        streamViewController.streamViewDelegate = self

        streamViewController.willMove(toParentViewController: self)
        let containerForStream = viewForStream()
        containerForStream.addSubview(streamViewController.view)
        streamViewController.view.frame = containerForStream.bounds
        streamViewController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addChildViewController(streamViewController)
        streamViewController.didMove(toParentViewController: self)
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
            onShow: { [weak self] in self?.showNavBars() },
            onHide: { [weak self] in self?.hideNavBars() }
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
        let posts = streamViewController.collectionViewDataSource.visibleCellItems.flatMap { streamCellItem in
            return streamCellItem.jsonable as? Post
        }
        PostService().sendPostViews(posts: posts, streamId: streamId, streamKind: streamKind, userId: currentUser?.id)

        let comments = streamViewController.collectionViewDataSource.visibleCellItems.flatMap { streamCellItem -> ElloComment? in
            guard streamCellItem.type != .createComment else { return nil }
            return streamCellItem.jsonable as? ElloComment
        }
        if let post = posts.first, streamKind == "post", comments.count > 0 {
            PostService().sendPostViews(comments: comments, streamId: post.id, streamKind: "comment", userId: currentUser?.id)
        }
    }

    override func updateNavBars() {
        super.updateNavBars()
        if let navigationBarsVisible = navigationBarsVisible {
            scrollLogic.isShowing = navigationBarsVisible
        }
    }

    override func showNavBars() {
        guard updatesBottomBar else { return }
        super.showNavBars()
        tapToShowTop.isUserInteractionEnabled = true
        tapToShowBottom.isUserInteractionEnabled = true
    }

    override func hideNavBars() {
        guard updatesBottomBar else { return }
        super.hideNavBars()
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

    func positionNavBar(_ navBar: UIView, visible: Bool, withConstraint navigationBarTopConstraint: NSLayoutConstraint? = nil, animated: Bool = true) {
        let upAmount: CGFloat
        if visible {
            upAmount = 0
        }
        else {
            upAmount = navBar.frame.size.height + 1
        }

        if let navigationBarTopConstraint = navigationBarTopConstraint {
            navigationBarTopConstraint.constant = -upAmount
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

    func streamViewInfiniteScroll() -> Promise<[JSONAble]>? {
        return nil
    }
}

extension StreamableViewController {
    @objc
    func tapToShowTapped() {
        scrollLogic.isShowing = true
        showNavBars()
    }
}

extension StreamableViewController: HasHamburgerButton {
    func hamburgerButtonTapped() {
        let responder: DrawerResponder? = findResponder()
        responder?.showDrawerViewController()
    }
}

// MARK: PostTappedResponder
extension StreamableViewController: PostTappedResponder {

    func postTapped(_ post: Post) {
        postTapped(postId: post.id, scrollToComment: nil)
    }

    func postTapped(_ post: Post, scrollToComment comment: ElloComment?) {
        postTapped(postId: post.id, scrollToComment: comment)
    }

    func postTapped(postId: String) {
        postTapped(postId: postId, scrollToComment: nil)
    }

    func postTapped(_ post: Post, scrollToComments: Bool) {
        let vc = postTapped(postId: post.id, scrollToComment: nil)
        vc.scrollToComments = scrollToComments
    }

    @discardableResult
    private func postTapped(postId: String, scrollToComment comment: ElloComment?) -> PostDetailViewController {
        let vc = PostDetailViewController(postParam: postId)
        vc.scrollToComment = comment
        vc.currentUser = currentUser
        navigationController?.pushViewController(vc, animated: true)
        return vc
    }
}

// MARK: UserTappedResponder
extension StreamableViewController: UserTappedResponder {

    func userTapped(_ user: User) {
        guard user.relationshipPriority != .block else { return }
        userParamTapped(user.id, username: user.username)
    }

    func userParamTapped(_ param: String, username: String?) {
        guard !DeepLinking.alreadyOnUserProfile(navVC: navigationController, userParam: param)
            else { return }

        let vc = ProfileViewController(userParam: param, username: username)
        vc.currentUser = currentUser
        self.navigationController?.pushViewController(vc, animated: true)
    }

    private func alreadyOnUserProfile(_ user: User) -> Bool {
        if let profileVC = self.navigationController?.topViewController as? ProfileViewController
        {
            let param = profileVC.userParam
            if param.hasPrefix("~") {
                let usernamePart = param[param.index(after: param.startIndex)...]
                return user.username == usernamePart
            }
            else {
                return user.id == profileVC.userParam
            }
        }
        return false
    }
}

// MARK: CreatePostResponder
extension StreamableViewController: CreatePostResponder {
    func createPost(text: String?, fromController: UIViewController) {
        let vc = OmnibarViewController(defaultText: text)
        vc.currentUser = self.currentUser
        vc.onPostSuccess { _ in
            _ = self.navigationController?.popViewController(animated: true)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func createComment(_ postId: String, text: String?, fromController: UIViewController) {
        let vc = OmnibarViewController(parentPostId: postId, defaultText: text)
        vc.currentUser = self.currentUser
        vc.onCommentSuccess { _ in
            _ = self.navigationController?.popViewController(animated: true)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func editComment(_ comment: ElloComment, fromController: UIViewController) {
        if OmnibarViewController.canEditRegions(comment.content) {
            let vc = OmnibarViewController(editComment: comment)
            vc.currentUser = self.currentUser
            vc.onCommentSuccess { _ in
                _ = self.navigationController?.popViewController(animated: true)
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let message = InterfaceString.Post.CannotEditComment
            let alertController = AlertViewController(message: message)
            let action = AlertAction(title: InterfaceString.ThatIsOK, style: .dark, handler: nil)
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    func editPost(_ post: Post, fromController: UIViewController) {
        if OmnibarViewController.canEditRegions(post.content) {
            let vc = OmnibarViewController(editPost: post)
            vc.currentUser = self.currentUser
            vc.onPostSuccess { _ in
                _ = self.navigationController?.popViewController(animated: true)
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let message = InterfaceString.Post.CannotEditPost
            let alertController = AlertViewController(message: message)
            let action = AlertAction(title: InterfaceString.ThatIsOK, style: .dark, handler: nil)
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

// MARK: StreamViewDelegate
extension StreamableViewController: StreamViewDelegate {
    @objc
    func streamViewStreamCellItems(jsonables: [JSONAble], defaultGenerator generator: StreamCellItemGenerator) -> [StreamCellItem]? {
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

extension StreamableViewController {

    func showGenericLoadFailure() {
        let message = InterfaceString.GenericError
        let alertController = AlertViewController(confirmation: message) { _ in
            _ = self.navigationController?.popViewController(animated: true)
        }
        self.present(alertController, animated: true, completion: nil)
    }

}

extension StreamableViewController: HasGridListButton {
    func gridListToggled(_ sender: UIButton) {
        streamViewController.gridListToggled(sender)
    }
}
