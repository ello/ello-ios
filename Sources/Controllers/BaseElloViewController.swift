////
///  BaseElloViewController.swift
//

@objc
protocol ControllerThatMightHaveTheCurrentUser {
    var currentUser: User? { get set }
}

class BaseElloViewController: UIViewController, ControllerThatMightHaveTheCurrentUser {

    var elloNavigationItem = UINavigationItem()

    override var title: String? {
        didSet {
            elloNavigationItem.title = title ?? ""
        }
    }

    var currentUser: User? {
        didSet { didSetCurrentUser() }
    }

    var appViewController: AppViewController? {
        return findViewController { vc in vc is AppViewController } as? AppViewController
    }

    var elloTabBarController: ElloTabBarController? {
        return findViewController { vc in vc is ElloTabBarController } as? ElloTabBarController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.fixNavBarItemPadding()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Tracker.shared.screenAppeared(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }

    func didSetCurrentUser() {}

    @IBAction
    func backTapped() {
        guard
            let navigationController = navigationController, navigationController.childViewControllers.count > 1 else { return }

        _ = navigationController.popViewController(animated: true)
    }

    func isRootViewController() -> Bool {
        if let viewControllers = navigationController?.viewControllers {
            return (viewControllers[0] ) == self
        }
        return false
    }
}

// MARK: Search
extension BaseElloViewController {
    func searchButtonTapped() {
        let search = SearchViewController()
        search.currentUser = currentUser
        self.navigationController?.pushViewController(search, animated: true)
    }
}
