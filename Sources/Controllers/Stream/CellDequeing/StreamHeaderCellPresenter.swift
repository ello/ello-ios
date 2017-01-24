////
///  StreamHeaderCellPresenter.swift
//

import Foundation
import TimeAgoInWords

struct StreamHeaderCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        if let cell = cell as? StreamHeaderCell,
            let authorable = streamCellItem.jsonable as? Authorable
        {
            let post = streamCellItem.jsonable as? Post

            cell.close()
            cell.ownPost = false
            cell.ownComment = false
            cell.isGridLayout = streamKind.isGridView

            switch streamKind {
            case .postDetail:
                cell.showUsername = false
            default:
                cell.showUsername = true
            }

            if let currentUser = currentUser,
                let comment = streamCellItem.jsonable as? ElloComment
            {
                if currentUser.isOwn(comment: comment) {
                    cell.ownComment = true
                }
                else if currentUser.isOwnParentPost(comment: comment) {
                    cell.ownPost = true
                }
            }

            var author = authorable.author
            var repostedBy: User? = nil
            var followButtonVisible = false
            if streamCellItem.type == .header {
                cell.avatarHeight = streamKind.avatarHeight
                cell.scrollView.isScrollEnabled = false
                cell.chevronHidden = true
                cell.goToPostView.isHidden = false

                if let repostAuthor = post?.repostAuthor {
                    repostedBy = author
                    author = repostAuthor
                }

                if streamKind.isDetail {
                    followButtonVisible = true
                }
                cell.canReply = false
            }
            else {
                cell.showUsername = true
                cell.avatarHeight = 30.0
                cell.scrollView.isScrollEnabled = true
                cell.chevronHidden = false
                cell.goToPostView.isHidden = true
                cell.canReply = true
            }

            if author?.id == currentUser?.id {
                followButtonVisible = false
            }

            var category: Category?
            if streamKind.showsCategory {
                category = post?.category
            }

            cell.setDetails(user: author, repostedBy: repostedBy, category: category)
            cell.followButtonVisible = followButtonVisible
            if streamKind.isGridView {
                cell.timeStamp = ""
            }
            else {
                cell.timeStamp = authorable.createdAt.timeAgoInWords()
            }
            cell.layoutIfNeeded()
        }
    }
}
