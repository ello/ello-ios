////
///  PagePromotionalHeaderCellPresenter.swift
//

struct PagePromotionalHeaderCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard
            let cell = cell as? CategoryHeaderCell,
            let pagePromotional = streamCellItem.jsonable as? PagePromotional
        else { return }

        let config = CategoryHeaderCell.Config(pagePromotional: pagePromotional)
        cell.config = config
    }
}
