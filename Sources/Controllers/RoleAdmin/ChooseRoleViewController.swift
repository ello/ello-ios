////
///  ChooseRoleViewController.swift
//

class ChooseRoleViewController: BaseElloViewController {
    weak var delegate: ChooseRoleControllerDelegate?

    private var _mockScreen: ChooseRoleScreenProtocol?
    var screen: ChooseRoleScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return fetchScreen(_mockScreen) }
    }

    let category: Category
    let selectedRole: CategoryUser.Role?

    init(category: Category, selectedRole: CategoryUser.Role?) {
        self.category = category
        self.selectedRole = selectedRole
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let screen = ChooseRoleScreen(selectedRole: selectedRole)
        screen.delegate = self
        screen.navigationBar.leftItems = [.back]
        screen.categoryName = category.name
        screen.categoryImageURL = category.tileURL
        screen.canModerate = RoleAdminPermissions.userCanAssignAnyRole(
            currentUser: currentUser,
            category: category
        )

        view = screen
    }

}

extension ChooseRoleViewController: ChooseRoleScreenDelegate {
    func moderatorChosen() {
        delegate?.chooseRoleControllerRoleChosen(.moderator)
    }

    func curatorChosen() {
        delegate?.chooseRoleControllerRoleChosen(.curator)
    }

    func featuredChosen() {
        delegate?.chooseRoleControllerRoleChosen(.featured)
    }
}
