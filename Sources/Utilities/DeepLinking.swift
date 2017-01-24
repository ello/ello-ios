////
///  DeepLinking.swift
//

struct DeepLinking {

    static func showDiscover(navVC: UINavigationController?, currentUser: User?) {
        if navVC?.topViewController is DiscoverAllCategoriesViewController { return }

        let vc = DiscoverAllCategoriesViewController()
        vc.currentUser = currentUser
        navVC?.pushViewController(vc, animated: true)
    }

    static func showSettings(navVC: UINavigationController?, currentUser: User?) {
        guard
            let settings = UIStoryboard(name: "Settings", bundle: .none).instantiateInitialViewController()
                as? SettingsContainerViewController
        else { return }

        settings.currentUser = currentUser
        navVC?.pushViewController(settings, animated: true)
    }

    static func showCategory(navVC: UINavigationController?, currentUser: User?, slug: String) {
        guard !DeepLinking.alreadyOnCurrentCategory(navVC: navVC, slug: slug) else { return }

        if let categoryVC = navVC?.topViewController as? CategoryViewController {
            categoryVC.selectCategoryFor(slug: slug)
        }
        else {
            let vc = CategoryViewController(slug: slug)
            vc.currentUser = currentUser
            navVC?.pushViewController(vc, animated: true)
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
        if let categoryVC = navVC?.visibleViewController as? CategoryViewController {
            return slug == categoryVC.slug
        }
        return false
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
