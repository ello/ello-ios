////
///  StreamCreateCommentCellPresenter.swift
//

struct StreamCreateCommentCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard
            let cell = cell as? StreamCreateCommentCell,
            let comment = streamCellItem.jsonable as? ElloComment,
            let post = comment.loadedFromPost,
            let user = comment.author
        else {
            return
        }

        let ownPost = currentUser?.id == post.authorId
        let ownRepost = (post.isRepost && (post.repostAuthor?.id =?= currentUser?.id))
        let replyAllVisibility: InteractionVisibility
        let watchVisibility: InteractionVisibility
        if ownPost {
            replyAllVisibility = .enabled
            watchVisibility = .hidden
        }
        else {
            replyAllVisibility = .hidden
            if ownRepost {
                watchVisibility = .hidden
            }
            else {
                watchVisibility = .enabled
            }
        }

        cell.avatarURL = user.avatarURL()
        cell.replyAllVisibility = replyAllVisibility
        cell.isWatching = post.isWatching
        cell.watchVisibility = watchVisibility
    }

}
