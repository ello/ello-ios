////
///  ProfileHeaderLinksPresenter.swift
//

struct ProfileHeaderLinksPresenter {

    static func configure(
        _ cell: ProfileHeaderLinksCell,
        user: User,
        currentUser: User?
    ) {
        guard let links = user.externalLinksList else { return }
        cell.externalLinks = links
    }
}
