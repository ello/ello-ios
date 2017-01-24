////
///  ProfileBioPresenter.swift
//

import Foundation


struct ProfileBioPresenter {

    static func configure(
        _ view: ProfileBioView,
        user: User,
        currentUser: User?)
    {
        view.bio = user.formattedShortBio ?? ""
    }
}
