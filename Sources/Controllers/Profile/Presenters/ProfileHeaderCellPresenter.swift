////
///  ProfileHeaderCellPresenter.swift
//

struct ProfileHeaderCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?
    ) {
        guard
            let cell = cell as? ProfileHeaderCell,
            let user = streamCellItem.jsonable as? User
        else { return }

        cell.onHeightMismatch = { calculatedCellHeights in
            streamCellItem.calculatedCellHeights = calculatedCellHeights
            postNotification(StreamNotification.UpdateCellHeightNotification, value: streamCellItem)
        }

        if let cell = cell as? ProfileHeaderAvatarCell {
            ProfileHeaderAvatarPresenter.configure(cell, user: user, currentUser: currentUser)
        }
        else if let cell = cell as? ProfileHeaderNamesCell {
            ProfileHeaderNamesPresenter.configure(cell, user: user, currentUser: currentUser)
        }
        else if let cell = cell as? ProfileHeaderStatsCell {
            ProfileHeaderStatsPresenter.configure(cell, user: user, currentUser: currentUser)
        }
        else if let cell = cell as? ProfileHeaderTotalCountAndBadgesCell {
            ProfileHeaderTotalCountAndBadgesPresenter.configure(
                cell,
                user: user,
                currentUser: currentUser
            )
        }
        else if let cell = cell as? ProfileHeaderBioCell {
            ProfileHeaderBioPresenter.configure(cell, user: user, currentUser: currentUser)
        }
        else if let cell = cell as? ProfileHeaderLocationCell {
            ProfileHeaderLocationPresenter.configure(cell, user: user, currentUser: currentUser)
        }
        else if let cell = cell as? ProfileHeaderLinksCell {
            ProfileHeaderLinksPresenter.configure(cell, user: user, currentUser: currentUser)
        }
    }
}
