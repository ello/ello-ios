////
///  ConversationCellPresenter.swift
//

public struct ConversationCellPresenter {

    static func configure(
        cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath,
        currentUser: User?)
    {
        guard let
            cell = cell as? ConversationCell,
            conversation = streamCellItem.jsonable as? Conversation
        else { return }
        cell.title = conversation.name
    }
}
