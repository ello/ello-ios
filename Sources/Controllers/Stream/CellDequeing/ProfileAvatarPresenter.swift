////
///  ProfileAvatarPresenter.swift
//

import Foundation


struct ProfileAvatarPresenter {

    static func configure(
        _ view: ProfileAvatarView,
        user: User,
        currentUser: User?)
    {
        let isCurrentUser = (user.id == currentUser?.id)
        if let cachedImage = TemporaryCache.load(.avatar), isCurrentUser
        {
            view.avatarImage = cachedImage
        }
        else if let url = user.avatarURL(viewsAdultContent: currentUser?.viewsAdultContent, animated: true) {
            view.avatarURL = url
        }

        view.badgeVisible = user.totalViewsCount == nil && (user.categories?.count ?? 0) > 0
    }
}
