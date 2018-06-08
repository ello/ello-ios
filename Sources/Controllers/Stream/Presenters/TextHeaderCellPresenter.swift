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
            let cell = cell as? TextHeaderCell
        else { return }

        if let title = streamCellItem.type.data as? String {
            let header = NSAttributedString(label: title, style: .header)
            cell.header = header
        }
        else if let header = streamCellItem.type.data as? NSAttributedString {
            cell.header = header
        }
    }

}
