////
///  StreamFooterCellPresenter.swift
//

import Foundation


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
        if let cell = cell as? StreamFooterCell,
            let post = streamCellItem.jsonable as? Post
        {
            configureDisplayCounts(cell, post: post, streamKind: streamKind)
            configureToolBarItems(cell, post: post, currentUser: currentUser, streamKind: streamKind)
            configureCommentControl(cell, streamCellItem: streamCellItem, streamKind: streamKind)
        }
    }

    fileprivate static func configureToolBarItems(
        _ cell: StreamFooterCell,
        post: Post,
        currentUser: User?,
        streamKind: StreamKind)
    {
        let ownPost = (currentUser?.id == post.authorId || (post.repostAuthor?.id != nil && currentUser?.id == post.repostAuthor?.id))

        let repostingEnabled = post.author?.hasRepostingEnabled ?? true
        var repostVisibility: InteractionVisibility = .enabled
        if post.reposted { repostVisibility = .disabled }
        else if !repostingEnabled { repostVisibility = .hidden }
        else if ownPost { repostVisibility = .disabled }

        let commentingEnabled = post.author?.hasCommentingEnabled ?? true
        let commentVisibility: InteractionVisibility = commentingEnabled ? .enabled : .hidden

        let sharingEnabled = post.author?.hasSharingEnabled ?? true
        let shareVisibility: InteractionVisibility = sharingEnabled ? .enabled : .hidden

        let lovingEnabled = post.author?.hasLovesEnabled ?? true
        var loveVisibility: InteractionVisibility = .enabled
        if post.loved { loveVisibility = .selectedAndEnabled }
        if !lovingEnabled { loveVisibility = .hidden }

        cell.updateToolbarItems(
            streamKind: streamKind,
            repostVisibility: repostVisibility,
            commentVisibility: commentVisibility,
            shareVisibility: shareVisibility,
            loveVisibility: loveVisibility
        )
    }

    fileprivate static func configureCommentControl(
        _ cell: StreamFooterCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind )
    {
        if streamKind.isDetail {
            cell.commentsOpened = true
            cell.commentsControl.isSelected = true
        }
        else {
            let isLoading = streamCellItem.state == .loading
            let isExpanded = streamCellItem.state == .expanded

            if isLoading {
                // this should be set via a custom accessor or method,
                // me thinks.
                // `StreamFooterCell.state = streamCellItem.state` ??
                cell.commentsControl.animate()
                cell.commentsControl.isSelected = true
            }
            else {
                cell.commentsControl.finishAnimation()

                if isExpanded {
                    cell.commentsControl.isSelected = true
                    cell.commentsOpened = true
                }
                else {
                    cell.commentsControl.isSelected = false
                    cell.commentsOpened = false
                    streamCellItem.state = .collapsed
                }
            }
        }
    }

    fileprivate static func configureDisplayCounts(
        _ cell: StreamFooterCell,
        post: Post,
        streamKind: StreamKind)
    {
        let rounding = streamKind.isGridView ? 0 : 2
        if cell.frame.width < 155 {
            cell.views = ""
            cell.reposts = ""
            cell.loves = ""
        }
        else {
            cell.views = post.viewsCount?.numberToHuman(rounding: rounding)
            cell.reposts = post.repostsCount?.numberToHuman(rounding: rounding)
            cell.loves = post.lovesCount?.numberToHuman(rounding: rounding)
        }
        cell.comments = post.commentsCount?.numberToHuman(rounding: rounding)
    }
}
