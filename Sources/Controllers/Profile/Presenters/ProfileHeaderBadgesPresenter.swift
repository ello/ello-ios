////
///  ProfileHeaderBadgesPresenter.swift
//

struct ProfileHeaderBadgesPresenter {

    static func configure(
        _ cell: ProfileHeaderBadgesCell,
        user: User,
        currentUser: User?)
    {
        cell.badges = user.badges
    }
}
