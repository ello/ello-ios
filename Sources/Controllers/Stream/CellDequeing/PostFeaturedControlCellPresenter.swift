////
///  PostFeaturedControlCellPresenter.swift
//

struct PostFeaturedControlCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard
            let cell = cell as? PostFeaturedControlCell,
            let post = streamCellItem.jsonable as? Post
        else { return }

        cell.isSelected = true
    }
}
