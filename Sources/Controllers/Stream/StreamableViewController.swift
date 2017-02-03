////
///  StreamableViewController.swift
//

protocol PostTappedDelegate: class {
    func postTapped(_ post: Post)
    func postTapped(_ post: Post, scrollToComment: ElloComment?)
    func postTapped(postId: String)
}

protocol UserTappedDelegate: class {
    func userTapped(_ user: User)
    func userParamTapped(_ param: String, username: String?)
}

protocol CreatePostDelegate: class {
    func createPost(text: String?, fromController: UIViewController)
    func createComment(_ postId: String, text: String?, fromController: UIViewController)
    func editComment(_ comment: ElloComment, fromController: UIViewController)
    func editPost(_ post: Post, fromController: UIViewController)
}

@objc
protocol InviteResponder: class {
    func onInviteFriends()
    func sendInvite(person: LocalPerson, isOnboarding: Bool, completion: @escaping ElloEmptyCompletion)
}

class StreamableViewController: BaseElloViewController, PostTappedDelegate {
    @IBOutlet weak var viewContainer: UIView!
    fileprivate var showing = false
    let streamViewController = StreamViewController.instantiateFromStoryboard()

    func setupStreamController() {
        streamViewController.currentUser = currentUser
        streamViewController.streamViewDelegate = self
        streamViewController.userTappedDelegate = self
        streamViewController.postTappedDelegate = self
        streamViewController.createPostDelegate = self

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
        willPresentStreamable(navigationBarsVisible())
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showing = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        willPresentStreamable(navigationBarsVisible())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupStreamController()
        scrollLogic = ElloScrollLogic(
            onShow: { [weak self] in self?.showNavBars() },
            onHide: { [weak self] in self?.hideNavBars() }
        )
    }

    fileprivate func willPresentStreamable(_ navBarsVisible: Bool) {
        postNotification(StatusBarNotifications.statusBarShouldHide, value: !navBarsVisible)
        UIView.setAnimationsEnabled(false)
        if navBarsVisible {
            showNavBars()
        }
        else {
            hideNavBars()
        }
        UIView.setAnimationsEnabled(true)
        scrollLogic.isShowing = navBarsVisible
    }

    func navigationBarsVisible() -> Bool {
        return bottomBarController?.navigationBarsVisible ?? false
    }

    func updateInsets(navBar: UIView?, streamController controller: StreamViewController, navigationBarsVisible visible: Bool? = nil) {
        let topInset = max(0, navBar?.frame.maxY ?? 0)
        let bottomInset: CGFloat
        if visible ?? bottomBarController?.bottomBarVisible ?? false {
            bottomInset = bottomBarController?.bottomBarHeight ?? 0
        }
        else {
            bottomInset = 0
        }

        controller.contentInset.top = topInset
        controller.contentInset.bottom = bottomInset
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

        if showing {
            postNotification(StatusBarNotifications.statusBarShouldHide, value: !visible)
        }
    }

    func showNavBars() {
        if let bottomBarController = bottomBarController {
            bottomBarController.setNavigationBarsVisible(true, animated: true)
        }
    }

    func hideNavBars() {
        if let bottomBarController = bottomBarController {
            bottomBarController.setNavigationBarsVisible(false, animated: true)
        }
    }

// MARK: PostTappedDelegate

    func postTapped(_ post: Post) {
        self.postTapped(postId: post.id, scrollToComment: nil)
    }

    func postTapped(_ post: Post, scrollToComment lastComment: ElloComment?) {
        self.postTapped(postId: post.id, scrollToComment: lastComment)
    }

    func postTapped(postId: String) {
        self.postTapped(postId: postId, scrollToComment: nil)
    }

    fileprivate func postTapped(postId: String, scrollToComment lastComment: ElloComment?) {
        let vc = PostDetailViewController(postParam: postId)
        vc.scrollToComment = lastComment
        vc.currentUser = currentUser
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: UserTappedDelegate
extension StreamableViewController: UserTappedDelegate {
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

    fileprivate func alreadyOnUserProfile(_ user: User) -> Bool {
        if let profileVC = self.navigationController?.topViewController as? ProfileViewController
        {
            let param = profileVC.userParam
            if param.hasPrefix("~") {
                let usernamePart = param.substring(from: param.index(after: param.startIndex))
                return user.username == usernamePart
            }
            else {
                return user.id == profileVC.userParam
            }
        }
        return false
    }
}

// MARK: CreatePostDelegate
extension StreamableViewController: CreatePostDelegate {
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
            vc.onPostSuccess() { _ in
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
    func streamViewCustomLoadFailed() -> Bool {
        return false
    }

    func streamViewStreamCellItems(jsonables: [JSONAble], defaultGenerator generator: StreamCellItemGenerator) -> [StreamCellItem]? {
        return nil
    }

    func streamViewDidScroll(scrollView: UIScrollView) {
        scrollLogic.scrollViewDidScroll(scrollView)
    }

    func streamViewWillBeginDragging(scrollView: UIScrollView) {
        scrollLogic.scrollViewWillBeginDragging(scrollView)
    }

    func streamViewDidEndDragging(scrollView: UIScrollView, willDecelerate: Bool) {
        scrollLogic.scrollViewDidEndDragging(scrollView, willDecelerate: willDecelerate)
    }
}

// MARK: InviteResponder
extension StreamableViewController: InviteResponder {
    func onInviteFriends() {
        Tracker.shared.inviteFriendsTapped()
        AddressBookController.promptForAddressBookAccess(fromController: self, completion: { result in
            switch result {
            case let .success(addressBook):
                Tracker.shared.contactAccessPreferenceChanged(true)
                let vc = AddFriendsViewController(addressBook: addressBook)
                vc.currentUser = self.currentUser
                if let navigationController = self.navigationController {
                    navigationController.pushViewController(vc, animated: true)
                }
                else {
                    self.present(vc, animated: true, completion: nil)
                }
            case let .failure(addressBookError):
                guard addressBookError != .cancelled else { return }

                Tracker.shared.contactAccessPreferenceChanged(false)
                let message = addressBookError.rawValue
                let alertController = AlertViewController(
                    message: NSString.localizedStringWithFormat(InterfaceString.Friends.ImportErrorTemplate as NSString, message) as String
                )

                let action = AlertAction(title: InterfaceString.OK, style: .dark, handler: .none)
                alertController.addAction(action)

                self.present(alertController, animated: true, completion: .none)
            }
        })
    }

    func sendInvite(person: LocalPerson, isOnboarding: Bool, completion: @escaping ElloEmptyCompletion) {
        guard let email = person.emails.first else { return }

        if isOnboarding {
            Tracker.shared.onboardingFriendInvited()
        }
        else {
            Tracker.shared.friendInvited()
        }
        ElloHUD.showLoadingHudInView(view)
        InviteService().invite(email,
            success: { [weak self] in
                guard let `self` = self else { return }
                ElloHUD.hideLoadingHudInView(self.view)
                completion()
            },
            failure: { [weak self] _ in
                guard let `self` = self else { return }
                ElloHUD.hideLoadingHudInView(self.view)
                completion()
            })
    }
}
