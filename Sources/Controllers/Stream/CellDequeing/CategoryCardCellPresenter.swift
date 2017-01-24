////
///  CategoryCardCellPresenter.swift
//

struct CategoryCardCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard
            let cell = cell as? CategoryCardCell,
            let category = streamCellItem.jsonable as? Category
        else { return }

        let desiredHeight: CGFloat = ceil(cell.frame.width / 1.5)
        if streamCellItem.calculatedCellHeights.oneColumn != desiredHeight || streamCellItem.calculatedCellHeights.multiColumn != desiredHeight {
            streamCellItem.calculatedCellHeights.oneColumn = desiredHeight
            streamCellItem.calculatedCellHeights.multiColumn = desiredHeight
            postNotification(StreamNotification.UpdateCellHeightNotification, value: cell)
        }

        cell.title = category.name
        cell.imageURL = category.tileURL
        cell.selectable = streamCellItem.type == .selectableCategoryCard
    }

}
