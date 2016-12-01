////
///  ProfileAvatarPresenter.swift
//

import Foundation


public struct ProfileAvatarPresenter {

    public static func configure(
        view: ProfileAvatarView,
        user: User,
        currentUser: User?)
    {
        let isCurrentUser = (user.id == currentUser?.id)
        if let cachedImage = TemporaryCache.load(.Avatar)
            where isCurrentUser
        {
            view.avatarImage = cachedImage
        }
        else if let url = user.avatarURL(viewsAdultContent: currentUser?.viewsAdultContent, animated: true) {
            view.avatarURL = url
        }

        view.badgeVisible = user.totalViewsCount == nil && user.categories?.count > 0
    }
}
