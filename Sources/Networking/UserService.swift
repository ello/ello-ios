////
///  UserService.swift
//

import Moya
import SwiftyJSON
import PromiseKit


struct UserService {

    init(){}

    func join(
        email: String,
        username: String,
        password: String,
        invitationCode: String?) -> Promise<User>
    {
            return ElloProvider.shared.request(.join(email: email, username: username, password: password, invitationCode: invitationCode))
                .then { data, _ -> User in
                    guard let user = data as? User else {
                        throw NSError.uncastableJSONAble()
                    }
                    return user
                }
    }

    func requestPasswordReset(email: String) -> Promise<()> {
        return ElloProvider.shared.request(.requestPasswordReset(email: email))
            .asVoid()
    }

    func resetPassword(password: String, authToken: String) -> Promise<User> {
        return ElloProvider.shared.request(.resetPassword(password: password, authToken: authToken))
            .then { user, _ -> User in
                guard let user = user as? User else {
                    throw NSError.uncastableJSONAble()
                }
                return user
            }
    }

    func setUser(categories: [Category]) -> Promise<()> {
        let categoryIds = categories.map { $0.id }
        return ElloProvider.shared.request(.userCategories(categoryIds: categoryIds))
            .asVoid()
    }
}
