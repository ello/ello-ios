////
///  StreamToggleCellPresenter.swift
//

struct StreamToggleCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard
            let cell = cell as? StreamToggleCell,
            let post = streamCellItem.jsonable as? Post
        else { return }

        let message: String
        if streamCellItem.state == .collapsed {
            message = InterfaceString.NSFW.Show
        }
        else {
            message = InterfaceString.NSFW.Hide
        }
        cell.label.text = "\(post.contentWarning) \(message)"
    }
}
