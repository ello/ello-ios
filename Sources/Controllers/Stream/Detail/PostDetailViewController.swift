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

    var navigationBar: ElloNavigationBar!
    var deeplinkPath: String?
    var generator: PostDetailGenerator!

    required init(postParam: String) {
        self.postParam = postParam
        super.init(nibName: nil, bundle: nil)
        if self.post == nil {
            if let post = ElloLinkedStore.sharedInstance.getObject(self.postParam, type: .postsType) as? Post {
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

    required init?(coder aDecoder: NSCoder) {
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

    fileprivate func updateInsets() {
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

    // MARK : private

    fileprivate func loadEntirePostDetail() {
        generator.load()
    }

    fileprivate func reloadEntirePostDetail() {
        generator.load(reload: true)
    }

    fileprivate func setupNavigationBar() {
        navigationBar = ElloNavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: ElloNavigationBar.Size.height))
        navigationBar.autoresizingMask = [.flexibleBottomMargin, .flexibleWidth]
        view.addSubview(navigationBar)

        setupNavigationItems()
    }

    fileprivate func setupNavigationItems() {
        let backItem = UIBarButtonItem.backChevron(withController: self)
        elloNavigationItem.leftBarButtonItems = [backItem]
        elloNavigationItem.fixNavBarItemPadding()
        navigationBar.items = [elloNavigationItem]

        guard post != nil else {
            elloNavigationItem.rightBarButtonItems = []
            return
        }

        var rightBarButtonItems: [UIBarButtonItem] = []

        if isOwnPost() {
            rightBarButtonItems = [
                UIBarButtonItem(image: .xBox, target: self, action: #selector(PostDetailViewController.deletePost)),
                UIBarButtonItem(image: .pencil, target: self, action: #selector(PostDetailViewController.editPostAction)),
            ]
        }
        else if currentUser != nil {
            rightBarButtonItems = [UIBarButtonItem(image: .dots, target: self, action: #selector(PostDetailViewController.flagPost))]
        }

        if !elloNavigationItem.areRightButtonsTheSame(rightBarButtonItems) {
            elloNavigationItem.rightBarButtonItems = rightBarButtonItems
        }
    }

    fileprivate func checkScrollToComment() {
        guard let comment = self.scrollToComment else { return }

        let commentItem = streamViewController.dataSource.visibleCellItems.find { item in
            return (item.jsonable as? ElloComment)?.id == comment.id
        }

        if let commentItem = commentItem, let indexPath = self.streamViewController.dataSource.indexPathForItem(commentItem) {
            self.scrollToComment = nil
            // nextTick didn't work, the collection view hadn't shown its
            // cells or updated contentView.  so this.
            delay(0.1) {
                self.streamViewController.collectionView.scrollToItem(
                    at: indexPath,
                    at: .top,
                    animated: true
                )
            }
        }
    }

    override func postTapped(_ post: Post) {
        if let selfPost = self.post, post.id != selfPost.id {
            super.postTapped(post)
        }
    }

    fileprivate func isOwnPost() -> Bool {
        guard let post = post, let currentUser = currentUser else {
            return false
        }
        return currentUser.isOwn(post: post)
    }

    func flagPost() {
        guard let post = post else { return }

        let flagger = ContentFlagger(presentingController: self,
            flaggableId: post.id,
            contentType: .post)
        flagger.displayFlaggingSheet()
    }

    func editPostAction() {
        guard let post = post, isOwnPost() else {
            return
        }

        editPost(post, fromController: self)
    }

    func deletePost() {
        guard let post = post, let currentUser = currentUser, isOwnPost() else {
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
                .onSuccess {
                    Tracker.shared.postDeleted(post)
                }
                .onFail { error in
                    // TODO: add error handling
                    print("failed to delete post, error: \(error)")
                }
        }
        let noAction = AlertAction(title: InterfaceString.No, style: .light, handler: .none)

        alertController.addAction(yesAction)
        alertController.addAction(noAction)

        self.present(alertController, animated: true, completion: .none)
    }

}

extension PostDetailViewController: PostCommentsResponder {
    func loadCommentsTapped() {
        guard
            let nextQueryItems = streamViewController.responseConfig?.nextQueryItems
        else { return }

        generator.loadMoreComments(nextQueryItems: nextQueryItems)
    }
}

// MARK: PostDetailViewController: PostDetailStreamDestination
extension PostDetailViewController: PostDetailStreamDestination {

    var pagingEnabled: Bool {
        get { return streamViewController.pagingEnabled }
        set { streamViewController.pagingEnabled = newValue }
    }

    func replacePlaceholder(type: StreamCellType.PlaceholderType, items: [StreamCellItem], completion: @escaping ElloEmptyCompletion) {
        streamViewController.replacePlaceholder(type: type, items: items) {
            self.checkScrollToComment()

            if self.streamViewController.hasCellItems(for: .profileHeader) && !self.streamViewController.hasCellItems(for: .profilePosts) {
                self.streamViewController.replacePlaceholder(type: .profilePosts, items: [StreamCellItem(type: .streamLoading)]) {}
            }
            completion()
        }
    }

    func setPlaceholders(items: [StreamCellItem]) {
        streamViewController.clearForInitialLoad()
        streamViewController.appendStreamCellItems(items)
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

        if isOwnPost() {
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
