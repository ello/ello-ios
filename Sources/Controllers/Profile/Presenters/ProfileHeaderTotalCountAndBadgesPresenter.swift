////
///  ProfileHeaderTotalCountAndBadgesPresenter.swift
//

struct ProfileHeaderTotalCountAndBadgesPresenter {

    static func configure(
        _ cell: ProfileHeaderTotalCountAndBadgesCell,
        user: User,
        currentUser: User?
    ) {
        cell.update(count: user.formattedTotalCount ?? "", badges: user.badges)
    }
}
