////
///  HireService.swift
//

import PromiseKit


class HireService {

    func hire(user: User, body: String) -> Promise<()> {
        return ElloProvider.shared.request(.hire(userId: user.id, body: body))
            .asVoid()
    }

    func collaborate(user: User, body: String) -> Promise<()> {
        return ElloProvider.shared.request(.collaborate(userId: user.id, body: body))
            .asVoid()
    }

}
