////
///  UserAvatarsCellPresenter.swift
//

struct UserAvatarsCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard
            let cell = cell as? UserAvatarsCell,
            let model = streamCellItem.jsonable as? UserAvatarCellModel
        else { return }

        cell.imageView.image = model.icon.normalImage
        cell.userAvatarCellModel = model
        cell.loadingLabel.isHidden = model.hasUsers
    }
}
