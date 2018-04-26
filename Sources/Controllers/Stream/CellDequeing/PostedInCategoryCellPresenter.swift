////
///  PostedInCategoryCellPresenter.swift
//

struct PostedInCategoryCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard
            let cell = cell as? PostedInCategoryCell,
            let post = streamCellItem.jsonable as? Post,
            let category = post.category
        else { return }

        cell.category = category
    }
}
