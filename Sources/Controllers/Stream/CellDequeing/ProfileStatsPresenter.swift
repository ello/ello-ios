////
///  ProfileStatsPresenter.swift
//

struct ProfileStatsPresenter {

    static func configure(
        _ view: ProfileStatsView,
        user: User,
        currentUser: User?)
    {
        view.postsCount = (user.postsCount ?? 0).numberToHuman(rounding: 1, showZero: true)
        let followingCount = user.followingCount ?? 0
        view.followingCount = followingCount.numberToHuman(rounding: 1, showZero: true)
        view.followingEnabled = followingCount > 0
        if let string = user.followersCount,
            let followersCount = Int(string)
        {
            view.followersCount = followersCount.numberToHuman(rounding: 1, showZero: true)
            view.followersEnabled = followersCount > 0
        }
        else {
            view.followersCount = user.followersCount ?? ""
            view.followersEnabled = false
        }
        view.lovesCount = (user.lovesCount ?? 0).numberToHuman(rounding: 1, showZero: true)
    }
}
