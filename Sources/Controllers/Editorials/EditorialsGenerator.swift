////
///  EditorialsGenerator.swift
//

final class EditorialsGenerator: StreamGenerator {

    var currentUser: User?
    let streamKind: StreamKind = .editorials
    weak var destination: StreamDestination?

    fileprivate var localToken: String = ""
    fileprivate var loadingToken = LoadingToken()

    init(currentUser: User?, destination: StreamDestination?) {
        self.currentUser = currentUser
        self.destination = destination
    }

    func load(reload: Bool = false) {
        localToken = loadingToken.resetInitialPageLoadingToken()
        if reload {
        }
        else {
            setPlaceHolders()
        }
        loadEditorials()
    }

}

private extension EditorialsGenerator {

    func setPlaceHolders() {
        destination?.setPlaceholders(items: [
            StreamCellItem(type: .placeholder, placeholderType: .editorials)
        ])
    }

    func loadEditorials() {
        StreamService().loadStream(streamKind: streamKind)
            .onSuccess { [weak self] response in
                guard
                    let `self` = self,
                    case let .jsonables(jsonables, responseConfig) = response,
                    let editorials = jsonables as? [Editorial]
                else { return }

                self.destination?.setPagingConfig(responseConfig: responseConfig)

                let postStreamEditorials = editorials.filter { $0.kind == .postStream }
                self.loadPostStreamEditorials(postStreamEditorials)

                let editorialItems = self.parse(jsonables: editorials)
                self.destination?.replacePlaceholder(type: .editorials, items: editorialItems) {
                    self.destination?.pagingEnabled = editorialItems.count > 0
                }

            }
            .onFail { [weak self] _ in
                guard let `self` = self else { return }
                self.destination?.primaryJSONAbleNotFound()
            }
    }

    func loadPostStreamEditorials(_ postStreamEditorials: [Editorial]) {
        for editorial in postStreamEditorials {
            guard
                editorial.kind == .postStream,
                let path = editorial.postStreamURL
            else { continue }

            let elloApi: ElloAPI = .custom(path: path, elloApi: { return .following })

            ElloProvider.shared.elloRequest(
                elloApi,
                success: { (data, responseConfig) in
                },
                failure: { (error, statusCode) in
                    promise.completeWithFail(error)
                })

        }
    }
}
