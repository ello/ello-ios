////
///  ProfileGenerator.swift
//

import PromiseKit


final class ProfileGenerator: StreamGenerator {

    var currentUser: User?
    var streamKind: StreamKind
    weak var destination: StreamDestination?

    private var user: User?
    private let userParam: String
    private var posts: [Post]?
    private var hasPosts: Bool?
    private var localToken: String = ""
    private var loadingToken = LoadingToken()
    private let queue = OperationQueue()
    private var pageConfig: PageConfig?

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

        let username = user?.username
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
        if let username = username {
            loadUserPosts(username: username, doneOperation, reload: reload)
        }
        else {
            loadUserPosts(doneOperation, reload: reload)
        }
    }

    func toggleGrid() {
        if let posts = posts, hasPosts == true {
            destination?.replacePlaceholder(type: .streamPosts, items: parse(jsonables: posts))
        }
        else if let user = user, hasPosts == false {
            let noItems = [StreamCellItem(jsonable: user, type: .noPosts)]
            destination?.replacePlaceholder(type: .streamPosts, items: noItems)
        }
    }

    func loadNextPage() -> Promise<[JSONAble]>? {
        guard
            let username = user?.username,
            let pageConfig = pageConfig,
            let next = pageConfig.next
        else { return nil }

        return API().userPosts(username: username, before: next)
            .then { newPageConfig, posts -> [JSONAble] in
                self.destination?.setPagingConfig(responseConfig: self.createFakeConfig(pageConfig: newPageConfig))
                self.pageConfig = newPageConfig
                return posts
            }
            .catch { error in
                let errorConfig = PageConfig(next: nil, isLastPage: true)
                self.destination?.setPagingConfig(responseConfig: self.createFakeConfig(pageConfig: errorConfig))
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
            StreamCellItem(type: .placeholder, placeholderType: .streamPosts)
        ])
    }

    func setInitialUser(_ doneOperation: AsyncOperation) {
        guard let user = user else { return }

        destination?.setPrimary(jsonable: user)
        destination?.replacePlaceholder(type: .profileHeader, items: headerItems())
        doneOperation.run()
    }

    func loadUser(_ doneOperation: AsyncOperation, reload: Bool) {
        guard !doneOperation.isFinished || reload else { return }

        // load the user with no posts
        UserService().loadUser(streamKind.endpoint)
            .then { user -> Void in
                guard self.loadingToken.isValidInitialPageLoadingToken(self.localToken) else { return }

                self.user = user
                self.destination?.setPrimary(jsonable: user)
                self.destination?.replacePlaceholder(type: .profileHeader, items: self.headerItems())
                doneOperation.run()
            }
            .catch { _ in
                self.destination?.primaryJSONAbleNotFound()
                self.queue.cancelAllOperations()
            }
    }

    func createFakeConfig(pageConfig: PageConfig) -> ResponseConfig {
        let fakeConfig = ResponseConfig()
        fakeConfig.nextQuery = URLComponents(string: ElloURI.baseURL)
        fakeConfig.totalPagesRemaining = pageConfig.isLastPage == true ? "0" : "1"
        return fakeConfig
    }

    func loadUserPosts(username: String, _ doneOperation: AsyncOperation, reload: Bool) {
        let displayPostsOperation = AsyncOperation()
        displayPostsOperation.addDependency(doneOperation)
        queue.addOperation(displayPostsOperation)

        API().userPosts(username: username)
            .then { pageConfig, posts -> Void in
                guard self.loadingToken.isValidInitialPageLoadingToken(self.localToken) else { return }

                self.destination?.setPagingConfig(responseConfig: self.createFakeConfig(pageConfig: pageConfig))

                self.pageConfig = pageConfig
                self.posts = posts
                let userPostItems = self.parse(jsonables: posts)
                displayPostsOperation.run {
                    inForeground {
                        if userPostItems.count == 0 {
                            self.hasPosts = false
                            let user: User = self.user ?? User.empty(id: self.userParam)
                            let noItems = [StreamCellItem(jsonable: user, type: .noPosts)]
                            self.destination?.replacePlaceholder(type: .streamPosts, items: noItems) {
                                self.destination?.isPagingEnabled = false
                            }
                            self.destination?.replacePlaceholder(type: .profileHeader, items: self.headerItems())
                        }
                        else {
                            let updateHeaderItems = self.hasPosts == false
                            self.hasPosts = true
                            if updateHeaderItems {
                                self.destination?.replacePlaceholder(type: .profileHeader, items: self.headerItems())
                            }
                            self.destination?.replacePlaceholder(type: .streamPosts, items: userPostItems) {
                                self.destination?.isPagingEnabled = true
                            }
                        }
                    }
                }
            }
            .catch { _ in
                self.destination?.primaryJSONAbleNotFound()
                self.queue.cancelAllOperations()
            }
    }

    func loadUserPosts(_ doneOperation: AsyncOperation, reload: Bool) {
        let displayPostsOperation = AsyncOperation()
        displayPostsOperation.addDependency(doneOperation)
        queue.addOperation(displayPostsOperation)

        UserService().loadUserPosts(userParam)
            .then { posts, responseConfig -> Void in
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
                            self.destination?.replacePlaceholder(type: .streamPosts, items: noItems) {
                                self.destination?.isPagingEnabled = false
                            }
                            self.destination?.replacePlaceholder(type: .profileHeader, items: self.headerItems())
                        }
                        else {
                            let updateHeaderItems = self.hasPosts == false
                            self.hasPosts = true
                            if updateHeaderItems {
                                self.destination?.replacePlaceholder(type: .profileHeader, items: self.headerItems())
                            }
                            self.destination?.replacePlaceholder(type: .streamPosts, items: userPostItems) {
                                self.destination?.isPagingEnabled = true
                            }
                        }
                    }
                }
            }
            .catch { _ in
                self.destination?.primaryJSONAbleNotFound()
                self.queue.cancelAllOperations()
            }
    }
}
