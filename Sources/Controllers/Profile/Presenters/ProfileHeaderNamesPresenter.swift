////
///  ProfileHeaderNamesPresenter.swift
//

struct ProfileHeaderNamesPresenter {

    static func configure(
        _ cell: ProfileHeaderNamesCell,
        user: User,
        currentUser: User?
    ) {
        cell.name = user.name
        cell.username = user.atName
    }
}
