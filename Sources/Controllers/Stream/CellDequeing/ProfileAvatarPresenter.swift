////
///  ProfileAvatarPresenter.swift
//

struct ProfileAvatarPresenter {

    static func configure(
        _ view: ProfileAvatarView,
        user: User,
        currentUser: User?)
    {
        let isCurrentUser = (user.id == currentUser?.id)
        if let cachedImage: UIImage = TemporaryCache.load(.avatar), isCurrentUser
        {
            view.avatarImage = cachedImage
        }
        else if let url = user.avatarURL(viewsAdultContent: currentUser?.viewsAdultContent, animated: true) {
            view.avatarURL = url
        }
    }
}
