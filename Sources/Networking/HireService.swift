////
///  HireService.swift
//

import PromiseKit


class HireService {

    init() {}

    func hire(user: User, body: String) -> Promise<Void> {
        return Promise { fulfill, reject in
            ElloProvider.shared.elloRequest(.hire(userId: user.id, body: body),
                success: { _ in
                    fulfill(Void())
                },
                failure: { error, _ in
                    reject(error)
                }
            )
        }
    }

    func collaborate(user: User, body: String) -> Promise<Void> {
        return Promise { fulfill, reject in
            ElloProvider.shared.elloRequest(.collaborate(userId: user.id, body: body),
                success: { _ in
                    fulfill(Void())
                },
                failure: { error, _ in
                    reject(error)
                }
            )
        }
    }

}
