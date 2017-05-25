////
///  CategoryViewController.swift
//

final class CategoryViewController: StreamableViewController {
    override func trackerName() -> String? { return "Discover" }
    override func trackerProps() -> [String: Any]? {
        guard let slug = slug else { return nil }

        return ["category": slug]
    }
    override func trackerStreamInfo() -> (String, String?)? {
        if let streamId = category?.id {
            return ("category", streamId)
        }
        else if let slug = slug, DiscoverType.fromURL(slug) != nil {
            return (slug, nil)
        }
        else {
            return nil
        }
    }

    override var tabBarItem: UITabBarItem? {
        get { return UITabBarItem.item(.searchTabBar, insets: ElloTab.discover.insets) }
        set { self.tabBarItem = newValue }
    }

    private var _mockScreen: CategoryScreenProtocol?
    var screen: CategoryScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return _mockScreen ?? self.view as! CategoryScreen }
    }

    var category: Category?
    var slug: String?
    fileprivate var prevSlug: String?
    var allCategories: [Category]?
    var pagePromotional: PagePromotional?
    var categoryPromotional: Promotional?
    var generator: CategoryGenerator?
    var userDidScroll: Bool = false

    var showBackButton: Bool {
        return !isRootViewController()
    }

    init(slug: String, name: String? = nil) {
        self.slug = slug
        super.init(nibName: nil, bundle: nil)
        self.title = name
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let screen = CategoryScreen()
        screen.delegate = self

        self.view = screen
        viewContainer = screen.streamContainer

        loadCategory(initial: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let streamKind: StreamKind
        if let slug = slug, let type = DiscoverType.fromURL(slug) {
            streamKind = .discover(type: type)
            screen.setupNavBar(show: .onlyGridToggle, back: showBackButton, animated: false)
        }
        else if let slug = slug {
            streamKind = .category(slug: slug)
            screen.setupNavBar(show: .all, back: showBackButton, animated: false)
        }
        else {
            streamKind = .allCategories
            screen.setupNavBar(show: .none, back: true, animated: false)
        }
        streamViewController.streamKind = streamKind
        screen.isGridView = streamKind.isGridView

        self.generator = CategoryGenerator(
            slug: slug,
            currentUser: currentUser,
            streamKind: streamKind,
            destination: self
        )

        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.initialLoadClosure = { [weak self] in self?.loadCategory(initial: true) }
        streamViewController.reloadClosure = { [weak self] in self?.reloadCurrentCategory() }
        streamViewController.toggleClosure = { [weak self] isGridView in self?.toggleGrid(isGridView) }

        self.loadCategory(initial: true)
    }

    fileprivate func updateInsets() {
        updateInsets(navBar: screen.topInsetView)

        if !userDidScroll && screen.categoryCardsVisible {
            var offset: CGFloat = CategoryCardListView.Size.height
            if screen.navigationBar.frame.maxY > 0 {
                offset += ElloNavigationBar.Size.height - 1
            }
            streamViewController.collectionView.setContentOffset(CGPoint(x: 0, y: -offset), animated: true)
        }
    }

    override func showNavBars() {
        super.showNavBars()
        positionNavBar(screen.navigationBar, visible: true, withConstraint: screen.navigationBarTopConstraint)
        screen.animateCategoriesList(navBarVisible: true)
        updateInsets()
    }

    override func hideNavBars() {
        super.hideNavBars()
        positionNavBar(screen.navigationBar, visible: false, withConstraint: screen.navigationBarTopConstraint)
        screen.animateCategoriesList(navBarVisible: false)
        updateInsets()
    }

    func toggleGrid(_ isGridView: Bool) {
        generator?.toggleGrid()
    }

    override func streamViewWillBeginDragging(scrollView: UIScrollView) {
        super.streamViewWillBeginDragging(scrollView: scrollView)
        userDidScroll = true
    }

    override func backTapped() {
        if slug == nil {
            selectCategoryFor(slug: prevSlug ?? "featured")
        }
        else {
            super.backTapped()
        }
    }
}

private extension CategoryViewController {

    func loadCategory(initial: Bool) {
        if !initial {
            replacePlaceholder(type: .categoryPosts, items: [StreamCellItem(type: .streamLoading)]) {}
        }
        title = category?.name ?? slug.flatMap { DiscoverType.fromURL($0)?.name } ?? InterfaceString.Discover.Title

        pagePromotional = nil
        categoryPromotional = nil
        category?.randomPromotional = nil
        generator?.load()

        streamViewController.pagingEnabled = true
    }

    func reloadCurrentCategory() {
        pagePromotional = nil
        categoryPromotional = nil
        category?.randomPromotional = nil
        generator?.load(reload: true)
    }
}

// MARK: CategoryViewController: StreamDestination
extension CategoryViewController: CategoryStreamDestination, StreamDestination {

    var pagingEnabled: Bool {
        get { return streamViewController.pagingEnabled }
        set { streamViewController.pagingEnabled = newValue }
    }

    func replacePlaceholder(type: StreamCellType.PlaceholderType, items: [StreamCellItem], completion: @escaping ElloEmptyCompletion) {
        streamViewController.replacePlaceholder(type: type, items: items) {
            if self.streamViewController.hasCellItems(for: .categoryHeader) && !self.streamViewController.hasCellItems(for: .categoryPosts) {
                self.streamViewController.replacePlaceholder(type: .categoryPosts, items: [StreamCellItem(type: .streamLoading)]) {}
            }

            completion()
        }
        updateInsets()
    }

    func setPlaceholders(items: [StreamCellItem]) {
        streamViewController.clearForInitialLoad()
        streamViewController.appendStreamCellItems(items)
    }

    func setPrimary(jsonable: JSONAble) {
        if let category = jsonable as? Category {
            self.category = category

            if let categoryPromotional = self.categoryPromotional {
                category.randomPromotional = categoryPromotional
            }
            else {
                categoryPromotional = category.randomPromotional
            }

            self.title = category.name
        }
        else if let pagePromotional = jsonable as? PagePromotional {
            self.pagePromotional = pagePromotional
        }
        updateInsets()
        streamViewController.doneLoading()
    }

    func set(categories: [Category]) {
        allCategories = categories

        let shouldAnimate = !screen.categoryCardsVisible
        let info = categories.map { (category: Category) -> CategoryCardListView.CategoryInfo in
            return CategoryCardListView.CategoryInfo(title: category.name, imageURL: category.tileURL)
        }

        let pullToRefreshView = streamViewController.pullToRefreshView
        pullToRefreshView?.isHidden = true
        screen.set(categoriesInfo: info, animated: shouldAnimate) {
            pullToRefreshView?.isHidden = false
        }

        let selectedCategoryIndex = categories.index { $0.slug == slug }
        if let selectedCategoryIndex = selectedCategoryIndex, shouldAnimate {
            screen.scrollToCategory(index: selectedCategoryIndex)
            screen.selectCategory(index: selectedCategoryIndex)
        }

        updateInsets()
    }

    func primaryJSONAbleNotFound() {
        self.streamViewController.doneLoading()
    }

    func setPagingConfig(responseConfig: ResponseConfig) {
        streamViewController.responseConfig = responseConfig
    }
}

extension CategoryViewController: CategoryScreenDelegate {

    func selectCategoryFor(slug: String) {
        guard let category = categoryFor(slug: slug) else {
            if allCategories == nil {
                self.slug = slug
            }
            return
        }
        select(category: category)
    }

    fileprivate func categoryFor(slug: String) -> Category? {
        return allCategories?.find { $0.slug == slug }
    }

    func gridListToggled(sender: UIButton) {
        streamViewController.gridListToggled(sender)
    }

    func allCategoriesTapped() {
        selectAllCategories()
    }

    func categorySelected(index: Int) {
        guard
            let category = allCategories?.safeValue(index),
            category.id != self.category?.id
        else { return }

        select(category: category)
    }

    private func selectAllCategories() {
        guard let allCategories = allCategories else { return }

        let streamKind = StreamKind.allCategories
        streamViewController.streamKind = streamKind
        streamViewController.pagingEnabled = false
        generator?.reset(streamKind: streamKind, category: nil, pagePromotional: nil)

        prevSlug = slug
        category = nil
        slug = nil
        title = InterfaceString.Discover.Title
        pagePromotional = nil
        categoryPromotional = nil

        screen.setupNavBar(show: .none, back: true, animated: true)
        screen.scrollToCategory(index: -1)
        screen.selectCategory(index: -1)
        screen.categoryCardsVisible = false

        let sortedCategories = CategoryList(categories: allCategories).categories
        let categoryItems = allCategoryItems(categories: sortedCategories)
        replacePlaceholder(type: .categoryHeader, items: []) {}
        replacePlaceholder(type: .categoryPosts, items: categoryItems) {}
        streamViewController.reloadCells(now: true)

        trackScreenAppeared()
    }

    private func select(category: Category) {
        Tracker.shared.categoryOpened(category.slug)

        var kind: StreamKind?
        let showShare: Bool
        switch category.level {
        case .meta:
            showShare = false
            if let type = DiscoverType.fromURL(category.slug) {
                kind = .discover(type: type)
            }
        default:
            showShare = true
            kind = .category(slug: category.slug)
        }

        guard let streamKind = kind else { return }

        category.randomPromotional = nil
        streamViewController.streamKind = streamKind
        screen.isGridView = streamKind.isGridView
        screen.setupNavBar(show: showShare ? .all : .onlyGridToggle, back: showBackButton, animated: true)
        screen.categoryCardsVisible = true
        generator?.reset(streamKind: streamKind, category: category, pagePromotional: nil)
        self.category = category
        self.slug = category.slug
        self.title = category.name
        loadCategory(initial: false)

        if let index = allCategories?.index(where: { $0.slug == category.slug }) {
            screen.scrollToCategory(index: index)
            screen.selectCategory(index: index)
        }
        trackScreenAppeared()
    }

    func shareTapped(sender: UIView) {
        guard
            let category = category,
            let shareURL = URL(string: category.shareLink)
        else { return }

        showShareActivity(sender: sender, url: shareURL)
    }

}

// MARK: StreamViewDelegate
extension CategoryViewController {
    func allCategoryItems(categories: [Category]) -> [StreamCellItem] {
        let metaCategories = categories.filter { $0.isMeta }
        let cardCategories = categories.filter { !$0.isMeta }

        let metaCategoriesList = CategoryList(categories: metaCategories)
        let metaCategoriesItem = StreamCellItem(jsonable: metaCategoriesList, type: .categoryList)
        var items: [StreamCellItem] = [metaCategoriesItem]
        items += cardCategories.map { StreamCellItem(jsonable: $0, type: .categoryCard) }
        return items
    }
}
