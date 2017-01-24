////
///  SearchStreamCellPresenter.swift
//

struct SearchStreamCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard
            let cell = cell as? SearchStreamCell,
            let search = streamCellItem.jsonable as? SearchString,
            case let .search(placeholder) = streamCellItem.type
        else { return }

        cell.placeholder = placeholder
        cell.search = search.text
    }
}
