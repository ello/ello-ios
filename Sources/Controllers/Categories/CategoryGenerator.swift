////
///  CategoryGenerator.swift
//

protocol CategoryStreamDestination: StreamDestination {
    func set(categories: [Category])
}

final class CategoryGenerator: StreamGenerator {

    var currentUser: User?
    var streamKind: StreamKind
    weak fileprivate var categoryStreamDestination: CategoryStreamDestination?
    weak var destination: StreamDestination? {
        get { return categoryStreamDestination }
        set {
            if !(newValue is CategoryStreamDestination) { fatalError("CategoryGenerator.destination must conform to CategoryStreamDestination") }
            categoryStreamDestination = newValue as? CategoryStreamDestination
        }
    }

    fileprivate var category: Category?
    fileprivate var categories: [Category]?
    fileprivate var slug: String?
    fileprivate var pagePromotional: PagePromotional?
    fileprivate var posts: [Post]?
    fileprivate var localToken: String = ""
    fileprivate var loadingToken = LoadingToken()

    fileprivate let queue = OperationQueue()

    func headerItems() -> [StreamCellItem] {
        var items: [StreamCellItem] = []

        if usesPagePromo() {
            if let pagePromotional = pagePromotional {
                items += [StreamCellItem(jsonable: pagePromotional, type: .pagePromotionalHeader)]
            }
        }
        else if let category = self.category, category.hasPromotionalData {
            items += [StreamCellItem(jsonable: category, type: .categoryPromotionalHeader)]
        }

        return items
    }

    init(slug: String?,
        currentUser: User?,
        streamKind: StreamKind,
        destination: StreamDestination?
        )
    {
        self.slug = slug
        self.currentUser = currentUser
        self.streamKind = streamKind
        self.destination = destination
    }

    func reset(streamKind: StreamKind, category: Category?, pagePromotional: PagePromotional?) {
        self.streamKind = streamKind
        self.category = category
        self.slug = category?.slug
        self.pagePromotional = nil
    }

    func load(reload: Bool = false) {
        if reload {
            pagePromotional = nil
        }

        let doneOperation = AsyncOperation()
        queue.addOperation(doneOperation)

        localToken = loadingToken.resetInitialPageLoadingToken()
        if reload {
            category = nil
            categories = nil
            pagePromotional = nil
            posts = nil
        }
        else {
            setPlaceHolders()
        }
        setInitialJSONAble(doneOperation)

        loadCategories()
        if let slug = slug {
            loadCategory(doneOperation, slug: slug, reload: reload)
        }

        if usesPagePromo() {
            loadPagePromotional(doneOperation)
        }

        loadCategoryPosts(doneOperation, reload: reload)
    }

    func toggleGrid() {
        guard let posts = posts else { return }
        destination?.replacePlaceholder(type: .categoryPosts, items: parse(jsonables: posts)) {}
    }

}

private extension CategoryGenerator {

    func setPlaceHolders() {
        destination?.setPlaceholders(items: [
            StreamCellItem(type: .placeholder, placeholderType: .categoryHeader),
            StreamCellItem(type: .placeholder, placeholderType: .categoryPosts)
        ])
    }

    func setInitialJSONAble(_ doneOperation: AsyncOperation) {
        guard let category = category else { return }

        let jsonable: JSONAble?
        if usesPagePromo() {
            jsonable = pagePromotional
        }
        else {
            jsonable = category
        }

        if let jsonable = jsonable {
            destination?.setPrimary(jsonable: jsonable)
            destination?.replacePlaceholder(type: .categoryHeader, items: headerItems()) {}
            doneOperation.run()
        }
    }

    func usesPagePromo() -> Bool {
        let discoverType: DiscoverType? = slug.flatMap { DiscoverType.fromURL($0) }
        // discover types are featured/trending/recent, they always use a page promo
        guard discoverType == nil else {
            return true
        }

        guard let category = category else {
            return false
        }

        return category.usesPagePromo
    }

    func loadCategory(_ doneOperation: AsyncOperation, slug: String, reload: Bool = false) {
        guard
            !doneOperation.isFinished || reload,
            !usesPagePromo()
        else { return }

        CategoryService().loadCategory(slug)
            .onSuccess { [weak self] category in
                guard
                    let `self` = self,
                    self.loadingToken.isValidInitialPageLoadingToken(self.localToken)
                else { return }

                self.category = category
                self.destination?.setPrimary(jsonable: category)
                self.destination?.replacePlaceholder(type: .categoryHeader, items: self.headerItems()) {}
                doneOperation.run()
            }
            .onFail { [weak self] _ in
                guard let `self` = self else { return }
                self.destination?.primaryJSONAbleNotFound()
                self.queue.cancelAllOperations()
            }
    }

    func loadPagePromotional(_ doneOperation: AsyncOperation) {
        guard usesPagePromo() else { return }

        PagePromotionalService().loadPagePromotionals()
            .onSuccess { [weak self] promotionals in
                guard
                    let `self` = self,
                    self.loadingToken.isValidInitialPageLoadingToken(self.localToken)
                else { return }

                if let pagePromotional = promotionals?.randomItem() {
                    self.pagePromotional = pagePromotional
                    self.destination?.setPrimary(jsonable: pagePromotional)
                }
                else {
                    self.destination?.primaryJSONAbleNotFound()
                }
                self.destination?.replacePlaceholder(type: .categoryHeader, items: self.headerItems()) {}
                doneOperation.run()
            }
            .onFail { [weak self] _ in
                guard let `self` = self else { return }
                self.destination?.primaryJSONAbleNotFound()
                self.queue.cancelAllOperations()
        }
    }

    func loadCategories() {
        CategoryService().loadCategories()
            .onSuccess { [weak self] categories in
                guard let `self` = self else { return }
                self.categories = categories
                self.categoryStreamDestination?.set(categories: categories)
            }.ignoreFailures()
    }

    func loadCategoryPosts(_ doneOperation: AsyncOperation, reload: Bool) {
        let displayPostsOperation = AsyncOperation()
        displayPostsOperation.addDependency(doneOperation)
        queue.addOperation(displayPostsOperation)

        var apiEndpoint: ElloAPI?
        if usesPagePromo() {
            if let slug = slug,
                let discoverType = DiscoverType.fromURL(slug)
            {
                apiEndpoint = .discover(type: discoverType)
            }
            else {
                apiEndpoint = nil
            }
        }
        else if let slug = slug {
            apiEndpoint = .categoryPosts(slug: slug)
        }
        else {
            apiEndpoint = nil
        }

        guard let endpoint = apiEndpoint else { return }

        StreamService().loadStream(
            endpoint: endpoint,
            streamKind: streamKind
            )
            .onSuccess { [weak self] response in
                guard
                    let `self` = self,
                    self.loadingToken.isValidInitialPageLoadingToken(self.localToken)
                else { return }

                switch response {
                case let .jsonables(jsonables, responseConfig):
                    self.destination?.setPagingConfig(responseConfig: responseConfig)
                    self.posts = jsonables as? [Post]
                    let items = self.parse(jsonables: jsonables)
                    displayPostsOperation.run {
                        inForeground {
                            if items.count == 0 {
                                let noItems = [StreamCellItem(type: .emptyStream(height: 182))]
                                self.destination?.replacePlaceholder(type: .categoryPosts, items: noItems) {
                                    self.destination?.pagingEnabled = false
                                }
                                self.destination?.replacePlaceholder(type: .categoryHeader, items: self.headerItems()) {}
                            }
                            else {
                                self.destination?.replacePlaceholder(type: .categoryPosts, items: items) {
                                    self.destination?.pagingEnabled = true
                                }
                            }
                        }
                    }
                case .empty:
                    let noContentItem = StreamCellItem(type: .emptyStream(height: 282))
                    self.destination?.replacePlaceholder(type: .categoryPosts, items: [noContentItem]) {}
                    self.destination?.primaryJSONAbleNotFound()
                    self.queue.cancelAllOperations()
                }
            }
            .onFail { [weak self] _ in
                    guard let `self` = self else { return }
                    self.destination?.primaryJSONAbleNotFound()
                    self.queue.cancelAllOperations()
            }
    }
}
