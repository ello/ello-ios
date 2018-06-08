////
///  ProfileHeaderBioPresenter.swift
//

struct ProfileHeaderBioPresenter {

    static func configure(
        _ cell: ProfileHeaderBioCell,
        user: User,
        currentUser: User?)
    {
        cell.bio = user.formattedShortBio ?? ""
    }
}
