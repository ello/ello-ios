////
///  HireService.swift
//

import FutureKit


class HireService {

    init() {}

    func hire(user: User, body: String) -> Future<Void> {
        let promise = Promise<Void>()
        ElloProvider.shared.elloRequest(.hire(userId: user.id, body: body),
            success: { _ in
                promise.completeWithSuccess(Void())
            },
            failure: { error, _ in
                promise.completeWithFail(error)
            }
        )
        return promise.future
    }

    func collaborate(user: User, body: String) -> Future<Void> {
        let promise = Promise<Void>()
        ElloProvider.shared.elloRequest(.collaborate(userId: user.id, body: body),
            success: { _ in
                promise.completeWithSuccess(Void())
            },
            failure: { error, _ in
                promise.completeWithFail(error)
            }
        )
        return promise.future
    }

}
