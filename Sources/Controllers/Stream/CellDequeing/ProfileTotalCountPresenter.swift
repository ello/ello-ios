////
///  ProfileTotalCountPresenter.swift
//

import Foundation


public struct ProfileTotalCountPresenter {

    public static func configure(
        view: ProfileTotalCountView,
        user: User,
        currentUser: User?)
    {
        view.count = user.formattedTotalCount
        view.badgeVisible = user.categories?.count > 0
    }
}
