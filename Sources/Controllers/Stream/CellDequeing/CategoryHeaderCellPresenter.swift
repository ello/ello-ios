////
///  CategoryHeaderCellPresenter.swift
//

struct CategoryHeaderCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard
            let cell = cell as? CategoryHeaderCell,
            let category = streamCellItem.jsonable as? Category
        else { return }

        let config = CategoryHeaderCell.Config(category: category)
        cell.config = config
    }
}
