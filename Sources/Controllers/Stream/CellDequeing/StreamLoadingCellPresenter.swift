////
///  StreamLoadingCellPresenter.swift
//

import Foundation

struct StreamLoadingCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        if let cell = cell as? StreamLoadingCell {
            cell.start()
        }
    }
}
