////
///  BaseElloViewController.swift
//

@objc
protocol ControllerThatMightHaveTheCurrentUser {
    var currentUser: User? { get set }
}

class BaseElloViewController: UIViewController,
    HasAppController, HasBackButton, HasCloseButton,
    ControllerThatMightHaveTheCurrentUser
{
    override var prefersStatusBarHidden: Bool {
        let visible = appViewController?.statusBarShouldBeVisible ?? true
        return !visible
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }

    override var title: String? {
        didSet {
            if isViewLoaded {
                let elloNavigationBar: ElloNavigationBar? = view.findSubview()
                elloNavigationBar?.invalidateDefaultTitle()
            }
        }
    }

    func fetchScreen<T>(_ mock: T?) -> T {
        if !isViewLoaded && Globals.isSimulator && !Globals.isTesting { fatalError("should not be accessing 'screen' now") }
        return mock ?? self.view as! T
    }

    var currentUser: User? {
        didSet { didSetCurrentUser() }
    }

    var appViewController: AppViewController? { return findParentController() }
    var elloTabBarController: ElloTabBarController? { return findParentController() }
    var bottomBarController: BottomBarController? { return findParentController() }
    var updatesBottomBar = true
    var navigationBarsVisible: Bool? {
        return bottomBarController?.navigationBarsVisible
    }

    // This is an odd one, `super.next` is not accessible in a closure that
    // captures self so we stuff it in a computed variable
    var superNext: UIResponder? {
        return super.next
    }

    var relationshipController: RelationshipController?

    override var next: UIResponder? {
        return relationshipController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupRelationshipController()
    }

    private func setupRelationshipController() {
        let chainableController = ResponderChainableController(
            controller: self,
            next: { [weak self] in
                return self?.superNext
            }
        )

        let relationshipController = RelationshipController(responderChainable: chainableController)
        relationshipController.currentUser = self.currentUser
        self.relationshipController = relationshipController
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNavBars(animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackScreenAppeared()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // updateNavBars(animated: false)
    }

    override func trackScreenAppeared() {
        super.trackScreenAppeared()

        if currentUser == nil {
            Tracker.shared.loggedOutScreenAppeared(self)
        }
    }

    func updateNavBars(animated: Bool) {
        guard let navigationBarsVisible = navigationBarsVisible else { return }

        postNotification(StatusBarNotifications.statusBarVisibility, value: navigationBarsVisible)
        if navigationBarsVisible {
            showNavBars(animated: animated)
        }
        else {
            hideNavBars(animated: animated)
        }
    }

    func showNavBars(animated: Bool) {
        guard updatesBottomBar else { return }
        bottomBarController?.setNavigationBarsVisible(true, animated: animated)
    }

    func hideNavBars(animated: Bool) {
        guard updatesBottomBar else { return }
        bottomBarController?.setNavigationBarsVisible(false, animated: animated)
    }

    func didSetCurrentUser() {
        relationshipController?.currentUser = currentUser

        for childController in children {
            (childController as? ControllerThatMightHaveTheCurrentUser)?.currentUser = currentUser
        }

        (presentedViewController as? ControllerThatMightHaveTheCurrentUser)?.currentUser = currentUser
    }

    func showShareActivity(sender: UIView, url shareURL: URL, image: UIImage? = nil) {
        var items: [Any] = [shareURL]
        if let image = image {
            items.append(image)
        }

        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: [SafariActivity()])
        if UI_USER_INTERFACE_IDIOM() == .phone {
            activityVC.modalPresentationStyle = .fullScreen
            present(activityVC, animated: true) { }
        }
        else {
            activityVC.modalPresentationStyle = .popover
            activityVC.popoverPresentationController?.sourceView = sender
            present(activityVC, animated: true) { }
        }
    }

    func isRootViewController() -> Bool {
        guard let navigationController = navigationController else { return true }
        return navigationController.viewControllers.first == self
    }

    // called from ElloTabBarController
    func goingBackNow(proceed: @escaping Block) {
        proceed()
    }

    func backButtonTapped() {
        guard
            let navigationController = navigationController, navigationController.children.count > 1
        else { return }

        _ = navigationController.popViewController(animated: true)
    }

    func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}

extension BaseElloViewController: HasHamburgerButton {
    func hamburgerButtonTapped() {
        let responder: DrawerResponder? = findResponder()
        responder?.showDrawerViewController()
    }
}

extension BaseElloViewController: PostTappedResponder {

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

extension BaseElloViewController: CategoryResponder {
    @objc
    func categoryTapped(_ category: Category) {
        let controller = CategoryViewController(currentUser: currentUser, category: category, usage: .detail)
        navigationController?.pushViewController(controller, animated: true)
    }

    @objc
    func categoryTapped(slug: String, name: String) {
        let controller = CategoryViewController(currentUser: currentUser, slug: slug, name: name, usage: .detail)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension BaseElloViewController: UserTappedResponder {

    @objc
    func userTapped(_ user: User) {
        guard user.relationshipPriority != .block else { return }
        userParamTapped(user.id, username: user.username)
    }

    @objc
    func userTapped(userId: String) {
        let vc = ProfileViewController(userParam: userId)
        vc.currentUser = currentUser
        self.navigationController?.pushViewController(vc, animated: true)
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
                return user.username == param.dropFirst()
            }
            else {
                return user.id == profileVC.userParam
            }
        }
        return false
    }
}

extension BaseElloViewController: CreatePostResponder {
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

extension BaseElloViewController {

    func showGenericLoadFailure() {
        let message = InterfaceString.GenericError
        let alertController = AlertViewController(confirmation: message) { _ in
            _ = self.navigationController?.popViewController(animated: true)
        }
        self.present(alertController, animated: true, completion: nil)
    }

}
