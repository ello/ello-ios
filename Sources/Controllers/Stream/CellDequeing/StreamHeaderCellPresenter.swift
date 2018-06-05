////
///  StreamHeaderCellPresenter.swift
//

import TimeAgoInWords


struct StreamHeaderCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard let cell = cell as? StreamHeaderCell,
            let post = streamCellItem.jsonable as? Post
        else { return}

        let isGridView = streamCellItem.isGridView(streamKind: streamKind)

        switch streamKind {
        case .postDetail:
            cell.showUsername = false
        default:
            cell.showUsername = true
        }

        var author = post.author
        var repostedBy: User? = nil

        cell.isGridView = isGridView
        cell.chevronHidden = true

        if let repostAuthor = post.repostAuthor {
            repostedBy = author
            author = repostAuthor
        }

        let isAuthor = currentUser?.isAuthorOf(post: post) ?? false
        let followButtonVisible = !isAuthor && streamKind.isDetail(post: post)

        var category: Category?
        if streamKind.showsCategory {
            category = post.category
        }

        let isSubmission: Bool
        if streamKind.showsSubmission,
            post.artistInviteId != nil
        {
            isSubmission = true
        }
        else {
            isSubmission = false
        }
        cell.setDetails(user: author, repostedBy: repostedBy, category: category, isSubmission: isSubmission)
        cell.followButtonVisible = followButtonVisible
        if isGridView {
            cell.timeStamp = ""
        }
        else {
            cell.timeStamp = post.createdAt.timeAgoInWords()
        }
        cell.layoutIfNeeded()
    }
}
