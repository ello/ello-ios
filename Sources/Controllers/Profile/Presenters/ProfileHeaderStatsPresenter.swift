////
///  ProfileHeaderStatsPresenter.swift
//

struct ProfileHeaderStatsPresenter {

    static func configure(
        _ cell: ProfileHeaderStatsCell,
        user: User,
        currentUser: User?)
    {
        guard user.hasProfileData else {
            cell.postsCount = "…"
            cell.followingCount = "…"
            cell.followersCount = "…"
            cell.lovesCount = "…"
            return
        }

        cell.postsCount = (user.postsCount ?? 0).numberToHuman(rounding: 1, showZero: true)
        let followingCount = user.followingCount ?? 0
        cell.followingCount = followingCount.numberToHuman(rounding: 1, showZero: true)
        cell.followingEnabled = followingCount > 0
        if let string = user.followersCount,
            let followersCount = Int(string)
        {
            cell.followersCount = followersCount.numberToHuman(rounding: 1, showZero: true)
            cell.followersEnabled = followersCount > 0
        }
        else {
            cell.followersCount = user.followersCount ?? ""
            cell.followersEnabled = false
        }
        cell.lovesCount = (user.lovesCount ?? 0).numberToHuman(rounding: 1, showZero: true)
    }
}
