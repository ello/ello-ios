////
///  DeepLinking.swift
//

struct DeepLinking {

    static func showDiscover(navVC: UINavigationController?, currentUser: User?) {
        if navVC?.visibleViewController is CategoryViewController { return }

        let vc = CategoryViewController(currentUser: currentUser)
        navVC?.pushViewController(vc, animated: true)
    }

    static func showSettings(navVC: UINavigationController?, currentUser: User?) {
        guard
            let currentUser = currentUser
        else { return }

        let settings = SettingsViewController(currentUser: currentUser)
        navVC?.pushViewController(settings, animated: true)
    }

    static func showCategory(navVC: UINavigationController?, currentUser: User?, slug: String) {
        guard !DeepLinking.alreadyOnCurrentCategory(navVC: navVC, slug: slug) else { return }

        if let categoryVC = navVC?.visibleViewController as? CategoryViewController {
            categoryVC.selectCategoryFor(slug: slug)
        }
        else {
            let vc = CategoryViewController(currentUser: currentUser, slug: slug)
            navVC?.pushViewController(vc, animated: true)
        }
    }

    static func showArtistInvites(navVC: UINavigationController?, currentUser: User?, slug: String? = nil) {
        if let slug = slug {
            guard let navVC = navVC, !DeepLinking.alreadyOnArtistInvites(navVC: navVC, slug: slug) else { return }

            let vc = ArtistInviteDetailController(slug: slug)
            vc.currentUser = currentUser
            ArtistInviteDetailController.open(vc, in: navVC)
        }
        else {
            let appVC = UIApplication.shared.keyWindow?.rootViewController as? AppViewController
            let tabBarVC = appVC?.visibleViewController as? ElloTabBarController
            tabBarVC?.selectedTab = .home

            let tabBarNavVC = tabBarVC?.selectedViewController as? ElloNavigationController
            let homeVC = tabBarNavVC?.viewControllers.first as? HomeViewController
            homeVC?.showArtistInvitesViewController()
            tabBarNavVC?.popToRootViewController(animated: false)

            navVC?.dismiss(animated: true)
        }
    }

    static func showProfile(navVC: UINavigationController?, currentUser: User?, username: String) {
        let param = "~\(username)"
        guard !DeepLinking.alreadyOnUserProfile(navVC: navVC, userParam: param) else { return }

        let vc = ProfileViewController(userParam: param, username: username)
        vc.currentUser = currentUser
        navVC?.pushViewController(vc, animated: true)
    }

    static func showPostDetail(navVC: UINavigationController?, currentUser: User?, token: String) {
        let param = "~\(token)"
        guard !DeepLinking.alreadyOnPostDetail(navVC: navVC, postParam: param) else { return }

        let vc = PostDetailViewController(postParam: param)
        vc.currentUser = currentUser
        navVC?.pushViewController(vc, animated: true)
    }

    static func showSearch(navVC: UINavigationController?, currentUser: User?, terms: String) {
        if let searchVC = navVC?.visibleViewController as? SearchViewController {
            searchVC.searchForPosts(terms)
        }
        else {
            let vc = SearchViewController()
            vc.currentUser = currentUser
            vc.searchForPosts(terms)
            navVC?.pushViewController(vc, animated: true)
        }
    }

    static func alreadyOnCurrentCategory(navVC: UINavigationController?, slug: String) -> Bool {
        if let categoryVC = navVC?.visibleViewController as? CategoryViewController,
            case let .category(visibleSlug) = categoryVC.categorySelection
        {
            return slug == visibleSlug
        }
        return false
    }

    static func alreadyOnArtistInvites(navVC: UINavigationController?, slug: String) -> Bool {
        let detailVC = navVC?.visibleViewController as? ArtistInviteDetailController
        return detailVC?.artistInvite?.slug == slug
    }

    static func alreadyOnUserProfile(navVC: UINavigationController?, userParam: String) -> Bool {
        if let profileVC = navVC?.visibleViewController as? ProfileViewController {
            return userParam == profileVC.userParam
        }
        return false
    }

    static func alreadyOnPostDetail(navVC: UINavigationController?, postParam: String) -> Bool {
        if let postDetailVC = navVC?.visibleViewController as? PostDetailViewController {
            return postParam == postDetailVC.postParam
        }
        return false
    }

}
