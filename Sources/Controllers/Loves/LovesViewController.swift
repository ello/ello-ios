////
///  LovesViewController.swift
//

class LovesViewController: GraphQLStreamViewController {
    convenience init(username: String) {
        self.init(
            streamKind: .userLoves(username: username),
            title: InterfaceString.Loves.Title,
            initialRequest: {
                return API().userLoves(username: username).execute().map { config, loves in
                    return (config, loves.compactMap { $0.post })
                }
            },
            nextPageRequest: { before in
                return API().userLoves(username: username, before: before).execute().map {
                    config,
                    loves in
                    return (config, loves.compactMap { $0.post })
                }
            }
        )
    }
}
