////
///  NoPostsCellPresenter.swift
//

struct NoPostsCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard
            let cell = cell as? NoPostsCell,
            let user = streamCellItem.jsonable as? User
        else { return }

        cell.isCurrentUser = currentUser?.id == user.id
    }
}
