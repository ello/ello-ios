////
///  EditorialCellPresenter.swift
//

struct EditorialCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard
            let cell = cell as? EditorialCell,
            let editorial = streamCellItem.jsonable as? Editorial
        else { return }

        var config = EditorialCell.Config()
        cell.config = config
    }
}
