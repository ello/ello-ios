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

        cell.editorialKind = editorial.kind
        let content = cell.editorialContentView!
        content.config = EditorialCellContent.Config.fromEditorial(editorial)
        (content as? EditorialJoinCell)?.onJoinChange = { editorial.join = $0 }
        (content as? EditorialInviteCell)?.onInviteChange = { editorial.invite = $0 }
    }
}
