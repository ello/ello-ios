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

    private var nextPageRequest: GraphQLRequest<(PageConfig, [Post])>?
    private var nextRequestGenerator: ((String) -> GraphQLRequest<(PageConfig, [Post])>)?

    func headerItems() -> [StreamCellItem] {
        guard let user = user else { return [] }

        let parser = StreamCellItemParser()
        var items = parser.userProfileItems(user)
        if hasPosts != false {
            items += [
                StreamCellItem(jsonable: user, type: .fullWidthSpacer(height: 5))
            ]
        }
        return items
    }

    init(currentUser: User?, userParam: String, user: User?, streamKind: StreamKind, destination: StreamDestination) {
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
        if let username = username {
            self.nextRequestGenerator = { next in return API().userPosts(username: username, before: next) }
        }

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
        if let username = username, APIKeys.shared.hasGraphQL {
            gqlLoadUserPosts(username: username, doneOperation, reload: reload)
        }
        else {
            loadUserPosts(doneOperation, reload: reload)
        }
    }

    func toggleGrid() {
        if let posts = posts, hasPosts == true {
            destination?.replacePlaceholder(type: .streamItems, items: parse(jsonables: posts))
        }
        else if let user = user, hasPosts == false {
            let noItems = [StreamCellItem(jsonable: user, type: .noPosts)]
            destination?.replacePlaceholder(type: .streamItems, items: noItems)
        }
    }

    func loadNextPage() -> Promise<[Model]>? {
        guard
            let nextPageRequest = nextPageRequest
        else { return nil }

        return nextPageRequest
            .execute()
            .map { (pageConfig, posts) -> [Model] in
                self.setNextPageConfig(pageConfig)
                return posts
            }
            .recover { error -> Promise<[Model]> in
                let errorConfig = PageConfig(next: nil, isLastPage: true)
                self.destination?.setPagingConfig(responseConfig: ResponseConfig(pageConfig: errorConfig))
                throw error
            }
    }

    private func setNextPageConfig(_ pageConfig: PageConfig) {
        self.destination?.setPagingConfig(responseConfig: ResponseConfig(pageConfig: pageConfig))
        if let next = pageConfig.next, let nextRequestGenerator = nextRequestGenerator {
            self.nextPageRequest = nextRequestGenerator(next)
        }
        else {
            self.nextPageRequest = nil
            self.nextRequestGenerator = nil
        }
    }
}

extension ProfileGenerator {

    private func setPlaceHolders() {
        let header = StreamCellItem(type: .profileHeaderGhost, placeholderType: .profileHeader)
        header.calculatedCellHeights.oneColumn = ProfileHeaderGhostCell.Size.height
        header.calculatedCellHeights.multiColumn = ProfileHeaderGhostCell.Size.height
        destination?.setPlaceholders(items: [
            header,
            StreamCellItem(type: .placeholder, placeholderType: .streamItems)
        ])
    }

    private func setInitialUser(_ doneOperation: AsyncOperation) {
        guard let user = user else { return }

        destination?.setPrimary(jsonable: user)
        destination?.replacePlaceholder(type: .profileHeader, items: headerItems())
        doneOperation.run()
    }

    private func loadUser(_ doneOperation: AsyncOperation, reload: Bool) {
        guard !doneOperation.isFinished || user?.hasProfileData == false || reload else { return }

        // load the user with no posts
        UserService().loadUser(streamKind.endpoint)
            .done { user in
                guard self.loadingToken.isValidInitialPageLoadingToken(self.localToken) else { return }

                self.user = user
                let username = user.username
                self.nextRequestGenerator = { next in return API().userPosts(username: username, before: next) }
                self.destination?.setPrimary(jsonable: user)
                self.destination?.replacePlaceholder(type: .profileHeader, items: self.headerItems())
                doneOperation.run()
            }
            .catch { _ in
                self.destination?.primaryModelNotFound()
                self.queue.cancelAllOperations()
            }
    }

    private func gqlLoadUserPosts(username: String, _ doneOperation: AsyncOperation, reload: Bool) {
        let displayPostsOperation = AsyncOperation()
        displayPostsOperation.addDependency(doneOperation)
        queue.addOperation(displayPostsOperation)

        API().userPosts(username: username)
            .execute()
            .done { pageConfig, posts in
                guard self.loadingToken.isValidInitialPageLoadingToken(self.localToken) else { return }

                self.setNextPageConfig(pageConfig)

                self.posts = posts
                let userPostItems = self.parse(jsonables: posts)
                displayPostsOperation.run {
                    inForeground {
                        if userPostItems.count == 0 {
                            self.hasPosts = false
                            let user: User = self.user ?? User.empty(id: self.userParam)
                            let noItems = [StreamCellItem(jsonable: user, type: .noPosts)]
                            self.destination?.replacePlaceholder(type: .streamItems, items: noItems) {
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
                            self.destination?.replacePlaceholder(type: .streamItems, items: userPostItems) {
                                self.destination?.isPagingEnabled = true
                            }
                        }
                    }
                }
            }
            .ignoreErrors()
    }

    private func loadUserPosts(_ doneOperation: AsyncOperation, reload: Bool) {
        let displayPostsOperation = AsyncOperation()
        displayPostsOperation.addDependency(doneOperation)
        queue.addOperation(displayPostsOperation)

        UserService().loadUserPosts(userParam)
            .done { posts, responseConfig in
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
                            self.destination?.replacePlaceholder(type: .streamItems, items: noItems) {
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
                            self.destination?.replacePlaceholder(type: .streamItems, items: userPostItems) {
                                self.destination?.isPagingEnabled = true
                            }
                        }
                    }
                }
            }
            .ignoreErrors()
    }
}
