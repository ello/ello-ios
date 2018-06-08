////
///  StreamInviteFriendsCellPresenter.swift
//

struct StreamInviteFriendsCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        if let cell = cell as? StreamInviteFriendsCell,
            let person = streamCellItem.jsonable as? LocalPerson
        {
            cell.person = person
            cell.isOnboarding = streamCellItem.type == .onboardingInviteFriends
        }
    }
}
