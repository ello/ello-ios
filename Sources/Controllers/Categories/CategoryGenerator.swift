////
///  CategoryGenerator.swift
//

import PromiseKit


protocol CategoryStreamDestination: StreamDestination {
    func set(subscribedCategories: [Category])
}

final class CategoryGenerator: StreamGenerator {
    var streamKind: StreamKind
    var currentUser: User?
    weak private var categoryStreamDestination: CategoryStreamDestination?
    var destination: StreamDestination? {
        get { return categoryStreamDestination }
        set {
            if !(newValue is CategoryStreamDestination) {
                fatalError(
                    "CategoryGenerator.destination must conform to CategoryStreamDestination"
                )
            }
            categoryStreamDestination = newValue as? CategoryStreamDestination
        }
    }

    private var subscribedCategories: [Category]?
    private var streamSelection: (Category.Selection, CategoryFilter)
    private var categorySelection: Category.Selection { return streamSelection.0 }
    private var filter: CategoryFilter { return streamSelection.1 }
    private var pageHeader: PageHeader?
    private var posts: [Post]?
    private var localToken: String = ""
    private var loadingToken = LoadingToken()
    private let queue = OperationQueue()

    private var nextPageRequest: GraphQLRequest<(PageConfig, [Post])>?
    private var nextRequestGenerator: ((String) -> GraphQLRequest<(PageConfig, [Post])>)?

    init(
        selection: Category.Selection,
        filter: CategoryFilter,
        currentUser: User?,
        destination: StreamDestination
    ) {
        self.streamKind = .category(selection, filter)
        self.streamSelection = (selection, filter)
        self.currentUser = currentUser
        self.destination = destination
    }

    func headerItems() -> [StreamCellItem] {
        guard let pageHeader = pageHeader else { return [] }

        var items: [StreamCellItem] = []
        if case .category = categorySelection {
            items.append(StreamCellItem(jsonable: pageHeader, type: .categoryHeader))
        }
        else {
            items.append(StreamCellItem(jsonable: pageHeader, type: .promotionalHeader))
        }

        if pageHeader.categoryId != nil, currentUser != nil {
            items.append(StreamCellItem(jsonable: pageHeader, type: .promotionalHeaderSubscription))
        }
        return items
    }

    func reset(
        selection _selection: Category.Selection? = nil,
        filter _filter: CategoryFilter? = nil
    ) {
        let selection = _selection ?? self.categorySelection
        let filter = _filter ?? self.filter
        self.streamSelection = (selection, filter)
        self.pageHeader = nil
        self.streamKind = .category(selection, filter)
    }

    func load(reloadPosts: Bool, reloadHeader: Bool, reloadCategories: Bool) {
        let doneOperation = AsyncOperation()
        queue.addOperation(doneOperation)

        localToken = loadingToken.resetInitialPageLoadingToken()

        let isInitialLoad = !reloadPosts && !reloadHeader && !reloadCategories
        if isInitialLoad {
            setPlaceHolders()
        }

        if reloadPosts {
            posts = nil
            self.destination?.replacePlaceholder(
                type: .streamItems,
                items: [StreamCellItem(type: .streamLoading)]
            )
        }

        if reloadHeader {
            self.destination?.replacePlaceholder(type: .pageHeader, items: [])
        }

        if isInitialLoad || reloadHeader {
            pageHeader = nil
            loadPageHeader(doneOperation)
        }
        else {
            doneOperation.run()
        }

        if isInitialLoad || reloadCategories {
            subscribedCategories = nil
            loadSubscribedCategories()
        }

        if isInitialLoad || reloadPosts {
            loadCategoryPosts(doneOperation, reload: reloadPosts)
        }
    }

    func toggleGrid() {
        guard let posts = posts else { return }
        destination?.replacePlaceholder(type: .streamItems, items: parse(jsonables: posts))
    }

    func loadNextPage() -> Promise<[Model]>? {
        guard
            let nextPageRequest = nextPageRequest
        else { return nil }

        return
            nextPageRequest
            .execute()
            .map { pageConfig, posts -> [Model] in
                self.setNextPageConfig(pageConfig)
                if posts.count == 0 {
                    self.destination?.isPagingEnabled = false
                }
                return posts
            }
            .recover { error -> Promise<[Model]> in
                let errorConfig = PageConfig(next: nil, isLastPage: true)
                self.destination?.setPagingConfig(
                    responseConfig: ResponseConfig(pageConfig: errorConfig)
                )
                self.destination?.isPagingEnabled = false
                throw error
            }
    }
}

extension CategoryGenerator {

    private func setPlaceHolders() {
        destination?.setPlaceholders(items: [
            StreamCellItem(type: .placeholder, placeholderType: .pageHeader),
            StreamCellItem(type: .placeholder, placeholderType: .streamItems)
        ])
    }

    private func loadPageHeader(_ doneOperation: AsyncOperation) {
        let kind: API.PageHeaderKind
        if case let .category(slug) = categorySelection {
            kind = .category(slug)
        }
        else {
            kind = .generic
        }

        API().pageHeaders(kind: kind)
            .execute()
            .done { pageHeaders in
                guard self.loadingToken.isValidInitialPageLoadingToken(self.localToken) else {
                    return
                }

                if let pageHeader = pageHeaders.randomItem() {
                    self.pageHeader = pageHeader
                    self.destination?.setPrimary(jsonable: pageHeader)
                }

                self.destination?.replacePlaceholder(type: .pageHeader, items: self.headerItems())
            }
            .catch { _ in
                self.destination?.primaryModelNotFound()
            }
            .finally {
                doneOperation.run()
            }
    }

    private func loadSubscribedCategories() {
        API().subscribedCategories()
            .execute()
            .done { subscribedCategories in
                self.subscribedCategories = subscribedCategories
                self.categoryStreamDestination?.set(subscribedCategories: subscribedCategories)
            }
            .ignoreErrors()
    }

    private func loadCategoryPosts(_ doneOperation: AsyncOperation, reload: Bool) {
        let request: GraphQLRequest<(PageConfig, [Post])>
        let filter = self.filter

        switch categorySelection {
        case .all:
            request = API().globalPostStream(filter: filter)
            nextRequestGenerator = { next in
                return API().globalPostStream(filter: filter, before: next)
            }
        case .subscribed:
            request = API().subscribedPostStream(filter: filter)
            nextRequestGenerator = { next in
                return API().subscribedPostStream(filter: filter, before: next)
            }
        case let .category(slug):
            request = API().categoryPostStream(categorySlug: slug, filter: filter)
            nextRequestGenerator = { next in
                return API().categoryPostStream(categorySlug: slug, filter: filter, before: next)
            }
        }

        let displayPostsOperation = AsyncOperation()
        displayPostsOperation.addDependency(doneOperation)
        queue.addOperation(displayPostsOperation)

        request.execute()
            .done { pageConfig, posts in
                guard self.loadingToken.isValidInitialPageLoadingToken(self.localToken) else {
                    return
                }

                self.setNextPageConfig(pageConfig)

                self.posts = posts
                var items = self.parse(jsonables: posts)
                let isPagingEnabled = items.count > 0
                let streamSelectionItem = StreamCellItem(type: .streamSelection)
                if items.count == 0 {
                    self.destination?.replacePlaceholder(
                        type: .streamItems,
                        items: [
                            streamSelectionItem, StreamCellItem(type: .emptyStream(height: 182))
                        ]
                    )
                    self.destination?.isPagingEnabled = isPagingEnabled
                    displayPostsOperation.run()
                }
                else {
                    displayPostsOperation.run {
                        inForeground {
                            if isPagingEnabled {
                                items.insert(streamSelectionItem, at: 0)
                            }

                            self.destination?.replacePlaceholder(type: .streamItems, items: items) {
                                self.destination?.isPagingEnabled = isPagingEnabled
                            }
                        }
                    }
                }
            }
            .catch { _ in
                self.destination?.replacePlaceholder(
                    type: .streamItems,
                    items: [StreamCellItem(type: .error(message: InterfaceString.GenericError))]
                )
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
