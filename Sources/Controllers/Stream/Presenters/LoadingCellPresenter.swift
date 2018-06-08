////
///  LoadingCellPresenter.swift
//

struct LoadingCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard let cell = cell as? LoadingCell else { return }
        cell.startAnimating()
    }
}
