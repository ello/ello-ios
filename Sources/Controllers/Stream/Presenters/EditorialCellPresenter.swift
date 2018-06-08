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

        cell.config = EditorialCell.Config.fromEditorial(editorial)
        (cell as? EditorialJoinCell)?.onJoinChange = { editorial.join = $0 }
        (cell as? EditorialInviteCell)?.onInviteChange = { editorial.invite = $0 }
    }
}
