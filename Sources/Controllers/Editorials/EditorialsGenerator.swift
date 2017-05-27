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
        var editorialItems: [StreamCellItem] = []
        let (afterAll, done) = afterN { [weak self] in
            guard let `self` = self else { return }

            self.destination?.replacePlaceholder(type: .editorials, items: editorialItems) {
                self.destination?.pagingEnabled = editorialItems.count > 0
            }
        }

        let receivedEditorials = afterAll()
        StreamService().loadStream(streamKind: streamKind)
            .thenFinally { [weak self] response in
                guard
                    let `self` = self,
                    case let .jsonables(jsonables, responseConfig) = response,
                    let editorials = jsonables as? [Editorial]
                else { return }

                self.destination?.setPagingConfig(responseConfig: responseConfig)
                editorialItems += self.parse(jsonables: editorials)

                let postStreamEditorials = editorials.filter { $0.kind == .postStream }
                self.loadPostStreamEditorials(postStreamEditorials, afterAll: afterAll)
                receivedEditorials()
            }
            .catch { [weak self] _ in
                guard let `self` = self else { return }
                self.destination?.primaryJSONAbleNotFound()
            }
        done()
    }

    private func loadPostStreamEditorials(_ postStreamEditorials: [Editorial], afterAll: AfterBlock) {
        for editorial in postStreamEditorials {
            guard
                editorial.kind == .postStream,
                let path = editorial.postStreamURL
            else { continue }

            let next = afterAll()
            ElloProvider.shared.elloRequest(
                .custom(url: path, mimics: { return .following }),
                success: { (data, responseConfig) in
                    guard let posts = data as? [Post] else { next() ; return }
                    editorial.posts = posts
                    next()
                },
                failure: { (error, statusCode) in
                    next()
                })
        }
    }
}
