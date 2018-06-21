////
///  RoleAdminPermissions.swift
//

class RoleAdminPermissions {
    static func userCanAdd(currentUser: User?, category: Category, role: CategoryUser.Role? = nil) -> Bool {
        guard let currentUser = currentUser else { return false }
        return currentUser.canModerateCategory(category) ||
            ((role == .featured || role == nil) && currentUser.canCurateCategory(category))
    }

    static func userCanEdit(currentUser: User?, categoryUser: CategoryUser) -> Bool {
        guard let currentUser = currentUser, let category = categoryUser.category else { return false }
        return currentUser.canModerateCategory(category)
    }

    static func userCanAssignAnyRole(currentUser: User?, category: Category) -> Bool {
        guard let currentUser = currentUser else { return false }
        return currentUser.canModerateCategory(category)
    }

    static func userCanDelete(currentUser: User?, categoryUser: CategoryUser) -> Bool {
        guard let currentUser = currentUser, let category = categoryUser.category else { return false }
        return currentUser.canModerateCategory(category) ||
            (categoryUser.role == .featured && currentUser.canCurateCategory(category))
    }
}
