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
        return Promise { fulfill, reject in
            ElloProvider.shared.elloRequest(ElloAPI.join(email: email, username: username, password: password, invitationCode: invitationCode),
                success: { data, _ in
                    if let user = data as? User {
                        fulfill(user)
                    }
                    else {
                        let error = NSError.uncastableJSONAble()
                        reject(error)
                    }
                },
                failure: { error, _ in
                    reject(error)
                }
            )
        }
    }

    func requestPasswordReset(email: String) -> Promise<()> {
        return Promise { fulfill, reject in
            ElloProvider.shared.elloRequest(ElloAPI.requestPasswordReset(email: email),
                success: { _ in
                    fulfill(())
                },
                failure: { error, _ in
                    reject(error)
                }
            )
        }
    }

    func resetPassword(password: String, authToken: String) -> Promise<User> {
        return Promise { fulfill, reject in
            ElloProvider.shared.elloRequest(ElloAPI.resetPassword(password: password, authToken: authToken),
                success: { user, _ in
                    if let user = user as? User {
                        fulfill(user)
                    }
                    else {
                        let error = NSError.uncastableJSONAble()
                        reject(error)
                    }
                },
                failure: { error, _ in
                    reject(error)
                }
            )
        }
    }

    func setUser(categories: [Category]) -> Promise<()> {
        return Promise { fulfill, reject in
            let categoryIds = categories.map { $0.id }
            ElloProvider.shared.elloRequest(ElloAPI.userCategories(categoryIds: categoryIds),
                success: { _ in
                    fulfill(())
                },
                failure: { error, _ in
                    reject(error)
                })
        }
    }
}
