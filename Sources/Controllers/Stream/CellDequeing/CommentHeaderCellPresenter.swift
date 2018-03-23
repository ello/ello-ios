////
///  CommentHeaderCellPresenter.swift
//

import TimeAgoInWords


struct CommentHeaderCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard let cell = cell as? CommentHeaderCell,
            let comment = streamCellItem.jsonable as? ElloComment
        else { return }

        var config = CommentHeaderCell.Config()
        config.author = comment.author
        config.timestamp = comment.createdAt.timeAgoInWords()

        let isLoggedIn = currentUser != nil
        let isPostAuthor = currentUser?.isAuthorOfOriginalPost(comment: comment) ?? false
        let isCommentAuthor = currentUser?.isAuthorOf(comment: comment) ?? false
        config.canEdit = isCommentAuthor
        config.canDelete = isCommentAuthor || isPostAuthor || AuthToken().isStaff
        config.canReplyAndFlag = isLoggedIn && !isCommentAuthor

        cell.config = config
    }
}
