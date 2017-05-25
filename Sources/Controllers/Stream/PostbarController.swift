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
    func watchPostTapped(_ watching: Bool, cell: StreamCreateCommentCell)
}

class PostbarController: UIResponder, PostbarResponder {

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override var next: UIResponder? {
        return responderChainable?.next()
    }

    var responderChainable: ResponderChainableController?
    var collectionView: UICollectionView
    let dataSource: StreamDataSource
    var currentUser: User?

    // on the post detail screen, the comments don't show/hide
    var toggleableComments: Bool = true

    init(collectionView: UICollectionView, dataSource: StreamDataSource) {
        self.collectionView = collectionView
        self.dataSource = dataSource
    }

    // in order to include the `StreamViewController` in our responder chain
    // search, we need to ask it directly for the correct target.  If the
    // `StreamViewController` isn't returned, this function returns the same
    // object as `target(forAction:,withSender:)`
    func properTarget(forAction action: Selector, withSender sender: Any?) -> Any? {
        return responderChainable?.controller?.target(forAction: action, withSender: sender)
    }

    func viewsButtonTapped(_ cell: UICollectionViewCell) {
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let post = postForIndexPath(indexPath)
        else { return }

        Tracker.shared.viewsButtonTapped(post: post)

        let responder = properTarget(forAction: #selector(StreamPostTappedResponder.postTappedInStream(_:)), withSender: self) as? StreamPostTappedResponder
        responder?.postTappedInStream(cell)
    }

    func commentsButtonTapped(_ cell: StreamFooterCell, imageLabelControl: ImageLabelControl) {
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let item = dataSource.visibleStreamCellItem(at: indexPath)
        else { return }

        guard
            dataSource.isFullWidthAtIndexPath(indexPath)
        else {
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

        guard !dataSource.streamKind.isDetail(post: post) else {
            return
        }

        imageLabelControl.isSelected = cell.commentsOpened
        cell.commentsControl.isEnabled = false

        if !cell.commentsOpened {
            self.dataSource.removeCommentsFor(post: post)
            self.collectionView.reloadData()
            item.state = .collapsed
            imageLabelControl.isEnabled = true
            imageLabelControl.finishAnimation()
            imageLabelControl.isHighlighted = false
        }
        else {
            item.state = .loading
            imageLabelControl.isHighlighted = true
            imageLabelControl.animate()

            StreamService().loadMoreCommentsForPost(post.id)
                .onSuccess { [weak self] response in
                    guard
                        let `self` = self,
                        let updatedIndexPath = self.dataSource.indexPathForItem(item)
                    else { return }

                    item.state = .expanded
                    imageLabelControl.finishAnimation()
                    let nextIndexPath = IndexPath(item: updatedIndexPath.row + 1, section: updatedIndexPath.section)

                    switch response {
                    case let .jsonables(comments, responseConfig):
                        self.commentLoadSuccess(post, comments: comments, indexPath: nextIndexPath, cell: cell)
                    case .empty:
                        self.commentLoadSuccess(post, comments: [], indexPath: nextIndexPath, cell: cell)
                    }
                }
                .onFail { _ in
                    item.state = .collapsed
                    imageLabelControl.finishAnimation()
                    cell.cancelCommentLoading()
                    print("comment load failure")
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

        let yesAction = AlertAction(title: InterfaceString.Yes, style: .dark) {
            action in
            if let comment = self.commentForIndexPath(indexPath) {
                // comment deleted
                postNotification(CommentChangedNotification, value: (comment, .delete))
                // post comment count updated
                ContentChange.updateCommentCount(comment, delta: -1)
                PostService().deleteComment(comment.postId, commentId: comment.id)
                    .onSuccess {
                        Tracker.shared.commentDeleted(comment)
                    }
                    .onFail { error in
                        // TODO: add error handling
                        print("failed to delete comment, error: \(error)")
                    }
            }
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
            let comment = commentForIndexPath(indexPath),
            let presentingController = responderChainable?.controller
        else { return }

        let responder = properTarget(forAction: #selector(CreatePostResponder.editComment(_:fromController:)), withSender: self) as? CreatePostResponder
        responder?.editComment(comment, fromController: presentingController)
    }

    func lovesButtonTapped(_ cell: StreamFooterCell) {
        guard currentUser != nil else {
            postNotification(LoggedOutNotifications.userActionAttempted, value: .postTool)
            return
        }

        guard
            let indexPath = collectionView.indexPath(for: cell),
            let post = self.postForIndexPath(indexPath)
        else { return }

        toggleLove(cell, post: post, via: "button")
    }

    func toggleLove(_ cell: StreamFooterCell?, post: Post, via: String) {
        cell?.lovesControl.isUserInteractionEnabled = false

        if post.loved { unlovePost(post, cell: cell) }
        else { lovePost(post, cell: cell, via: via) }
    }

    fileprivate func unlovePost(_ post: Post, cell: StreamFooterCell?) {
        Tracker.shared.postUnloved(post)
        if let count = post.lovesCount {
            post.lovesCount = count - 1
            post.loved = false
            postNotification(PostChangedNotification, value: (post, .loved))
        }

        if let user = currentUser, let userLoveCount = user.lovesCount {
            user.lovesCount = userLoveCount - 1
            postNotification(CurrentUserChangedNotification, value: user)
        }

        let service = LovesService()
        service.unlovePost(
            postId: post.id,
            success: {
                if let currentUser = self.currentUser {
                    let love = Love(
                        id: "", createdAt: Date(), updatedAt: Date(),
                        deleted: true, postId: post.id, userId: currentUser.id
                        )
                    postNotification(JSONAbleChangedNotification, value: (love, .delete))
                }
                cell?.lovesControl.isUserInteractionEnabled = true
            },
            failure: { error, statusCode in
                cell?.lovesControl.isUserInteractionEnabled = true
                print("failed to unlove post \(post.id), error: \(error.elloErrorMessage ?? error.localizedDescription)")
            })
    }

    fileprivate func lovePost(_ post: Post, cell: StreamFooterCell?, via: String) {
        Tracker.shared.postLoved(post, via: via)
        if let count = post.lovesCount {
            post.lovesCount = count + 1
            post.loved = true
            postNotification(PostChangedNotification, value: (post, .loved))
        }
        if let user = currentUser, let userLoveCount = user.lovesCount {
            user.lovesCount = userLoveCount + 1
            postNotification(CurrentUserChangedNotification, value: user)
        }
        LovesService().lovePost(
            postId: post.id,
            success: { (love, responseConfig) in
                postNotification(JSONAbleChangedNotification, value: (love, .create))
                cell?.lovesControl.isUserInteractionEnabled = true
            },
            failure: { error, statusCode in
                cell?.lovesControl.isUserInteractionEnabled = true
                print("failed to love post \(post.id), error: \(error.elloErrorMessage ?? error.localizedDescription)")
            })
    }

    func repostButtonTapped(_ cell: UICollectionViewCell) {
        guard currentUser != nil else {
            postNotification(LoggedOutNotifications.userActionAttempted, value: .postTool)
            return
        }
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let post = self.postForIndexPath(indexPath),
            let presentingController = responderChainable?.controller
        else { return }

        Tracker.shared.postReposted(post)
        let message = InterfaceString.Post.RepostConfirm
        let alertController = AlertViewController(message: message)
        alertController.autoDismiss = false

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

    fileprivate func createRepost(_ post: Post, alertController: AlertViewController) {
        alertController.resetActions()
        alertController.dismissable = false

        let spinnerContainer = UIView(frame: CGRect(x: 0, y: 0, width: alertController.view.frame.size.width, height: 200))
        let spinner = ElloLogoView(frame: CGRect(origin: .zero, size: ElloLogoView.Size.Natural))
        spinner.center = spinnerContainer.bounds.center
        spinnerContainer.addSubview(spinner)
        alertController.contentView = spinnerContainer
        spinner.animateLogo()
        if let user = currentUser, let userPostsCount = user.postsCount {
            user.postsCount = userPostsCount + 1
            postNotification(CurrentUserChangedNotification, value: user)
        }

        post.reposted = true
        if let repostsCount = post.repostsCount {
            post.repostsCount = repostsCount + 1
        }
        else {
            post.repostsCount = 1
        }
        ElloLinkedStore.sharedInstance.setObject(post, forKey: post.id, type: .postsType)
        postNotification(PostChangedNotification, value: (post, .reposted))

        RePostService().repost(post: post,
            success: { repost in
                postNotification(PostChangedNotification, value: (repost, .create))
                alertController.contentView = nil
                alertController.message = InterfaceString.Post.RepostSuccess
                delay(1) {
                    alertController.dismiss()
                }
            }, failure: { (error, statusCode)  in
                alertController.contentView = nil
                alertController.message = InterfaceString.Post.RepostError
                alertController.autoDismiss = true
                alertController.dismissable = true
                let okAction = AlertAction(title: InterfaceString.OK, style: .light, handler: .none)
                alertController.addAction(okAction)
            })
    }

    func shareButtonTapped(_ cell: UICollectionViewCell, sourceView: UIView) {
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let post = dataSource.postForIndexPath(indexPath),
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
            let comment = commentForIndexPath(indexPath),
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
            let comment = commentForIndexPath(indexPath),
            let presentingController = responderChainable?.controller,
            let atName = comment.author?.atName
        else { return }

        let postId = comment.loadedFromPostId

        let responder = properTarget(forAction: #selector(CreatePostResponder.createComment(_:text:fromController:)), withSender: self) as? CreatePostResponder
        responder?.createComment(postId, text: "\(atName) ", fromController: presentingController)
    }

    func replyToAllButtonTapped(_ cell: UICollectionViewCell) {
        guard currentUser != nil else {
            postNotification(LoggedOutNotifications.userActionAttempted, value: .postTool)
            return
        }
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let comment = commentForIndexPath(indexPath),
            let presentingController = responderChainable?.controller
        else { return }

        let postId = comment.loadedFromPostId
        PostService().loadReplyAll(postId)
            .onSuccess { [weak self] usernames in
                guard let `self` = self else { return }
                let usernamesText = usernames.reduce("") { memo, username in
                    return memo + "@\(username) "
                }
                let responder = self.properTarget(forAction: #selector(CreatePostResponder.createComment(_:text:fromController:)), withSender: self) as? CreatePostResponder
                responder?.createComment(postId, text: usernamesText, fromController: presentingController)
            }
            .onFail { [weak self] error in
                guard let `self` = self else { return }
                guard let controller = self.responderChainable?.controller else { return }

                let responder = self.properTarget(forAction: #selector(CreatePostResponder.createComment(_:text:fromController:)), withSender: self) as? CreatePostResponder
                responder?.createComment(postId, text: nil, fromController: controller)
            }
    }

    func watchPostTapped(_ watching: Bool, cell: StreamCreateCommentCell) {
        guard currentUser != nil else {
            postNotification(LoggedOutNotifications.userActionAttempted, value: .postTool)
            return
        }
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let comment = dataSource.commentForIndexPath(indexPath),
            let post = comment.parentPost
        else { return }

        cell.watching = watching
        cell.isUserInteractionEnabled = false
        PostService().toggleWatchPost(post, watching: watching)
            .onSuccess { post in
                cell.isUserInteractionEnabled = true
                postNotification(PostChangedNotification, value: (post, .watching))
            }
            .onFail { error in
                cell.isUserInteractionEnabled = true
                cell.watching = !watching
            }
    }

// MARK: - Private

    fileprivate func postForIndexPath(_ indexPath: IndexPath) -> Post? {
        return dataSource.postForIndexPath(indexPath)
    }

    fileprivate func commentForIndexPath(_ indexPath: IndexPath) -> ElloComment? {
        return dataSource.commentForIndexPath(indexPath)
    }

    fileprivate func commentLoadSuccess(_ post: Post, comments jsonables: [JSONAble], indexPath: IndexPath, cell: StreamFooterCell) {
        self.appendCreateCommentItem(post, at: indexPath)
        let commentsStartingIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)

        var items = StreamCellItemParser().parse(jsonables, streamKind: StreamKind.following, currentUser: currentUser)

        if let lastComment = jsonables.last,
            let maxCount = ElloAPI.postComments(postId: "").parameters!["per_page"] as? Int,
            let postCommentCount = post.commentsCount,
            postCommentCount > maxCount
        {
            items.append(StreamCellItem(jsonable: lastComment, type: .seeMoreComments))
        }
        else {
            items.append(StreamCellItem(type: .spacer(height: 10.0)))
        }

        self.dataSource.insertUnsizedCellItems(items,
            withWidth: self.collectionView.frame.width,
            startingIndexPath: commentsStartingIndexPath) { [weak self] (indexPaths) in
                guard let `self` = self else { return }
                self.collectionView.reloadData() // insertItemsAtIndexPaths(indexPaths)
                cell.commentsControl.isEnabled = true

                if let controller = self.responderChainable?.controller,
                    indexPaths.count == 1, jsonables.count == 0, self.currentUser != nil
                {
                    let responder = self.properTarget(forAction: #selector(CreatePostResponder.createComment(_:text:fromController:)), withSender: self) as? CreatePostResponder
                    responder?.createComment(post.id, text: nil, fromController: controller)
                }
            }
    }

    fileprivate func appendCreateCommentItem(_ post: Post, at indexPath: IndexPath) {
        guard let currentUser = currentUser else { return }

        let comment = ElloComment.newCommentForPost(post, currentUser: currentUser)
        let createCommentItem = StreamCellItem(jsonable: comment, type: .createComment)

        let items = [createCommentItem]
        self.dataSource.insertStreamCellItems(items, startingIndexPath: indexPath)
        self.collectionView.reloadData() // insertItemsAtIndexPaths([indexPath]) //
    }

    fileprivate func commentLoadFailure(_ error: NSError, statusCode: Int?) {
    }

}
