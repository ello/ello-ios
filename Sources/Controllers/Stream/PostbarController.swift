////
///  PostbarController.swift
//

@objc
protocol LoveableCell: class {
    func toggleLoveControl(enabled: Bool)
    func toggleLoveState(loved: Bool)
}

class PostbarController: UIResponder {

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override var next: UIResponder? {
        return responderChainable?.next()
    }

    var responderChainable: ResponderChainableController?
    weak var streamViewController: StreamViewController!
    weak var collectionViewDataSource: CollectionViewDataSource!
    // overrideable to make specs easier to write
    weak var collectionView: UICollectionView!

    var currentUser: User? { return streamViewController.currentUser }

    // on the post detail screen, the comments don't show/hide
    var toggleableComments: Bool = true

    init(streamViewController: StreamViewController, collectionViewDataSource: CollectionViewDataSource) {
        self.streamViewController = streamViewController
        self.collectionView = streamViewController.collectionView
        self.collectionViewDataSource = collectionViewDataSource
    }

    // in order to include the `StreamViewController` in our responder chain
    // search, we need to ask it directly for the correct responder.  If the
    // `StreamViewController` isn't returned, this function returns the same
    // object as `findResponder`
    func findProperResponder<T>() -> T? {
        if let responder: T? = findResponder() {
            return responder
        }
        else {
            return responderChainable?.controller?.findResponder()
        }
    }

    func viewsButtonTapped(cell: UICollectionViewCell) {
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let post = collectionViewDataSource.post(at: indexPath)
        else { return }

        Tracker.shared.viewsButtonTapped(post: post)

        let responder: StreamPostTappedResponder? = findProperResponder()
        responder?.postTappedInStream(cell)
    }

    func viewsButtonTapped(post: Post, scrollToComments: Bool) {
        Tracker.shared.viewsButtonTapped(post: post)

        let responder: PostTappedResponder? = findProperResponder()
        responder?.postTapped(post, scrollToComments: scrollToComments)
    }

    func commentsButtonTapped(cell: StreamFooterCell, imageLabelControl: ImageLabelControl) {
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let item = collectionViewDataSource.streamCellItem(at: indexPath)
        else { return }

        guard collectionViewDataSource.isFullWidth(at: indexPath) else {
            cell.cancelCommentLoading()
            viewsButtonTapped(cell: cell)
            return
        }

        guard toggleableComments else {
            cell.cancelCommentLoading()
            return
        }

        guard
            let post = item.jsonable as? Post
        else {
            cell.cancelCommentLoading()
            return
        }

        if let commentCount = post.commentsCount, commentCount == 0, currentUser == nil {
            postNotification(LoggedOutNotifications.userActionAttempted, value: .postTool)
            return
        }

        guard !streamViewController.streamKind.isDetail(post: post) else {
            return
        }

        imageLabelControl.isSelected = cell.commentsOpened
        cell.comments.isEnabled = false

        if !cell.commentsOpened {
            streamViewController.removeComments(forPost: post)
            item.state = .collapsed
            imageLabelControl.isEnabled = true
            imageLabelControl.finishAnimation()
            imageLabelControl.isHighlighted = false
        }
        else {
            item.state = .loading
            imageLabelControl.isHighlighted = true
            imageLabelControl.animate()

            PostService().loadPostComments(post.id)
                .done { [weak self] (comments, config) in
                    guard
                        let `self` = self,
                        let updatedIndexPath = self.collectionViewDataSource.indexPath(forItem: item)
                    else { return }

                    item.state = .expanded
                    imageLabelControl.finishAnimation()
                    let nextIndexPath = IndexPath(item: updatedIndexPath.row + 1, section: updatedIndexPath.section)

                    self.commentLoadSuccess(post, comments: comments, indexPath: nextIndexPath, cell: cell)
                }
                .catch { _ in
                    item.state = .collapsed
                    imageLabelControl.finishAnimation()
                    cell.cancelCommentLoading()
                }
        }
    }

    func deleteCommentButtonTapped(cell: UICollectionViewCell) {
        guard currentUser != nil else {
            postNotification(LoggedOutNotifications.userActionAttempted, value: .postTool)
            return
        }
        guard let indexPath = collectionView.indexPath(for: cell) else { return }

        let message = InterfaceString.Post.DeleteCommentConfirm
        let alertController = AlertViewController(message: message)

        let yesAction = AlertAction(title: InterfaceString.Yes, style: .dark) { action in
            guard let comment = self.collectionViewDataSource.comment(at: indexPath) else { return }

            postNotification(CommentChangedNotification, value: (comment, .delete))
            ContentChange.updateCommentCount(comment, delta: -1)

            PostService().deleteComment(comment.postId, commentId: comment.id)
                .done {
                    Tracker.shared.commentDeleted(comment)
                }.ignoreErrors()
        }
        let noAction = AlertAction(title: InterfaceString.No, style: .light, handler: .none)

        alertController.addAction(yesAction)
        alertController.addAction(noAction)

        responderChainable?.controller?.present(alertController, animated: true, completion: nil)
    }

    func editCommentButtonTapped(cell: UICollectionViewCell) {
        guard currentUser != nil else {
            postNotification(LoggedOutNotifications.userActionAttempted, value: .postTool)
            return
        }
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let comment = collectionViewDataSource.comment(at: indexPath),
            let presentingController = responderChainable?.controller
        else { return }

        let responder: CreatePostResponder? = self.findProperResponder()
        responder?.editComment(comment, fromController: presentingController)
    }

    func lovesButtonTapped(cell: StreamFooterCell) {
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let post = collectionViewDataSource.post(at: indexPath)
        else { return }

        toggleLove(cell, post: post, via: "button")
    }

    func lovesButtonTapped(post: Post) {
        toggleLove(nil, post: post, via: "button")
    }

    func toggleLove(_ cell: LoveableCell?, post: Post, via: String) {
        guard currentUser != nil else {
            postNotification(LoggedOutNotifications.userActionAttempted, value: .postTool)
            return
        }

        cell?.toggleLoveState(loved: !post.isLoved)
        cell?.toggleLoveControl(enabled: false)

        if post.isLoved { unlovePost(post, cell: cell) }
        else { lovePost(post, cell: cell, via: via) }
    }

    private func unlovePost(_ post: Post, cell: LoveableCell?) {
        Tracker.shared.postUnloved(post)
        post.isLoved = false
        if let count = post.lovesCount {
            post.lovesCount = count - 1
        }
        ElloLinkedStore.shared.setObject(post, forKey: post.id, type: .postsType)
        postNotification(PostChangedNotification, value: (post, .loved))

        if let user = currentUser, let userLoveCount = user.lovesCount {
            user.lovesCount = userLoveCount - 1
            ElloLinkedStore.shared.setObject(user, forKey: user.id, type: .usersType)
            postNotification(CurrentUserChangedNotification, value: user)
        }

        LovesService().unlovePost(postId: post.id)
            .done { _ in
                guard let currentUser = self.currentUser else { return }

                let love = Love(
                    id: "",
                    isDeleted: true, postId: post.id, userId: currentUser.id
                )
                postNotification(ModelChangedNotification, value: (love, .delete))
            }
            .ensure {
                cell?.toggleLoveControl(enabled: true)
            }
            .ignoreErrors()
    }

    private func lovePost(_ post: Post, cell: LoveableCell?, via: String) {
        Tracker.shared.postLoved(post, via: via)
        post.isLoved = true
        if let count = post.lovesCount {
            post.lovesCount = count + 1
        }
        ElloLinkedStore.shared.setObject(post, forKey: post.id, type: .postsType)
        postNotification(PostChangedNotification, value: (post, .loved))

        if let user = currentUser, let userLoveCount = user.lovesCount {
            user.lovesCount = userLoveCount + 1
            ElloLinkedStore.shared.setObject(user, forKey: user.id, type: .usersType)
            postNotification(CurrentUserChangedNotification, value: user)
        }

        postNotification(HapticFeedbackNotifications.successfulUserEvent, value: ())

        LovesService().lovePost(postId: post.id)
            .done { love in
                postNotification(ModelChangedNotification, value: (love, .create))
            }
            .ensure {
                cell?.toggleLoveControl(enabled: true)
            }
            .ignoreErrors()
    }

    func repostButtonTapped(cell: UICollectionViewCell) {
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let post = collectionViewDataSource.post(at: indexPath)
        else { return }

        repostButtonTapped(post: post)
    }

    func repostButtonTapped(post: Post, presentingController presenter: UIViewController? = nil) {
        guard currentUser != nil else {
            postNotification(LoggedOutNotifications.userActionAttempted, value: .postTool)
            return
        }
        guard let presentingController = presenter ?? responderChainable?.controller else { return }

        Tracker.shared.postReposted(post)
        let message = InterfaceString.Post.RepostConfirm
        let alertController = AlertViewController(message: message)
        alertController.shouldAutoDismiss = false

        let yesAction = AlertAction(title: InterfaceString.Yes, style: .dark) { action in
            self.createRepost(post, alertController: alertController)
        }
        let noAction = AlertAction(title: InterfaceString.No, style: .light) { action in
            alertController.dismiss()
        }

        alertController.addAction(yesAction)
        alertController.addAction(noAction)

        presentingController.present(alertController, animated: true, completion: nil)
    }

    private func createRepost(_ post: Post, alertController: AlertViewController) {
        alertController.resetActions()
        alertController.isDismissable = false

        let spinnerContainer = Container(frame: CGRect(x: 0, y: 0, width: alertController.view.frame.size.width, height: 200))
        let spinner = GradientLoadingView(frame: CGRect(origin: .zero, size: GradientLoadingView.Size.size))
        spinner.center = spinnerContainer.bounds.center
        spinnerContainer.addSubview(spinner)
        alertController.contentView = spinnerContainer
        spinner.startAnimating()
        if let user = currentUser, let userPostsCount = user.postsCount {
            user.postsCount = userPostsCount + 1
            postNotification(CurrentUserChangedNotification, value: user)
        }

        post.isReposted = true
        if let repostsCount = post.repostsCount {
            post.repostsCount = repostsCount + 1
        }
        else {
            post.repostsCount = 1
        }
        ElloLinkedStore.shared.setObject(post, forKey: post.id, type: .postsType)
        postNotification(PostChangedNotification, value: (post, .reposted))

        RePostService().repost(post: post)
            .done { repost in
                postNotification(PostChangedNotification, value: (repost, .create))
                postNotification(HapticFeedbackNotifications.successfulUserEvent, value: ())
                alertController.contentView = nil
                alertController.message = InterfaceString.Post.RepostSuccess
                delay(1) {
                    alertController.dismiss()
                }
            }
            .catch { _ in
                alertController.contentView = nil
                alertController.message = InterfaceString.Post.RepostError
                alertController.shouldAutoDismiss = true
                alertController.isDismissable = true
                let okAction = AlertAction(title: InterfaceString.OK, style: .light, handler: .none)
                alertController.addAction(okAction)
            }
    }

    func shareButtonTapped(cell: UICollectionViewCell, sourceView: UIView) {
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let post = collectionViewDataSource.post(at: indexPath)
        else { return }

        shareButtonTapped(post: post, sourceView: sourceView)
    }

    func shareButtonTapped(post: Post, sourceView: UIView, presentingController presenter: UIViewController? = nil) {
        guard
            let shareLink = post.shareLink,
            let shareURL = URL(string: shareLink),
            let presentingController = presenter ?? responderChainable?.controller
        else { return }

        Tracker.shared.postShared(post)
        let activityVC = UIActivityViewController(activityItems: [shareURL], applicationActivities: [SafariActivity()])
        if UI_USER_INTERFACE_IDIOM() == .phone {
            activityVC.modalPresentationStyle = .fullScreen
            presentingController.present(activityVC, animated: true) { }
        }
        else {
            activityVC.modalPresentationStyle = .popover
            activityVC.popoverPresentationController?.sourceView = sourceView
            presentingController.present(activityVC, animated: true) { }
        }
    }

    func flagCommentButtonTapped(cell: UICollectionViewCell) {
        guard currentUser != nil else {
            postNotification(LoggedOutNotifications.userActionAttempted, value: .postTool)
            return
        }
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let comment = collectionViewDataSource.comment(at: indexPath),
            let presentingController = responderChainable?.controller
        else { return }

        let flagger = ContentFlagger(
            presentingController: presentingController,
            flaggableId: comment.id,
            contentType: .comment,
            commentPostId: comment.postId
        )

        flagger.displayFlaggingSheet()
    }

    func replyToCommentButtonTapped(cell: UICollectionViewCell) {
        guard currentUser != nil else {
            postNotification(LoggedOutNotifications.userActionAttempted, value: .postTool)
            return
        }
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let comment = collectionViewDataSource.comment(at: indexPath),
            let presentingController = responderChainable?.controller,
            let atName = comment.author?.atName
        else { return }

        let postId = comment.loadedFromPostId

        let responder: CreatePostResponder? = self.findProperResponder()
        responder?.createComment(postId, text: "\(atName) ", fromController: presentingController)
    }

    func replyToAllButtonTapped(cell: UICollectionViewCell) {
        guard currentUser != nil else {
            postNotification(LoggedOutNotifications.userActionAttempted, value: .postTool)
            return
        }
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let comment = collectionViewDataSource.comment(at: indexPath),
            let presentingController = responderChainable?.controller
        else { return }

        let postId = comment.loadedFromPostId
        PostService().loadReplyAll(postId)
            .done { [weak self] usernames in
                guard let `self` = self else { return }
                let usernamesText = usernames.reduce("") { memo, username in
                    return memo + "@\(username) "
                }
                let responder: CreatePostResponder? = self.findProperResponder()
                responder?.createComment(postId, text: usernamesText, fromController: presentingController)
            }
            .catch { [weak self] error in
                guard let `self` = self else { return }
                guard let controller = self.responderChainable?.controller else { return }

                let responder: CreatePostResponder? = self.findProperResponder()
                responder?.createComment(postId, text: nil, fromController: controller)
            }
    }

    func watchPostTapped(_ isWatching: Bool, cell: StreamCreateCommentCell) {
        guard currentUser != nil else {
            postNotification(LoggedOutNotifications.userActionAttempted, value: .postTool)
            return
        }
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let comment = collectionViewDataSource.comment(at: indexPath),
            let post = comment.parentPost
        else { return }

        cell.isWatching = isWatching
        cell.isUserInteractionEnabled = false
        PostService().toggleWatchPost(post, isWatching: isWatching)
            .done { post in
                cell.isUserInteractionEnabled = true
                if isWatching {
                    Tracker.shared.postWatched(post)
                }
                else {
                    Tracker.shared.postUnwatched(post)
                }
                postNotification(PostChangedNotification, value: (post, .watching))
            }
            .catch { error in
                cell.isUserInteractionEnabled = true
                cell.isWatching = !isWatching
            }
    }

    private func commentLoadSuccess(_ post: Post, comments jsonables: [Model], indexPath: IndexPath, cell: StreamFooterCell) {
        let createCommentNow = jsonables.count == 0
        self.appendCreateCommentItem(post, at: indexPath)

        var items = StreamCellItemParser().parse(jsonables, streamKind: StreamKind.following, currentUser: currentUser)

        if let lastComment = jsonables.last,
            let postCommentsCount = post.commentsCount,
            postCommentsCount > jsonables.count
        {
            items.append(StreamCellItem(jsonable: lastComment, type: .seeMoreComments))
        }
        else {
            items.append(StreamCellItem(type: .spacer(height: 10.0)))
        }

        streamViewController.insertUnsizedCellItems(items, startingIndexPath: indexPath) { [weak self] in
            guard let `self` = self else { return }

            cell.comments.isEnabled = true

            if let controller = self.responderChainable?.controller,
                createCommentNow,
                self.currentUser != nil
            {
                let responder: CreatePostResponder? = self.findProperResponder()
                responder?.createComment(post.id, text: nil, fromController: controller)
            }
        }
    }

    private func appendCreateCommentItem(_ post: Post, at indexPath: IndexPath) {
        guard let currentUser = currentUser else { return }

        let comment = ElloComment.newCommentForPost(post, currentUser: currentUser)
        let createCommentItem = StreamCellItem(jsonable: comment, type: .createComment)

        let items = [createCommentItem]
        streamViewController.insertUnsizedCellItems(items, startingIndexPath: indexPath)
    }

}
