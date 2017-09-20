////
///  ElloWebBrowserViewController.swift
//

import KINWebBrowser


class BottomBarNavController: ElloNavigationController, BottomBarController {
    var bottomBarView = UIView()
    var navigationBarsVisible: Bool? = true
    let bottomBarVisible: Bool = true
    var bottomBarHeight: CGFloat { return 0 }

    func setNavigationBarsVisible(_ visible: Bool, animated: Bool) {
        navigationBarsVisible = visible
    }
}

class ElloWebBrowserViewController: KINWebBrowserViewController {
    var toolbarHidden = false
    var prevRequestURL: URL?
    static var currentUser: User?
    static var elloTabBarController: ElloTabBarController?

    class func navigationControllerWithBrowser(_ webBrowser: ElloWebBrowserViewController) -> ElloNavigationController {
        // tell AppDelegate to allow rotation
        AppDelegate.restrictRotation = false
        let xButton = UIBarButtonItem.closeButton(target: webBrowser, action: #selector(ElloWebBrowserViewController.doneButtonPressed(_:)))
        let shareButton = UIBarButtonItem(image: InterfaceImage.share.normalImage, style: UIBarButtonItemStyle.plain, target: webBrowser, action: #selector(ElloWebBrowserViewController.shareButtonPressed(_:)))

        webBrowser.navigationItem.leftBarButtonItem = xButton
        webBrowser.navigationItem.rightBarButtonItem = shareButton
        webBrowser.actionButtonHidden = true
        return BottomBarNavController(rootViewController: webBrowser)
    }

    override class func navigationControllerWithWebBrowser() -> ElloNavigationController {
        let browser = self.init()
        return navigationControllerWithBrowser(browser)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppDelegate.restrictRotation = false
        self.navigationController?.setToolbarHidden(toolbarHidden, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate = self
    }

    func shareButtonPressed(_ barButtonItem: UIBarButtonItem) {
        var webViewUrl: URL?
        if let wkWebView = wkWebView {
            webViewUrl = wkWebView.url
        }
        else if let uiWebView = uiWebView {
            webViewUrl = uiWebView.request?.url
        }

        guard let urlForActivityItem = webViewUrl
        else { return }

        let activityVC = UIActivityViewController(activityItems: [urlForActivityItem], applicationActivities: [SafariActivity()])
        if UI_USER_INTERFACE_IDIOM() == .phone {
            activityVC.modalPresentationStyle = .fullScreen
            present(activityVC, animated: true) { }
        }
        else {
            activityVC.modalPresentationStyle = .popover
            activityVC.popoverPresentationController?.barButtonItem = barButtonItem
            present(activityVC, animated: true) { }
        }
    }

}

// MARK: ElloWebBrowserViewConteroller: KINWebBrowserDelegate
extension ElloWebBrowserViewController: KINWebBrowserDelegate {

    func webBrowser(_ webBrowser: KINWebBrowserViewController!, didFailToLoad url: URL?, error: Error!) {
        if let url = url ?? prevRequestURL {
            UIApplication.shared.openURL(url)
        }
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    func webBrowser(_ webBrowser: KINWebBrowserViewController!, shouldStartLoadWith request: URLRequest!) -> Bool {
        prevRequestURL = request.url
        return ElloWebViewHelper.handle(request: request, origin: self, fromWebView: true)
    }

    func willDismissWebBrowser(_ webView: KINWebBrowserViewController) {
        AppDelegate.restrictRotation = true
    }

}

// MARK: ElloWebBrowserViewController: WebLinkResponder
extension ElloWebBrowserViewController: WebLinkResponder {

    func webLinkTapped(path: String, type: ElloURIWrapper, data: String) {
        switch type.uri {
        case .confirm,
             .email,
             .external,
             .forgotMyPassword,
             .freedomOfSpeech,
             .faceMaker,
             .invitations,
             .invite,
             .join,
             .signup,
             .login,
             .manifesto,
             .nativeRedirect,
             .onboarding,
             .passwordResetError,
             .profileFollowers,
             .profileFollowing,
             .profileLoves,
             .randomSearch,
             .requestInvite,
             .requestInvitation,
             .requestInvitations,
             .resetMyPassword,
             .resetPasswordError,
             .searchPeople,
             .searchPosts,
             .subdomain,
             .unblock,
             .whoMadeThis,
             .wtf:
            break // this is handled in ElloWebViewHelper/KINWebBrowserViewController
        case .discover:
            DeepLinking.showDiscover(navVC: navigationController, currentUser: ElloWebBrowserViewController.currentUser)
        case .category,
             .discoverRandom,
             .discoverRecent,
             .discoverRelated,
             .discoverTrending,
             .exploreRecommended,
             .exploreRecent,
             .exploreTrending:
            DeepLinking.showCategory(navVC: navigationController, currentUser: ElloWebBrowserViewController.currentUser, slug: data)
        case .artistInvitesBrowse:
            DeepLinking.showArtistInvites(navVC: navigationController, currentUser: ElloWebBrowserViewController.currentUser)
        case .artistInvitesDetail, .pushNotificationArtistInvite:
            DeepLinking.showArtistInvites(navVC: navigationController, currentUser: ElloWebBrowserViewController.currentUser, slug: data)
        case .betaPublicProfiles,
             .enter,
             .exit,
             .root,
             .explore:
            self.navigationController?.dismiss(animated: true, completion: nil)
        case .friends,
             .following,
             .noise,
             .starred:
            self.selectTab(.home)
        case .notifications: self.selectTab(.notifications)
        case .post,
             .pushNotificationPost,
             .pushNotificationComment:
            DeepLinking.showPostDetail(navVC: navigationController, currentUser: ElloWebBrowserViewController.currentUser, token: data)
        case .profile,
             .pushNotificationUser:
            DeepLinking.showProfile(navVC: navigationController, currentUser: ElloWebBrowserViewController.currentUser, username: data)
        case .search: DeepLinking.showSearch(navVC: navigationController, currentUser: ElloWebBrowserViewController.currentUser, terms: data)
        case .settings: DeepLinking.showSettings(navVC: navigationController, currentUser: ElloWebBrowserViewController.currentUser)
        }
    }

    fileprivate func selectTab(_ tab: ElloTab) {
        navigationController?.dismiss(animated: true) {
            ElloWebBrowserViewController.elloTabBarController?.selectedTab = tab
        }
    }

}
