////
///  FollowingGenerator.swift
//

import PromiseKit


final class FollowingGenerator: StreamGenerator {

    var currentUser: User?
    let streamKind: StreamKind = .following
    weak var destination: StreamDestination?

    private var before: String?
    private var localToken: String = ""
    private var loadingToken = LoadingToken()

    init(destination: StreamDestination) {
        self.destination = destination
    }

    func load(reload: Bool = false) {
        localToken = loadingToken.resetInitialPageLoadingToken()
        if !reload {
            setPlaceHolders()
        }
        loadInitialFollowing()
    }

    func loadNextPage() -> Promise<[Model]>? {
        guard let before = before else { return nil }
        return loadFollowing(before: before)
    }
}

extension FollowingGenerator {
    private func setPlaceHolders() {
        destination?.setPlaceholders(items: [
            StreamCellItem(type: .placeholder, placeholderType: .streamItems)
        ])
    }

    private func loadInitialFollowing() {
        loadFollowing()
            .done { posts in
                let items = self.parse(jsonables: posts)

                self.destination?.replacePlaceholder(type: .streamItems, items: items) {
                    self.destination?.isPagingEnabled = items.count > 0
                }
            }
            .catch { _ in
                self.destination?.primaryModelNotFound()
            }
    }

    private func loadFollowing(before: String? = nil) -> Promise<[Model]> {
        return API().followingPostStream(before: before)
            .execute()
            .map { pageConfig, posts in
                self.before = pageConfig.next
                self.destination?.setPagingConfig(responseConfig: ResponseConfig(pageConfig: pageConfig))
                return posts
            }
    }
}
