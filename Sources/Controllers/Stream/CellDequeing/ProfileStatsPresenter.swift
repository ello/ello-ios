////
///  ProfileStatsPresenter.swift
//

import Foundation


struct ProfileStatsPresenter {

    static func configure(
        _ view: ProfileStatsView,
        user: User,
        currentUser: User?)
    {
        view.postsCount = (user.postsCount ?? 0).numberToHuman(rounding: 2, showZero: true)
        view.followingCount = (user.followingCount ?? 0).numberToHuman(rounding: 2, showZero: true)
        if
            let string = user.followersCount,
            let followersCount = Int(string)
        {
            view.followersCount = followersCount.numberToHuman(rounding: 2, showZero: true)
        }
        else {
            view.followersCount = user.followersCount ?? ""
        }
        view.lovesCount = (user.lovesCount ?? 0).numberToHuman(rounding: 2, showZero: true)
    }
}
