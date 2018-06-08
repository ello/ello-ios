////
///  UserListItemCellPresenter.swift
//

struct UserListItemCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        if let cell = cell as? UserListItemCell,
            let user = streamCellItem.jsonable as? User
        {
            cell.relationshipControl.isVisible = true

            if let currentUser = currentUser {
                cell.relationshipControl.isHidden = user.id == currentUser.id
            }

            cell.setUser(user)
        }
    }
}
