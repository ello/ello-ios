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

        if let postCategories = comment.parentPost?.categoryPosts,
            let authorRoles = comment.author?.categoryRoles
        {
            let categories = postCategories.compactMap { $0.category }

            let isModerator = authorRoles.any { categoryUser in
                guard categoryUser.role == .moderator else { return false }
                return categories.any({ $0.slug == categoryUser.category?.slug })
            }
            let isCurator = authorRoles.any { categoryUser in
                guard categoryUser.role == .curator else { return false }
                return categories.any({ $0.slug == categoryUser.category?.slug })
            }
            let isFeatured = authorRoles.any { categoryUser in
                guard categoryUser.role == .featured else { return false }
                return categories.any({ $0.slug == categoryUser.category?.slug })
            }

            if isModerator {
                config.role = .moderator
            }
            else if isCurator {
                config.role = .curator
            }
            else if isFeatured {
                config.role = .featured
            }
        }

        cell.config = config
    }
}
