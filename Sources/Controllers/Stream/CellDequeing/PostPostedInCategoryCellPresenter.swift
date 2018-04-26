////
///  PostPostedInCategoryCellPresenter.swift
//

struct PostPostedInCategoryCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard
            let cell = cell as? PostPostedInCategoryCell,
            let post = streamCellItem.jsonable as? Post,
            let category = post.category
        else { return }

        cell.category = category
    }
}
