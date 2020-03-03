////
///  StreamSelectionCellPresenter.swift
//

class StreamSelectionCellPresenter {
    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?
    ) {
        guard
            let cell = cell as? StreamSelectionCell,
            case let .category(_, filter) = streamKind
        else { return }

        cell.selectedFilter = filter
    }
}
