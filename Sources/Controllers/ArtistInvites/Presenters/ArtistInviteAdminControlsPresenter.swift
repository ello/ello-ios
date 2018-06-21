////
///  ArtistInviteAdminControlsPresenter.swift
//

struct ArtistInviteAdminControlsPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard
            let cell = cell as? ArtistInviteAdminControlsCell,
            let submission = streamCellItem.jsonable as? ArtistInviteSubmission
        else { return }

        cell.config = ArtistInviteAdminControlsCell.Config.from(submission: submission)
    }

}
