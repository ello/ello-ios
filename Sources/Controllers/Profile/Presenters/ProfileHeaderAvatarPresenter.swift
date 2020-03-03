////
///  ProfileHeaderAvatarPresenter.swift
//

struct ProfileHeaderAvatarPresenter {

    static func configure(
        _ cell: ProfileHeaderAvatarCell,
        user: User,
        currentUser: User?
    ) {
        let isCurrentUser = (user.id == currentUser?.id)
        if let cachedImage:UIImage = TemporaryCache.load(.avatar), isCurrentUser {
            cell.avatarImage = cachedImage
        }
        else if let url = user.avatarURL(
            viewsAdultContent: currentUser?.viewsAdultContent,
            animated: true
        ) {
            cell.avatarURL = url
        }
    }
}
