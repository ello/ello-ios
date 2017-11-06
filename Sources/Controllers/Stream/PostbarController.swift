////
///  PostbarController.swift
//

@objc
protocol PostbarResponder: class {
    func viewsButtonTapped(_ cell: UICollectionViewCell)
    func commentsButtonTapped(_ cell: StreamFooterCell, imageLabelControl: ImageLabelControl)
    func deleteCommentButtonTapped(_ cell: UICollectionViewCell)
    func editCommentButtonTapped(_ cell: UICollectionViewCell)
    func lovesButtonTapped(_ cell: StreamFooterCell)
    func repostButtonTapped(_ cell: UICollectionViewCell)
    func shareButtonTapped(_ cell: UICollectionViewCell, sourceView: UIView)
    func flagCommentButtonTapped(_ cell: UICollectionViewCell)
    func replyToCommentButtonTapped(_ cell: UICollectionViewCell)
    func replyToAllButtonTapped(_ cell: UICollectionViewCell)
    func watchPostTapped(_ isWatching: Bool, cell: StreamCreateCommentCell)
}

@objc
protocol LoveableCell: class {
    func toggleLoveControl(enabled: Bool)
    func toggleLoveState(loved: Bool)
}

class PostbarController: UIResponder, PostbarResponder {

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

    func viewsButtonTapped(_ cell: UICollectionViewCell) {
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let post = collectionViewDataSource.post(at: indexPath)
        else { return }

        Tracker.shared.viewsButtonTapped(post: post)

        let responder: StreamPostTappedResponder? = findProperResponder()
        responder?.postTappedInStream(cell)
    }

    func commentsButtonTapped(_ cell: StreamFooterCell, imageLabelControl: ImageLabelControl) {
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let item = collectionViewDataSource.streamCellItem(at: indexPath)
        else { return }

        guard collectionViewDataSource.isFullWidth(at: indexPath) else {
            cell.cancelCommentLoading()
            viewsButtonTapped(cell)
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
        cell.commentsControl.isEnabled = false

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

            PostService().loadMoreCommentsForPost(post.id)
                .then { [weak self] comments -> Void in
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

    func deleteCommentButtonTapped(_ cell: UICollectionViewCell) {
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
                .then {
                    Tracker.shared.commentDeleted(comment)
                }.ignoreErrors()
        }
        let noAction = AlertAction(title: InterfaceString.No, style: .light, handler: .none)

        alertController.addAction(yesAction)
        alertController.addAction(noAction)

        responderChainable?.controller?.present(alertController, animated: true, completion: .none)
    }

    func editCommentButtonTapped(_ cell: UICollectionViewCell) {
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

    func lovesButtonTapped(_ cell: StreamFooterCell) {
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let post = collectionViewDataSource.post(at: indexPath)
        else { return }

        toggleLove(cell, post: post, via: "button")
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
        postNotification(PostChangedNotification, value: (post, .loved))
        ElloLinkedStore.shared.setObject(post, forKey: post.id, type: .postsType)

        if let user = currentUser, let userLoveCount = user.lovesCount {
            user.lovesCount = userLoveCount - 1
            postNotification(CurrentUserChangedNotification, value: user)
            ElloLinkedStore.shared.setObject(user, forKey: user.id, type: .usersType)
        }

        LovesService().unlovePost(postId: post.id)
            .then { _ -> Void in
                guard let currentUser = self.currentUser else { return }

                let now = AppSetup.shared.now
                let love = Love(
                    id: "", createdAt: now, updatedAt: now,
                    isDeleted: true, postId: post.id, userId: currentUser.id
                )
                postNotification(JSONAbleChangedNotification, value: (love, .delete))
            }
            .always {
                cell?.toggleLoveControl(enabled: true)
            }
    }

    private func lovePost(_ post: Post, cell: LoveableCell?, via: String) {
        Tracker.shared.postLoved(post, via: via)
        post.isLoved = true
        if let count = post.lovesCount {
            post.lovesCount = count + 1
        }
        postNotification(PostChangedNotification, value: (post, .loved))
        ElloLinkedStore.shared.setObject(post, forKey: post.id, type: .postsType)

        if let user = currentUser, let userLoveCount = user.lovesCount {
            user.lovesCount = userLoveCount + 1
            postNotification(CurrentUserChangedNotification, value: user)
            ElloLinkedStore.shared.setObject(user, forKey: user.id, type: .usersType)
        }

        postNotification(HapticFeedbackNotifications.successfulUserEvent, value: ())

        LovesService().lovePost(postId: post.id)
            .then { love -> Void in
                postNotification(JSONAbleChangedNotification, value: (love, .create))
            }
            .always {
                cell?.toggleLoveControl(enabled: true)
            }
    }

    func repostButtonTapped(_ cell: UICollectionViewCell) {
        guard currentUser != nil else {
            postNotification(LoggedOutNotifications.userActionAttempted, value: .postTool)
            return
        }
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let post = collectionViewDataSource.post(at: indexPath),
            let presentingController = responderChainable?.controller
        else { return }

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

        presentingController.present(alertController, animated: true, completion: .none)
    }

    private func createRepost(_ post: Post, alertController: AlertViewController) {
        alertController.resetActions()
        alertController.isDismissable = false

        let spinnerContainer = UIView(frame: CGRect(x: 0, y: 0, width: alertController.view.frame.size.width, height: 200))
        let spinner = ElloLogoView(frame: CGRect(origin: .zero, size: ElloLogoView.Size.natural))
        spinner.center = spinnerContainer.bounds.center
        spinnerContainer.addSubview(spinner)
        alertController.contentView = spinnerContainer
        spinner.animateLogo()
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
            .then { repost -> Void in
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

    func shareButtonTapped(_ cell: UICollectionViewCell, sourceView: UIView) {
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let post = collectionViewDataSource.post(at: indexPath)
        else { return }

        sharePost(post, sourceView: sourceView)
    }

    func sharePost(_ post: Post, sourceView: UIView) {
        guard
            let shareLink = post.shareLink,
            let shareURL = URL(string: shareLink),
            let presentingController = responderChainable?.controller
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

    func flagCommentButtonTapped(_ cell: UICollectionViewCell) {
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

    func replyToCommentButtonTapped(_ cell: UICollectionViewCell) {
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

    func replyToAllButtonTapped(_ cell: UICollectionViewCell) {
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
            .then { [weak self] usernames -> Void in
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
            .then { post -> Void in
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

// MARK: - Private

    private func commentLoadSuccess(_ post: Post, comments jsonables: [JSONAble], indexPath: IndexPath, cell: StreamFooterCell) {
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

            cell.commentsControl.isEnabled = true

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
