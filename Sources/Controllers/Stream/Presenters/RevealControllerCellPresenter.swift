////
///  RevealControllerCellPresenter.swift
//

struct RevealControllerCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard
            let cell = cell as? RevealControllerCell,
            case let .revealController(label, _) = streamCellItem.type
        else { return }

        cell.text = label
    }
}
