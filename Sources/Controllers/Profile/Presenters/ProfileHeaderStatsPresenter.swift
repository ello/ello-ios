////
///  ProfileHeaderStatsPresenter.swift
//

struct ProfileHeaderStatsPresenter {

    static func configure(
        _ cell: ProfileHeaderStatsCell,
        user: User,
        currentUser: User?
    ) {
        guard user.hasProfileData else {
            cell.postsCount = "…"
            cell.followingCount = "…"
            cell.followersCount = "…"
            cell.lovesCount = "…"
            return
        }

        cell.postsCount = (user.postsCount ?? 0).numberToHuman(rounding: 1, showZero: true)

        if user.username == "ello" {
            cell.followingCount = "∞"
            cell.followersCount = "∞"
            cell.lovesCount = "∞"
            cell.followersEnabled = false
            cell.followingEnabled = false
        }
        else {
            let followingCount = user.followingCount ?? 0
            let lovesCount = user.lovesCount ?? 0
            let followersCount = user.followersCount ?? 0

            cell.followingCount = followingCount.numberToHuman(rounding: 1, showZero: true)
            cell.followingEnabled = followingCount > 0
            cell.lovesCount = lovesCount.numberToHuman(rounding: 1, showZero: true)
            cell.lovesEnabled = lovesCount > 0
            cell.followersCount = followersCount.numberToHuman(rounding: 1, showZero: true)
            cell.followersEnabled = followersCount > 0
        }
    }
}
