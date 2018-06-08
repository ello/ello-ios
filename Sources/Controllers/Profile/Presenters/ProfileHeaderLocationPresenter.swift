////
///  ProfileHeaderLocationPresenter.swift
//

struct ProfileHeaderLocationPresenter {

    static func configure(
        _ cell: ProfileHeaderLocationCell,
        user: User,
        currentUser: User?)
    {
        guard let location = user.location else { return }
        cell.location = location
    }
}
