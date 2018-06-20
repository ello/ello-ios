////
///  RoleAdminGenerator.swift
//

import PromiseKit


class RoleAdminGenerator {
    enum Error: Swift.Error {
        case missingArgs
    }

    func loadRoles(user: User) -> Promise<[CategoryUser]> {
        let (promise, seal) = Promise<[CategoryUser]>.pending()
        API().userDetail(token: .id(user.id))
            .execute()
            .done { user in
                seal.fulfill(user.categoryRoles ?? [])
            }
            .catch(seal.reject)

        return promise
    }

    func delete(categoryUser: CategoryUser) -> Guarantee<Void> {
        let (promise, fulfill) = Guarantee<Void>.pending()

        let endpoint: ElloAPI = .deleteCategoryUser(categoryUser.id)
        ElloProvider.shared.request(endpoint)
            .ensure {
                fulfill(Void())
            }
            .ignoreErrors()

        return promise
    }

    func add(categoryId: String, userId: String, role: CategoryUser.Role) -> Promise<CategoryUser> {
        let (promise, seal) = Promise<CategoryUser>.pending()

        let endpoint: ElloAPI = .createCategoryUser(
            categoryId: categoryId,
            userId: userId,
            role: role.rawValue
            )
        ElloProvider.shared.request(endpoint)
            .done { jsonable, config in
                seal.fulfill(jsonable as! CategoryUser)
            }
            .catch(seal.reject)

        return promise
    }

    func edit(categoryId: String, userId: String, role: CategoryUser.Role) -> Promise<CategoryUser> {
        let (promise, seal) = Promise<CategoryUser>.pending()
        let endpoint: ElloAPI = .editCategoryUser(
            categoryId: categoryId,
            userId: userId,
            role: role.rawValue
            )
        ElloProvider.shared.request(endpoint)
            .done { jsonable, config in
                seal.fulfill(jsonable as! CategoryUser)
            }
            .catch(seal.reject)

        return promise
    }
}
