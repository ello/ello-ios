////
///  ConversationMemberSelectionCellPresenter.swift
//

public struct ConversationMemberSelectionCellPresenter {

    static func configure(
        cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath,
        currentUser: User?)
    {
        guard let
            cell = cell as? ConversationMemberSelectionCell,
            user = streamCellItem.jsonable as? User
        else { return }

        cell.setUser(user)
    }
}
