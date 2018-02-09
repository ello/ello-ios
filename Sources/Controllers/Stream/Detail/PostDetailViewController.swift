////
///  PostDetailViewController.swift
//


final class PostDetailViewController: StreamableViewController {
    override func trackerName() -> String? { return "Post Detail" }
    override func trackerProps() -> [String: Any]? {
        if let post = post {
            return ["id": post.id]
        }
        return ["id": postParam]
    }
    override func trackerStreamInfo() -> (String, String?)? {
        guard let streamId = post?.id else { return nil }
        return ("post", streamId)
    }

    var post: Post?
    var postParam: String
    var scrollToComment: ElloComment?
    var scrollToComments: Bool = false

    var navigationBar: ElloNavigationBar!
    var deeplinkPath: String?
    var generator: PostDetailGenerator!

    required init(postParam: String) {
        self.postParam = postParam
        super.init(nibName: nil, bundle: nil)
        if self.post == nil {
            if let post = ElloLinkedStore.shared.getObject(self.postParam, type: .postsType) as? Post {
                self.post = post
            }
        }

        self.generator = PostDetailGenerator(
            currentUser: self.currentUser,
            postParam: postParam,
            post: self.post,
            streamKind: .postDetail(postParam: postParam),
            destination: self
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        streamViewController.streamKind = generator.streamKind
        view.backgroundColor = .white
        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.initialLoadClosure = { [weak self] in self?.loadEntirePostDetail() }
        streamViewController.reloadClosure = { [weak self] in self?.reloadEntirePostDetail() }

        streamViewController.loadInitialPage()
    }

    // used to provide StreamableViewController access to the container it then
    // loads the StreamViewController's content into
    override func viewForStream() -> UIView {
        return view
    }

    private func updateInsets() {
        updateInsets(navBar: navigationBar)
    }

    override func didSetCurrentUser() {
        generator.currentUser = currentUser
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

    // MARK: private

    private func loadEntirePostDetail() {
        generator.load()
    }

    private func reloadEntirePostDetail() {
        generator.load(reload: true)
    }

    private func setupNavigationBar() {
        navigationBar = ElloNavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: ElloNavigationBar.Size.height))
        navigationBar.autoresizingMask = [.flexibleBottomMargin, .flexibleWidth]
        view.addSubview(navigationBar)

        setupNavigationItems()
    }

    private func setupNavigationItems() {
        navigationBar.leftItems = [.back]

        guard post != nil else {
            navigationBar.rightItems = []
            return
        }

        var rightItems: [ElloNavigationBar.Item] = []

        if isAuthorOfPost() {
            rightItems = [.delete, .edit]
        }
        else if currentUser != nil {
            rightItems = [.more, .share]
        }
        else if post?.author?.hasSharingEnabled == true {
            rightItems = [.share]
        }

        navigationBar.rightItems = rightItems
    }

    private func checkScrollToComment() {
        if let comment = self.scrollToComment {
            let commentItem = streamViewController.collectionViewDataSource.visibleCellItems.find { item in
                return (item.jsonable as? ElloComment)?.id == comment.id
            }

            if let commentItem = commentItem {
                scrollToItem(commentItem)
            }
        }
        else if scrollToComments {
            let commentItem = streamViewController.collectionViewDataSource.visibleCellItems.find { item in
                return item.type == .createComment
            }

            if let commentItem = commentItem {
                scrollToItem(commentItem)
            }
        }
    }

    private func scrollToItem(_ commentItem: StreamCellItem) {
        guard let indexPath = streamViewController.collectionViewDataSource.indexPath(forItem: commentItem) else { return }

        scrollToComment = nil
        scrollToComments = false

        // nextTick didn't work, the collection view hadn't shown its
        // cells or updated contentView.  so this.
        delay(0.1) {
            self.streamViewController.collectionView.scrollToItem(
                at: indexPath,
                at: .centeredVertically,
                animated: true
            )
        }
    }

    override func postTapped(_ post: Post) {
        if let selfPost = self.post, post.id != selfPost.id {
            super.postTapped(post)
        }
    }

    private func isAuthorOfPost() -> Bool {
        guard let post = post, let currentUser = currentUser else {
            return false
        }
        return currentUser.isAuthorOf(post: post)
    }

}

extension PostDetailViewController: PostCommentsResponder {
    func loadCommentsTapped() {
        guard
            let nextQuery = streamViewController.responseConfig?.nextQuery
        else { return }

        generator.loadMoreComments(nextQuery: nextQuery)
    }
}

// MARK: PostDetailViewController: PostDetailStreamDestination
extension PostDetailViewController: PostDetailStreamDestination {

    var isPagingEnabled: Bool {
        get { return streamViewController.isPagingEnabled }
        set { streamViewController.isPagingEnabled = newValue }
    }

    func replacePlaceholder(type: StreamCellType.PlaceholderType, items: [StreamCellItem], completion: @escaping Block) {
        streamViewController.replacePlaceholder(type: type, items: items) {
            if type == .postComments {
                self.checkScrollToComment()
            }

            if self.streamViewController.hasCellItems(for: .profileHeader) && !self.streamViewController.hasCellItems(for: .streamPosts) {
                self.streamViewController.replacePlaceholder(type: .streamPosts, items: [StreamCellItem(type: .streamLoading)])
            }
            completion()
        }
    }

    func setPlaceholders(items: [StreamCellItem]) {
        streamViewController.clearForInitialLoad(newItems: items)
    }

    func setPrimary(jsonable: JSONAble) {
        guard let post = jsonable as? Post else { return }

        self.post = post
        streamViewController.doneLoading()

        // need to reassign the userParam to the id for paging
        self.postParam = post.id

        /*
         - need to reassign the streamKind so that the comments
         can page based off the post.id from the ElloAPI.path

         - same for when tapping on a post token in a post this
         will replace '~CRAZY-TOKEN' with the correct id for
         paging to work
         */

        streamViewController.streamKind = .postDetail(postParam: postParam)

        self.title = post.author?.atName ?? InterfaceString.Post.DefaultTitle

        setupNavigationItems()

        if isAuthorOfPost() {
            showNavBars()
        }
    }

    func setPagingConfig(responseConfig: ResponseConfig) {
        streamViewController.responseConfig = responseConfig
    }

    func appendComments(_ commentItems: [StreamCellItem]) {
        streamViewController.appendPlaceholder(.postComments, with: commentItems)
    }

    func primaryJSONAbleNotFound() {
        if let deeplinkPath = self.deeplinkPath,
            let deeplinkURL = URL(string: deeplinkPath)
        {
            UIApplication.shared.openURL(deeplinkURL)
            self.deeplinkPath = nil
            _ = self.navigationController?.popViewController(animated: true)
        }
        else {
            self.showGenericLoadFailure()
        }
        self.streamViewController.doneLoading()
    }
}

extension PostDetailViewController: HasShareButton {
    func shareButtonTapped(_ sender: UIView) {
        guard
            let post = post,
            let shareLink = post.shareLink,
            let shareURL = URL(string: shareLink)
        else { return }

        Tracker.shared.postShared(post)
        showShareActivity(sender: sender, url: shareURL)
    }
}

extension PostDetailViewController: HasMoreButton {
    func moreButtonTapped() {
        guard let post = post else { return }

        let flagger = ContentFlagger(presentingController: self,
            flaggableId: post.id,
            contentType: .post)
        flagger.displayFlaggingSheet()
    }
}

extension PostDetailViewController: HasDeleteButton {
    func deleteButtonTapped() {
        guard let post = post, let currentUser = currentUser, isAuthorOfPost() else {
            return
        }

        let message = InterfaceString.Post.DeletePostConfirm
        let alertController = AlertViewController(message: message)

        let yesAction = AlertAction(title: InterfaceString.Yes, style: .dark) { _ in
            if let userPostCount = currentUser.postsCount {
                currentUser.postsCount = userPostCount - 1
                postNotification(CurrentUserChangedNotification, value: currentUser)
            }

            postNotification(PostChangedNotification, value: (post, .delete))
            PostService().deletePost(post.id)
                .then {
                    Tracker.shared.postDeleted(post)
                }
                .catch { error in
                    // TODO: add error handling
                }
        }
        let noAction = AlertAction(title: InterfaceString.No, style: .light, handler: .none)

        alertController.addAction(yesAction)
        alertController.addAction(noAction)

        self.present(alertController, animated: true, completion: nil)
    }
}

extension PostDetailViewController: HasEditButton {
    func editButtonTapped() {
        guard let post = post, isAuthorOfPost() else {
            return
        }

        editPost(post, fromController: self)
    }
}
