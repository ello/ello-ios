////
///  ProfileCategoriesViewController.swift
//

final class ProfileCategoriesViewController: BaseElloViewController {

    var presentingVC: UIViewController?
    var categories = [Category]()
    init(categories: [Category]) {
        super.init(nibName: nil, bundle: nil)
        self.categories = categories
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var _mockScreen: ProfileCategoriesProtocol?
    var screen: ProfileCategoriesProtocol {
        set(screen) { _mockScreen = screen }
        get { return _mockScreen ?? self.view as! ProfileCategoriesScreen }
    }

    override func loadView() {
        let screen = ProfileCategoriesScreen(categories: categories)
        screen.delegate = self
        self.view = screen
    }
}

// MARK: UIViewControllerTransitioningDelegate
extension ProfileCategoriesViewController: UIViewControllerTransitioningDelegate {

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        guard presented == self
            else { return .none }

        return DarkModalPresentationController(presentedViewController: presented, presentingViewController: presenting, backgroundColor: .dimmedModalBackground)
    }
}

extension ProfileCategoriesViewController: ProfileCategoriesDelegate {

    func learnMoreTapped() {
        guard let badge = Badge.lookup(slug: "featured") else { return }
        Tracker.shared.badgeLearnMore(badge.slug)

        self.dismiss(animated: true) {
            if let url = badge.url {
                postNotification(ExternalWebNotification, value: url.absoluteString)
            }
        }
    }

    func categoryTapped(_ category: Category) {
        Tracker.shared.categoryOpened(category.slug)
        let vc = CategoryViewController(slug: category.slug, name: category.name)
        vc.currentUser = currentUser

        let presentingVC = self.presentingVC
        self.dismiss(animated: true) {
            presentingVC?.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func dismiss() {
        self.dismiss(animated: true, completion: .none)
    }
}
