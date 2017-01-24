////
///  EmptyStreamCellPresenter.swift
//

struct EmptyStreamCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard let cell = cell as? EmptyStreamCell else { return }

        cell.title = InterfaceString.EmptyStreamText
    }
}
