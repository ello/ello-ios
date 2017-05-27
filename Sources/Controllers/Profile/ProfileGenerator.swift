////
///  ProfileGenerator.swift
//

final class ProfileGenerator: StreamGenerator {

    var currentUser: User?
    var streamKind: StreamKind
    weak var destination: StreamDestination?
    let postCreatedPlaceholder = StreamCellType.PlaceholderType.profilePosts

    fileprivate var user: User?
    fileprivate let userParam: String
    fileprivate var posts: [Post]?
    fileprivate var hasPosts: Bool?
    fileprivate var localToken: String = ""
    fileprivate var loadingToken = LoadingToken()
    fileprivate let queue = OperationQueue()

    func headerItems() -> [StreamCellItem] {
        guard let user = user else { return [] }

        var items = [
            StreamCellItem(jsonable: user, type: .profileHeader),
        ]
        if hasPosts != false {
            items += [
                StreamCellItem(jsonable: user, type: .fullWidthSpacer(height: 5))
            ]
        }
        return items
    }

    init(
        currentUser: User?,
        userParam: String,
        user: User?,
        streamKind: StreamKind,
        destination: StreamDestination?
        ) {
        self.currentUser = currentUser
        self.user = user
        self.userParam = userParam
        self.streamKind = streamKind
        self.destination = destination
    }

    func load(reload: Bool = false) {
        let doneOperation = AsyncOperation()
        queue.addOperation(doneOperation)

        localToken = loadingToken.resetInitialPageLoadingToken()
        if reload {
            user = nil
            posts = nil
        }
        else {
            setPlaceHolders()
        }
        setInitialUser(doneOperation)
        loadUser(doneOperation, reload: reload)
        loadUserPosts(doneOperation, reload: reload)
    }

    func toggleGrid() {
        if let posts = posts, hasPosts == true {
            destination?.replacePlaceholder(type: .profilePosts, items: parse(jsonables: posts)) {}
        }
        else if let user = user, hasPosts == false {
            let noItems = [StreamCellItem(jsonable: user, type: .noPosts)]
            destination?.replacePlaceholder(type: .profilePosts, items: noItems) {}
        }
    }

}

private extension ProfileGenerator {

    func setPlaceHolders() {
        let header = StreamCellItem(type: .profileHeaderGhost, placeholderType: .profileHeader)
        header.calculatedCellHeights.oneColumn = ProfileHeaderGhostCell.Size.height
        header.calculatedCellHeights.multiColumn = ProfileHeaderGhostCell.Size.height
        destination?.setPlaceholders(items: [
            header,
            StreamCellItem(type: .placeholder, placeholderType: .profilePosts)
        ])
    }

    func setInitialUser(_ doneOperation: AsyncOperation) {
        guard let user = user else { return }

        destination?.setPrimary(jsonable: user)
        destination?.replacePlaceholder(type: .profileHeader, items: headerItems()) {}
        doneOperation.run()
    }

    func loadUser(_ doneOperation: AsyncOperation, reload: Bool) {
        guard !doneOperation.isFinished || reload else { return }

        // load the user with no posts
        StreamService().loadUser(streamKind.endpoint)
            .thenFinally { [weak self] user in
                guard let `self` = self else { return }
                guard self.loadingToken.isValidInitialPageLoadingToken(self.localToken) else { return }

                self.user = user
                self.destination?.setPrimary(jsonable: user)
                self.destination?.replacePlaceholder(type: .profileHeader, items: self.headerItems()) {}
                doneOperation.run()
            }
            .catch { [weak self] _ in
                guard let `self` = self else { return }
                self.destination?.primaryJSONAbleNotFound()
                self.queue.cancelAllOperations()
            }
    }

    func loadUserPosts(_ doneOperation: AsyncOperation, reload: Bool) {
        let displayPostsOperation = AsyncOperation()
        displayPostsOperation.addDependency(doneOperation)
        queue.addOperation(displayPostsOperation)

        StreamService().loadUserPosts(userParam)
            .thenFinally { [weak self] (posts, responseConfig) in
                guard let `self` = self else { return }
                guard self.loadingToken.isValidInitialPageLoadingToken(self.localToken) else { return }

                self.destination?.setPagingConfig(responseConfig: responseConfig)
                self.posts = posts
                let userPostItems = self.parse(jsonables: posts)
                displayPostsOperation.run {
                    inForeground {
                        if userPostItems.count == 0 {
                            self.hasPosts = false
                            let user: User = self.user ?? User.empty(id: self.userParam)
                            let noItems = [StreamCellItem(jsonable: user, type: .noPosts)]
                            self.destination?.replacePlaceholder(type: .profilePosts, items: noItems) {
                                self.destination?.pagingEnabled = false
                            }
                            self.destination?.replacePlaceholder(type: .profileHeader, items: self.headerItems()) {}
                        }
                        else {
                            let updateHeaderItems = self.hasPosts == false
                            self.hasPosts = true
                            if updateHeaderItems {
                                self.destination?.replacePlaceholder(type: .profileHeader, items: self.headerItems()) {}
                            }
                            self.destination?.replacePlaceholder(type: .profilePosts, items: userPostItems) {
                                self.destination?.pagingEnabled = true
                            }
                        }
                    }
                }
            }
            .catch { [weak self] _ in
                guard let `self` = self else { return }
                self.destination?.primaryJSONAbleNotFound()
                self.queue.cancelAllOperations()
            }
    }
}
