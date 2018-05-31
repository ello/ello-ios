////
///  CategoryViewController.swift
//

import PromiseKit


final class CategoryViewController: StreamableViewController {
    override func trackerName() -> String? { return "Discover" }
    override func trackerProps() -> [String: Any]? {
        guard
            case let .category(slug) = categorySelection
        else { return nil }
        return ["category": slug]
    }
    override func trackerStreamInfo() -> (String, String?)? {
        if let streamId = category?.id {
            return ("category", streamId)
        }
        return nil
    }

    private var _mockScreen: CategoryScreenProtocol?
    var screen: CategoryScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return fetchScreen(_mockScreen) }
    }

    var category: Category?
    var categorySelection: Category.Selection = .all
    var filter: CategoryFilter = .featured
    private var prevSelection: Category.Selection?
    var subscribedCategories: [Category]?
    var pageHeader: PageHeader?
    var generator: CategoryGenerator!
    var userDidScroll: Bool = false
    var hasSubscribedCategory: Bool {
        return currentUser?.hasSubscribedCategory == true
    }
    let usage: Usage

    enum Usage {
        case `default`
        case largeNav
        case detail
    }

    var showBackButton: Bool {
        if parent is HomeViewController {
            return false
        }
        return !isRootViewController()
    }

    convenience init(currentUser: User?, category: Category, usage: Usage = .default) {
        self.init(currentUser: currentUser, slug: category.slug, name: category.name, usage: usage)
        self.category = category
    }

    init(currentUser: User?, slug: String? = nil, name: String? = nil, usage: Usage = .default) {
        self.usage = usage
        if let slug = slug {
            self.categorySelection = .category(slug)
        }
        else if let currentUser = currentUser, currentUser.hasSubscribedCategory {
            self.categorySelection = .subscribed
        }
        else {
            self.categorySelection = .all
        }
        super.init(nibName: nil, bundle: nil)
        self.title = name

        self.generator = CategoryGenerator(
            selection: categorySelection,
            filter: filter,
            currentUser: currentUser,
            destination: self
        )
        self.currentUser = currentUser
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didSetCurrentUser() {
        super.didSetCurrentUser()
        generator.currentUser = currentUser

        if isViewLoaded {
            screen.showEditButton = currentUser != nil && usage != .detail

            if let subscribedCategories = subscribedCategories,
                let currentUser = currentUser,
                Set(subscribedCategories.map { $0.id }) != currentUser.followedCategoryIds
            {
                reloadCurrentCategory()
            }
        }
    }

    override func loadView() {
        let screen = CategoryScreen(usage: usage)
        screen.delegate = self
        screen.showEditButton = currentUser != nil && usage != .detail
        screen.isGridView = generator.streamKind.isGridView

        view = screen
        viewContainer = screen.streamContainer
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        screen.navigationBar.hasBackButton = showBackButton
        screen.setupNavBar(back: showBackButton, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        ElloHUD.showLoadingHudInView(streamViewController.view)

        streamViewController.streamKind = generator.streamKind
        streamViewController.initialLoadClosure = {}
        streamViewController.reloadClosure = { [unowned self] in self.reloadCurrentCategory() }
        streamViewController.toggleClosure = { [unowned self] isGridView in self.toggleGrid(isGridView) }

        self.initialLoadCategory()
    }

    private func updateInsets() {
        updateInsets(navBar: screen.topInsetView)

        if !userDidScroll {
            streamViewController.scrollToTop(animated: true)
        }
    }

    override func showNavBars(animated: Bool) {
        super.showNavBars(animated: animated)
        positionNavBar(screen.navigationBar, visible: true, withConstraint: screen.navigationBarTopConstraint, animated: animated)
        screen.toggleCategoriesList(navBarVisible: true, animated: animated)
        updateInsets()
    }

    override func hideNavBars(animated: Bool) {
        super.hideNavBars(animated: animated)
        positionNavBar(screen.navigationBar, visible: false, withConstraint: screen.navigationBarTopConstraint, animated: animated)
        screen.toggleCategoriesList(navBarVisible: false, animated: animated)
        updateInsets()
    }

    func toggleGrid(_ isGridView: Bool) {
        generator.toggleGrid()
    }

    override func streamViewWillBeginDragging(scrollView: UIScrollView) {
        super.streamViewWillBeginDragging(scrollView: scrollView)
        userDidScroll = true
    }

    override func streamViewInfiniteScroll() -> Promise<[Model]>? {
        return generator.loadNextPage()
    }
}

private extension CategoryViewController {

    func initialLoadCategory() {
        generator.load(reloadPosts: false, reloadHeader: false, reloadCategories: false)
        streamViewController.isPullToRefreshEnabled = false
    }

    func loadCategory() {
        if let categoryName = category?.name {
            title = categoryName
        }
        else {
            title = InterfaceString.Discover.Title
        }

        pageHeader = nil
        generator.load(reloadPosts: true, reloadHeader: true, reloadCategories: false)
        streamViewController.isPullToRefreshEnabled = false
    }

    func loadStream(_ filter: CategoryFilter) {
        generator.reset(filter: filter)
        streamViewController.streamKind = generator.streamKind
        generator.load(reloadPosts: true, reloadHeader: false, reloadCategories: false)
        streamViewController.isPullToRefreshEnabled = false
    }

    func reloadCurrentCategory() {
        ElloHUD.showLoadingHudInView(streamViewController.view)
        screen.categoriesLoaded = false
        generator.load(reloadPosts: true, reloadHeader: false, reloadCategories: true)
        streamViewController.isPullToRefreshEnabled = false
    }
}

extension CategoryViewController: CategoryStreamDestination, StreamDestination {

    var isPagingEnabled: Bool {
        get { return streamViewController.isPagingEnabled }
        set { streamViewController.isPagingEnabled = newValue }
    }

    func replacePlaceholder(type: StreamCellType.PlaceholderType, items: [StreamCellItem], completion: @escaping Block) {
        streamViewController.replacePlaceholder(type: type, items: items) {
            if self.streamViewController.hasCellItems(for: .pageHeader) && !self.streamViewController.hasCellItems(for: .streamItems) {
                self.streamViewController.replacePlaceholder(type: .streamItems, items: [StreamCellItem(type: .streamLoading)])
            }

            completion()
        }

        updateInsets()

        if type == .streamItems {
            streamViewController.isPullToRefreshEnabled = true
            streamViewController.doneLoading()
        }
        else {
            streamViewController.hideLoadingSpinner()
        }
    }

    func setPlaceholders(items: [StreamCellItem]) {
        streamViewController.clearForInitialLoad(newItems: items)
    }

    func setPrimary(jsonable: Model) {
        guard let pageHeader = jsonable as? PageHeader else { return }
        self.pageHeader = pageHeader

        if let trackingPostToken = pageHeader.postToken {
            let trackViews: ElloAPI = .promotionalViews(tokens: [trackingPostToken])
            ElloProvider.shared.request(trackViews).ignoreErrors()
        }

        updateInsets()
    }

    func set(category: Category) {
        self.category = category
        self.title = category.name
    }

    func set(subscribedCategories: [Category]) {
        self.subscribedCategories = subscribedCategories
        screen.categoriesLoaded = true

        var info: [CategoryCardListView.CategoryInfo] = [.all]

        if hasSubscribedCategory {
            info.append(.subscribed)
            screen.showSubscribed = true
        }
        else {
            screen.showSubscribed = false
        }

        info += subscribedCategories.map { (category: Category) -> CategoryCardListView.CategoryInfo in
            return CategoryCardListView.CategoryInfo(category: category)
        }

        if !hasSubscribedCategory && currentUser != nil {
            info.append(.zeroState)
        }

        let pullToRefreshView = streamViewController.pullToRefreshView
        pullToRefreshView?.isHidden = true
        screen.set(categoriesInfo: info) {
            pullToRefreshView?.isVisible = true
        }

        if case let .category(slug) = categorySelection,
            let selectedCategoryIndex = subscribedCategories.index(where: { $0.slug == slug })
        {
            screen.scrollToCategory(.category(selectedCategoryIndex))
            screen.selectCategory(.category(selectedCategoryIndex))
        }

        let screenSelection: CategoryScreen.Selection
        switch categorySelection {
        case .all:
            screenSelection = .all
        case .subscribed:
            screenSelection = .subscribed
        case let .category(slug):
            if let index = subscribedCategories.index(where: { $0.slug == slug }) {
                screenSelection = .category(index)
            }
            else {
                screenSelection = .all
            }
        }
        screen.selectCategory(screenSelection)

        updateInsets()
    }

    func primaryModelNotFound() {
    }

    func setPagingConfig(responseConfig: ResponseConfig) {
        streamViewController.responseConfig = responseConfig
    }
}

extension CategoryViewController: CategoryScreenDelegate {
    func searchButtonTapped() {
        let search = SearchViewController()
        search.currentUser = currentUser
        self.navigationController?.pushViewController(search, animated: true)
    }

    func scrollToTop() {
        streamViewController.scrollToTop(animated: true)
    }

    func selectCategoryFor(slug: String) {
        guard let category = categoryFor(slug: slug) else {
            if subscribedCategories == nil {
                self.categorySelection = .category(slug)
            }
            return
        }
        select(category: category)
    }

    private func categoryFor(slug: String) -> Category? {
        return subscribedCategories?.find { $0.slug == slug }
    }

    func gridListToggled(sender: UIButton) {
        streamViewController.gridListToggled(sender)
    }

    func allCategoriesTapped() {
        Tracker.shared.allCategoriesTapped()
        selectAllCategories()
    }

    func editCategoriesTapped() {
        guard let currentUser = currentUser else { return }

        Tracker.shared.editCategoriesTapped()
        let vc = ManageCategoriesViewController(currentUser: currentUser)
        vc.currentUser = currentUser
        navigationController?.pushViewController(vc, animated: true)
    }

    func subscribedCategoryTapped() {
        Tracker.shared.subscribedCategoryTapped()
        selectSubscribedCategory()
    }

    func categorySelected(index: Int) {
        guard
            let category = subscribedCategories?[index],
            category.id != self.category?.id
        else { return }

        select(category: category)
    }

    private func select(_ selection: Category.Selection) {
        switch selection {
        case .all:
            selectAllCategories()
        case .subscribed:
            selectSubscribedCategory()
        case let .category(slug):
            selectCategoryFor(slug: slug)
        }
    }

    private func selectAllCategories() {
        category = nil
        prevSelection = categorySelection
        categorySelection = .all
        title = InterfaceString.Discover.Title

        screen.scrollToCategory(.all)
        screen.selectCategory(.all)
        generator.reset(selection: categorySelection)
        streamViewController.streamKind = generator.streamKind
        loadCategory()

        trackScreenAppeared()
    }

    private func selectSubscribedCategory() {
        category = nil
        prevSelection = categorySelection
        categorySelection = .subscribed
        title = InterfaceString.Discover.Title

        screen.scrollToCategory(.subscribed)
        screen.selectCategory(.subscribed)
        generator.reset(selection: categorySelection)
        streamViewController.streamKind = generator.streamKind
        loadCategory()

        trackScreenAppeared()
    }

    private func select(category: Category) {
        Tracker.shared.categoryOpened(category.slug)

        self.category = category
        categorySelection = .category(category.slug)
        title = category.name

        if let index = subscribedCategories?.index(where: { $0.slug == category.slug }) {
            screen.scrollToCategory(.category(index))
            screen.selectCategory(.category(index))
        }
        generator.reset(selection: categorySelection)
        streamViewController.streamKind = generator.streamKind
        loadCategory()

        trackScreenAppeared()
    }

    func shareTapped(sender: UIView) {
        guard
            let shareURL = categorySelection.shareLink
        else { return }

        showShareActivity(sender: sender, url: shareURL)
    }

}

extension CategoryViewController: CategoryHeaderResponder {
    func categoryHeaderTapped(cell: UICollectionViewCell, header: PageHeader) {
        print("=============== \(#file) line \(#line) ===============")
        print("header: \(header)")
    }
}
extension CategoryViewController: PromotionalHeaderResponder {
    func categorySubscribed(categoryId: String) {
        guard
            let currentUser = currentUser,
            !currentUser.subscribedTo(categoryId: categoryId)
        else { return }

        var newCategoryIds = currentUser.followedCategoryIds
        newCategoryIds.insert(categoryId)
        ElloHUD.showLoadingHudInView(streamViewController.view)
        ProfileService().update(categoryIds: newCategoryIds, onboarding: false)
            .ensure {
                ElloHUD.hideLoadingHudInView(self.streamViewController.view)
            }
            .done { _ in
                currentUser.followedCategoryIds = newCategoryIds
                self.appViewController?.currentUser = currentUser
            }
            .ignoreErrors()
    }
}

extension CategoryViewController: PostFeaturedResponder {
    func categoryPostTapped(streamCellItem: StreamCellItem, categoryPost: CategoryPost) {
        guard
            streamCellItem.state == .none,
            let action = categoryPost.actions.first
        else { return }

        if let indexPath = self.streamViewController.indexPath(forItem: streamCellItem) {
            streamCellItem.state = .loading
            self.streamViewController.performDataUpdate { collectionView in
                collectionView.reloadItems(at: [indexPath])
            }
        }

         ElloProvider.shared.request(action.endpoint)
             .done { (jsonable, _) in
                 guard let newCategoryPost = jsonable as? CategoryPost else { return }
                 streamCellItem.jsonable = newCategoryPost
             }
             .ensure {
                guard let indexPath = self.streamViewController.indexPath(forItem: streamCellItem) else { return }
                streamCellItem.state = .none
                self.streamViewController.performDataUpdate { collectionView in
                    collectionView.reloadItems(at: [indexPath])
                }
             }
            .ignoreErrors()
    }
}

extension CategoryViewController: StreamSelectionCellResponder {

    func streamTapped(_ filterName: String) {
        Tracker.shared.categoryFilterChanged(filterName, on: categorySelection)
        let filter: CategoryFilter! = CategoryFilter(rawValue: filterName)
        loadStream(filter)

        trackScreenAppeared()
    }

}
