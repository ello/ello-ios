////
///  RoleAdminProtocols.swift
//

protocol RoleAdminScreenDelegate: class {
    func addRoleTapped()
    func editRoleTapped(index: Int)
    func removeRoleTapped(index: Int)
}

protocol RoleAdminScreenProtocol: class {
    var navigationBar: ElloNavigationBar { get }
    func updateRoles(_ roles: [RoleAdminScreen.RoleInfo])
}

protocol ChooseRoleScreenDelegate: class {
    func moderatorChosen()
    func curatorChosen()
    func featuredChosen()
}

protocol ChooseRoleScreenProtocol: class {
    var categoryImageURL: URL? { get set }
    var canModerate: Bool { get set }
}

protocol ChooseRoleControllerDelegate: class {
    func chooseRoleControllerRoleChosen(_ role: CategoryUser.Role)
}
