////
///  TextHeaderCellPresenter.swift
//

struct TextHeaderCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard
            let cell = cell as? TextHeaderCell,
            let header = streamCellItem.type.data as? NSAttributedString
        else { return}

        cell.header = header
    }

}
