////
///  PromotionalHeaderCellPresenter.swift
//

struct PromotionalHeaderCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?
    ) {
        guard
            let cell = cell as? PromotionalHeaderCell,
            let pageHeader = streamCellItem.jsonable as? PageHeader
        else { return }

        let config = PromotionalHeaderCell.Config(pageHeader: pageHeader)
        cell.config = config
    }
}
