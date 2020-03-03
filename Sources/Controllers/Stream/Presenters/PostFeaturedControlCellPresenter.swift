////
///  PostFeaturedControlCellPresenter.swift
//

struct PostFeaturedControlCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?
    ) {
        guard
            let cell = cell as? PostFeaturedControlCell,
            let categoryPost = streamCellItem.jsonable as? CategoryPost
        else { return }

        cell.isFeatured = categoryPost.hasAction(.unfeature)
        cell.isBusy = streamCellItem.state != .none
    }
}
