////
///  ArtistInviteCellPresenter.swift
//

struct ArtistInviteCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard
            let cell = cell as? ArtistInviteConfigurableCell,
            let artistInvite = streamCellItem.jsonable as? ArtistInvite
        else { return }

        let config = ArtistInviteBubbleCell.Config.fromArtistInvite(artistInvite)
        cell.config = config
    }

    static func configureGuide(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard
            let cell = cell as? ArtistInviteGuideCell,
            let guide = streamCellItem.type.data as? ArtistInvite.Guide
        else { return }

        cell.config = guide
    }
}
