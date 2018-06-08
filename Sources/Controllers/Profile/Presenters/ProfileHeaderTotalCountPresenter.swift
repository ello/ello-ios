////
///  ProfileHeaderTotalCountPresenter.swift
//

struct ProfileHeaderTotalCountPresenter {

    static func configure(
        _ cell: ProfileHeaderTotalCountCell,
        user: User,
        currentUser: User?)
    {
        cell.count = user.formattedTotalCount
    }
}
