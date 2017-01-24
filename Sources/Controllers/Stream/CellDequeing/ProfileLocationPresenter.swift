////
///  ProfileLocationPresenter.swift
//

import Foundation


struct ProfileLocationPresenter {

    static func configure(
        _ view: ProfileLocationView,
        user: User,
        currentUser: User?)
    {
        guard let location = user.location else { return }
        view.location = location
    }
}
