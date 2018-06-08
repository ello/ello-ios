////
///  StreamFooterCellPresenter.swift
//

enum InteractionVisibility {
    case enabled
    case selectedAndEnabled
    case selectedAndDisabled
    case disabled
    case hidden

    var isVisible: Bool { return self != .hidden }
    var isEnabled: Bool { return self == .enabled || self == .selectedAndEnabled }
    var isSelected: Bool { return self == .selectedAndDisabled || self == .selectedAndEnabled }
}


struct StreamFooterCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard
            let cell = cell as? StreamFooterCell,
            let post = streamCellItem.jsonable as? Post
        else { return }

        let isGridView = streamCellItem.isGridView(streamKind: streamKind)
        configureDisplayCounts(cell, post: post, isGridView: isGridView)
        configureToolBarItems(cell, post: post, currentUser: currentUser, isGridView: isGridView)
        configureCommentControl(cell, post: post, streamCellItem: streamCellItem, streamKind: streamKind, currentUser: currentUser)
    }

    private static func configureDisplayCounts(
        _ cell: StreamFooterCell,
        post: Post,
        isGridView: Bool)
    {
        let rounding = isGridView ? 0 : 1
        if cell.frame.width < 155 {
            cell.views.title = ""
            cell.reposts.title = ""
            cell.loves.title = ""
        }
        else {
            cell.views.title = post.viewsCount?.numberToHuman(rounding: rounding)
            cell.reposts.title = post.repostsCount?.numberToHuman(rounding: rounding)
            cell.loves.title = post.lovesCount?.numberToHuman(rounding: rounding)
        }
        cell.comments.title = post.commentsCount?.numberToHuman(rounding: rounding)
    }

    private static func configureToolBarItems(
        _ cell: StreamFooterCell,
        post: Post,
        currentUser: User?,
        isGridView: Bool)
    {
        let (commentVisibility, loveVisibility, repostVisibility, shareVisibility) = toolbarItemVisibility(post: post, currentUser: currentUser, isGridView: isGridView)

        cell.updateToolbarItems(
            isGridView: isGridView,
            commentVisibility: commentVisibility,
            loveVisibility: loveVisibility,
            repostVisibility: repostVisibility,
            shareVisibility: shareVisibility
        )
    }

    static func toolbarItemVisibility(post: Post,
        currentUser: User?,
        isGridView: Bool) -> (commentVisibility: InteractionVisibility, loveVisibility: InteractionVisibility, repostVisibility: InteractionVisibility, shareVisibility: InteractionVisibility)
    {
        let ownPost = (currentUser?.id == post.authorId || (post.repostAuthor?.id != nil && currentUser?.id == post.repostAuthor?.id))

        let commentingEnabled = post.author?.hasCommentingEnabled ?? true
        let commentVisibility: InteractionVisibility = commentingEnabled ? .enabled : .hidden

        let lovingEnabled = post.author?.hasLovesEnabled ?? true
        var loveVisibility: InteractionVisibility = .enabled
        if post.isLoved { loveVisibility = .selectedAndEnabled }
        if !lovingEnabled { loveVisibility = .hidden }

        let repostingEnabled = post.author?.hasRepostingEnabled ?? true
        var repostVisibility: InteractionVisibility = .enabled
        if post.isReposted { repostVisibility = .disabled }
        else if !repostingEnabled { repostVisibility = .hidden }
        else if ownPost { repostVisibility = .disabled }

        let sharingEnabled = post.author?.hasSharingEnabled ?? true
        let shareVisibility: InteractionVisibility = sharingEnabled ? .enabled : .hidden


        return (commentVisibility: commentVisibility, loveVisibility: loveVisibility, repostVisibility: repostVisibility, shareVisibility: shareVisibility)
    }

    private static func configureCommentControl(
        _ cell: StreamFooterCell,
        post: Post,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        currentUser: User?)
    {
        if streamKind.isDetail(post: post) && currentUser == nil {
            let count = post.commentsCount ?? 0
            let open = count > 0
            cell.commentsOpened = open
            cell.comments.isSelected = open
        }
        else if streamKind.isDetail(post: post) {
            cell.commentsOpened = true
            cell.comments.isSelected = true
        }
        else {
            let isLoading = streamCellItem.state == .loading
            let isExpanded = streamCellItem.state == .expanded

            if isLoading {
                // this should be set via a custom accessor or method,
                // me thinks.
                // `StreamFooterCell.state = streamCellItem.state` ??
                cell.commentsAnimate()
                cell.comments.isSelected = true
            }
            else {
                cell.commentsFinishAnimation()

                if isExpanded {
                    cell.comments.isSelected = true
                    cell.commentsOpened = true
                }
                else {
                    cell.comments.isSelected = false
                    cell.commentsOpened = false
                    streamCellItem.state = .collapsed
                }
            }
        }
    }
}
