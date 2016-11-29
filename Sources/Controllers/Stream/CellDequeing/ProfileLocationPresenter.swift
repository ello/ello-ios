////
///  ProfileLocationPresenter.swift
//

import Foundation


public struct ProfileLocationPresenter {

    public static func configure(
        view: ProfileLocationView,
        user: User,
        currentUser: User?)
    {
        guard let location = user.location else { return }
        view.location = location
    }
}
