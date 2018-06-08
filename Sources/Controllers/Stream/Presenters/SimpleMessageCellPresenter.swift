////
///  SimpleMessageCellPresenter.swift
//

struct SimpleMessageCellPresenter {

    static func configureEmpty(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard let cell = cell as? SimpleMessageCell else { return }

        cell.title = InterfaceString.EmptyStreamText
    }

    static func configureError(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard
            let cell = cell as? SimpleMessageCell,
            case let .error(message) = streamCellItem.type
        else { return }

        cell.title = message
    }
}
