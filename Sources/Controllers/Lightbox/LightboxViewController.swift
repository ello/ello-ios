////
///  LightboxViewController.swift
//

import PromiseKit


class LightboxViewController: BaseElloViewController {
    struct Item {
        let path: IndexPath
        let url: URL
        let post: Post
    }

    private var allItems: [Item]
    private var selectedIndex: Int
    private var postChangedNotification: NotificationObserver?
    weak var delegate: LightboxControllerDelegate?
    weak var streamViewController: StreamViewController?

    private var _mockScreen: LightboxScreenProtocol?
    var screen: LightboxScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return _mockScreen ?? self.view as! LightboxScreen }
    }

    init(selected index: Int, allItems: [Item]) {
        self.allItems = allItems
        self.selectedIndex = index
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = self

        addNotificationObservers()
    }

    deinit {
        removeNotificationObservers()
    }

    private func removeNotificationObservers() {
        postChangedNotification?.removeObserver()
    }

    private func addNotificationObservers() {
        postChangedNotification = NotificationObserver(notification: PostChangedNotification) { [weak self] (post, change) in
            guard let `self` = self else { return }
            self.updateItems(post: post)
        }
    }

    required init(coder: NSCoder) {
        fatalError("This isn't implemented")
    }

    override func loadView() {
        let view = LightboxScreen()
        view.delegate = self
        self.view = view
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        postNotification(StatusBarNotifications.alertStatusBarVisibility, value: false)
    }

    private func updateItems(post: Post) {
        for (index, item) in allItems.enumerated() {
            guard item.post.id == post.id else { continue }
            let newItem = Item(path: item.path, url: item.url, post: post)
            allItems[index] = newItem
        }

        if allItems[selectedIndex].post.id == post.id, isViewLoaded {
            configureToolbar(screen.toolbar)
        }
    }
}

extension LightboxViewController: LightboxScreenDelegate {
    @objc
    func viewAction() {
        guard let postbarController = streamViewController?.postbarController else { return }

        dismissAction()

        let post = allItems[selectedIndex].post
        postbarController.viewsButtonTapped(post: post, scrollToComments: false)
    }

    @objc
    func commentsAction() {
        guard let postbarController = streamViewController?.postbarController else { return }

        dismissAction()

        let post = allItems[selectedIndex].post
        postbarController.viewsButtonTapped(post: post, scrollToComments: true)
    }

    @objc
    func loveAction() {
        guard let postbarController = streamViewController?.postbarController else { return }

        let post = allItems[selectedIndex].post
        postbarController.lovesButtonTapped(post: post)
    }

    @objc
    func loveAction(animationLocation location: CGPoint) {
        let post = allItems[selectedIndex].post
        if !post.isLoved {
            loveAction()
        }

        if let window = view.window {
            LoveAnimation.perform(inWindow: window, at: location)
        }
    }

    @objc
    func repostAction() {
        guard let postbarController = streamViewController?.postbarController else { return }

        let post = allItems[selectedIndex].post
        postbarController.repostButtonTapped(post: post, presentingController: self)
    }

    @objc
    func shareAction(control: UIView) {
        guard let postbarController = streamViewController?.postbarController else { return }

        let post = allItems[selectedIndex].post
        postbarController.shareButtonTapped(post: post, sourceView: control, presentingController: self)
    }

    @objc
    func dismissAction() {
        postNotification(StatusBarNotifications.alertStatusBarVisibility, value: true)
        delegate?.lightboxWillDismiss()
        dismiss(animated: true, completion: nil)
    }

    func isDifferentPost(delta: Int) -> Bool {
        guard selectedIndex + delta >= 0 && selectedIndex + delta < allItems.count else { return false }
        return allItems[selectedIndex + delta].post.id != allItems[selectedIndex].post.id
    }

    func didMoveBy(delta: Int) {
        guard selectedIndex + delta >= 0 && selectedIndex + delta < allItems.count else { return }
        selectedIndex += delta

        streamViewController?.scrollTo(indexPath: allItems[selectedIndex].path)
    }

    func configureToolbar(_ toolbar: PostToolbar) {
        let post = allItems[selectedIndex].post

        toolbar.views.title = post.viewsCount?.numberToHuman(rounding: 1)
        toolbar.reposts.title = post.repostsCount?.numberToHuman(rounding: 1)
        toolbar.loves.title = post.lovesCount?.numberToHuman(rounding: 1)
        toolbar.comments.title = post.commentsCount?.numberToHuman(rounding: 1)

        let (commentVisibility, loveVisibility, repostVisibility, shareVisibility) = StreamFooterCellPresenter.toolbarItemVisibility(post: post, currentUser: currentUser, isGridView: false)
        var toolbarItems: [PostToolbar.Item] = [.views]

        toolbar.loves.isEnabled = loveVisibility.isEnabled
        toolbar.loves.isSelected = loveVisibility.isSelected

        toolbar.reposts.isEnabled = repostVisibility.isEnabled
        toolbar.reposts.isSelected = repostVisibility.isSelected

        if commentVisibility.isVisible {
            toolbarItems.append(.comments)
        }

        if loveVisibility.isVisible {
            toolbarItems.append(.loves)
        }

        if repostVisibility.isVisible {
            toolbarItems.append(.repost)
        }

        if shareVisibility.isVisible {
            toolbarItems.append(.share)
        }

        toolbar.postItems = toolbarItems
    }

    func imageURLsForScreen() -> (prev: URL?, current: URL, next: URL?) {
        let prev = selectedIndex > 0 ? allItems[selectedIndex - 1].url : nil
        let current = allItems[selectedIndex].url
        let next = selectedIndex + 1 < allItems.count ? allItems[selectedIndex + 1].url : nil
        return (prev: prev, current: current, next: next)
    }

    func canLoadMore() -> Bool {
        return streamViewController?.canLoadNextPage() == true
    }

    func loadMoreImages() -> Promise<Void> {
        guard let streamViewController = streamViewController else {
            let promise = Promise(value: Void())
            return promise
        }

        return streamViewController.actuallyLoadNextPage()
            .then { _ -> Void in
                let (_, imageItems) = streamViewController.gatherLightboxItems()
                self.allItems = imageItems
                self.screen.updateImages(updateToolbar: false)
            }
    }
}

// MARK: UIViewControllerTransitioningDelegate
extension LightboxViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        guard presented == self else { return nil }

        return AlertPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
