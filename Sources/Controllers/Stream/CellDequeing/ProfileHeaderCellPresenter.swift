////
///  ProfileHeaderCellPresenter.swift
//

import Foundation


struct ProfileHeaderCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard
            let cell = cell as? ProfileHeaderCell,
            let user = streamCellItem.jsonable as? User
        else { return }

        cell.onHeightMismatch = { calculatedCellHeights in
            streamCellItem.calculatedCellHeights = calculatedCellHeights
            postNotification(StreamNotification.UpdateCellHeightNotification, value: cell)
        }
        cell.calculatedCellHeights = streamCellItem.calculatedCellHeights

        ProfileNamesPresenter.configure(cell.namesView, user: user, currentUser: currentUser)
        ProfileAvatarPresenter.configure(cell.avatarView, user: user, currentUser: currentUser)
        ProfileStatsPresenter.configure(cell.statsView, user: user, currentUser: currentUser)
        ProfileTotalCountPresenter.configure(cell.totalCountView, user: user, currentUser: currentUser)
        ProfileBioPresenter.configure(cell.bioView, user: user, currentUser: currentUser)
        ProfileLocationPresenter.configure(cell.locationView, user: user, currentUser: currentUser)
        ProfileLinksPresenter.configure(cell.linksView, user: user, currentUser: currentUser)
    }
}
