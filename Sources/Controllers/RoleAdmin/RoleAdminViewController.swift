////
///  RoleAdminViewController.swift
//

import PromiseKit


class RoleAdminViewController: BaseElloViewController {
    private var _mockScreen: RoleAdminScreenProtocol?
    var screen: RoleAdminScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return fetchScreen(_mockScreen) }
    }

    let user: User
    let generator = RoleAdminGenerator()
    var categoryUsers: [CategoryUser] {
        didSet { updateRoles() }
    }

    var currentAction: Action?
    var currentCategory: Category?

    enum Action {
        case add
        case edit(CategoryUser)
    }

    init(user: User) {
        self.user = user
        self.categoryUsers = user.categoryRoles ?? []
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let screen = RoleAdminScreen()
        screen.delegate = self
        screen.navigationBar.leftItems = [.back]

        view = screen
        updateRoles()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        ElloHUD.showLoadingHudInView(view)
        generator.loadRoles(user: user)
            .done { categoryUsers in
                self.categoryUsers = categoryUsers
            }
            .catch { _ in
                self.categoryUsers = self.user.categoryRoles ?? []
            }
            .finally {
                ElloHUD.hideLoadingHudInView(self.view)
            }
    }

    override func showNavBars(animated: Bool) {
    }

    override func hideNavBars(animated: Bool) {
    }

    private func updateRoles() {
        screen.updateRoles(
            categoryUsers.map { categoryUser in
                let currentUserCanEdit = RoleAdminPermissions.userCanEdit(
                    currentUser: currentUser,
                    categoryUser: categoryUser
                )
                let currentUserCanDelete = RoleAdminPermissions.userCanDelete(
                    currentUser: currentUser,
                    categoryUser: categoryUser
                )
                let roleInfo = RoleAdminScreen.RoleInfo(
                    categoryName: categoryUser.category?.name ?? "???",
                    imageURL: categoryUser.category?.tileURL,
                    role: categoryUser.role,
                    currentUserCanEdit: currentUserCanEdit,
                    currentUserCanDelete: currentUserCanDelete
                )
                return roleInfo
            }
        )
    }

    override func backButtonTapped() {
        ElloHUD.showLoadingHudInView(view)
        ProfileService().reloadProfile(currentUser: currentUser!)
            .done { _ in
                super.backButtonTapped()
            }
            .ensure {
                ElloHUD.hideLoadingHudInView(self.view)
            }
            .ignoreErrors()
    }
}

extension RoleAdminViewController: RoleAdminScreenDelegate {
    func addRoleTapped() {
        guard let currentUser = currentUser else { return }

        self.currentAction = .add

        let controller = ChooseCategoryViewController(
            currentUser: currentUser,
            category: nil,
            usage: .roleAdmin
        )
        controller.categoryFilter = { category in
            if self.categoryUsers.any({ $0.category?.id == category.id }) {
                return false
            }
            return RoleAdminPermissions.userCanAdd(currentUser: currentUser, category: category)
        }
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }

    func editRoleTapped(index: Int) {
        let categoryUser = categoryUsers[index]
        guard
            let category = categoryUser.category,
            RoleAdminPermissions.userCanEdit(currentUser: currentUser, categoryUser: categoryUser)
        else { return }

        self.currentCategory = category
        self.currentAction = .edit(categoryUser)

        let controller = ChooseRoleViewController(
            category: category,
            selectedRole: categoryUser.role
        )
        controller.currentUser = currentUser
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }

    func removeRoleTapped(index: Int) {
        let categoryUser = categoryUsers[index]
        guard
            let category = categoryUser.category,
            RoleAdminPermissions.userCanDelete(currentUser: currentUser, categoryUser: categoryUser)
        else { return }

        let alertController = AlertViewController()
        alertController.attributedMessage = NSAttributedString(
            label: "Remove \(user.atName) from ",
            style: .black
        ) + NSAttributedString(label: category.name, style: .blackUnderlined)
            + NSAttributedString(label: "?", style: .black)

        let yesAction = AlertAction(title: InterfaceString.Yes, style: .green) { _ in
            var removeCategoryUser: CategoryUser?
            let newCategoryUsers: [CategoryUser] = self.categoryUsers.enumerated().compactMap {
                existingIndex,
                categoryUser in
                if existingIndex == index {
                    removeCategoryUser = categoryUser
                    return nil
                }
                return categoryUser
            }

            if let removeCategoryUser = removeCategoryUser {
                ElloHUD.showLoadingHudInView(self.view)
                self.generator.delete(categoryUser: removeCategoryUser)
                    .done {
                        self.categoryUsers = newCategoryUsers
                        ElloHUD.hideLoadingHudInView(self.view)
                    }
                    .ignoreErrors()
            }
        }
        alertController.addAction(yesAction)

        let noAction = AlertAction(title: InterfaceString.Nevermind, style: .gray)
        alertController.addAction(noAction)

        self.present(alertController, animated: true, completion: nil)
    }
}

extension RoleAdminViewController: ChooseCategoryControllerDelegate {
    func chooseCategoryShouldGoBack() -> Bool {
        return false
    }

    func categoryChosen(_ category: Category) {
        guard let navigationController = navigationController else { return }

        self.currentCategory = category

        let roleController = ChooseRoleViewController(category: category, selectedRole: nil)
        roleController.currentUser = currentUser
        roleController.delegate = self

        let controllers: [UIViewController] = navigationController.viewControllers.map {
            controller in
            if controller is ChooseCategoryViewController {
                return roleController
            }
            return controller
        }
        navigationController.setViewControllers(controllers, animated: true)
    }
}

extension RoleAdminViewController: ChooseRoleControllerDelegate {
    func chooseRoleControllerRoleChosen(_ role: CategoryUser.Role) {
        navigationController?.popViewController(animated: true)
        guard let currentAction = currentAction, let currentCategory = currentCategory else {
            return
        }

        switch currentAction {
        case .add:
            guard
                RoleAdminPermissions.userCanAdd(
                    currentUser: currentUser,
                    category: currentCategory,
                    role: role
                )
            else { return }

            ElloHUD.showLoadingHudInView(view)
            generator.add(categoryId: currentCategory.id, userId: user.id, role: role)
                .done { newCategoryUser in
                    self.categoryUsers = [newCategoryUser] + self.categoryUsers
                }
                .catch { err in
                    let alert = AlertViewController(confirmation: "Could not save role")
                    self.present(alert, animated: true, completion: nil)
                }
                .finally {
                    ElloHUD.hideLoadingHudInView(self.view)
                }

        case let .edit(prevCategoryUser):
            if prevCategoryUser.role == role {
                return
            }
            guard
                RoleAdminPermissions.userCanEdit(
                    currentUser: currentUser,
                    categoryUser: prevCategoryUser
                )
            else { return }

            ElloHUD.showLoadingHudInView(view)
            generator.edit(categoryId: currentCategory.id, userId: user.id, role: role)
                .done { newCategoryUser in
                    self.categoryUsers = self.categoryUsers.map { categoryUser in
                        if categoryUser == prevCategoryUser {
                            return newCategoryUser
                        }
                        return categoryUser
                    }
                }
                .catch { _ in
                    let alert = AlertViewController(confirmation: "Could not save role")
                    self.present(alert, animated: true, completion: nil)
                }
                .finally {
                    ElloHUD.hideLoadingHudInView(self.view)
                }
        }

        updateRoles()
    }
}
