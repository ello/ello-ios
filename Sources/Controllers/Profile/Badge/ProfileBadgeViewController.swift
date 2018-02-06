////
///  ProfileBadgeViewController.swift
//

final class ProfileBadgeViewController: BaseElloViewController {

    let badge: Badge

    init(badge: Badge) {
        self.badge = badge
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var _mockScreen: ProfileBadgeScreenProtocol?
    var screen: ProfileBadgeScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return _mockScreen ?? self.view as! ProfileBadgeScreen }
    }

    override func loadView() {
        let screen = ProfileBadgeScreen(title: badge.name, caption: badge.caption)
        screen.delegate = self
        self.view = screen
    }
}

// MARK: UIViewControllerTransitioningDelegate
extension ProfileBadgeViewController: UIViewControllerTransitioningDelegate {

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        guard presented == self
            else { return .none }

        return DarkModalPresentationController(presentedViewController: presented, presentingViewController: presenting, backgroundColor: .dimmedModalBackground)
    }
}

extension ProfileBadgeViewController: ProfileBadgeScreenDelegate {

    func learnMoreTapped() {
        let badge = self.badge
        Tracker.shared.badgeLearnMore(badge.slug)
        self.dismiss(animated: true) {
            if let url = badge.url {
                postNotification(ExternalWebNotification, value: url.absoluteString)
            }
        }
    }

    func dismiss() {
        self.dismiss(animated: true, completion: .none)
    }
}
