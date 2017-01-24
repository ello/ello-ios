////
///  CategoryViewController.swift
//

final class CategoryViewController: StreamableViewController {
    override func trackerName() -> String? { return "Discover" }
    override func trackerProps() -> [String: AnyObject]? {
        return ["category": slug as AnyObject]
    }

    var mockScreen: CategoryScreenProtocol?
    var screen: CategoryScreenProtocol {
        return mockScreen ?? self.view as! CategoryScreenProtocol
    }

    var gridListItem: UIBarButtonItem?
    var category: Category?
    var slug: String
    var allCategories: [Category] = []
    var pagePromotional: PagePromotional?
    var categoryPromotional: Promotional?
    var generator: CategoryGenerator?
    var userDidScroll: Bool = false

    init(slug: String, name: String? = nil) {
        self.slug = slug
        super.init(nibName: nil, bundle: nil)
        self.title = name
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.title = category?.name ?? DiscoverType.fromURL(slug)?.name

        let screen = CategoryScreen()
        screen.navigationItem = elloNavigationItem

        self.view = screen
        viewContainer = screen.streamContainer
        screen.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItems()
        let streamKind: StreamKind
        if let type = DiscoverType.fromURL(slug) {
            streamKind = .discover(type: type)
        }
        else {
            streamKind = .category(slug: slug)
        }
        streamViewController.streamKind = streamKind
        gridListItem?.setImage(isGridView: streamKind.isGridView)

        self.generator = CategoryGenerator(
            slug: slug,
            currentUser: currentUser,
            streamKind: streamKind,
            destination: self
        )

        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.initialLoadClosure = { [unowned self] in self.loadCategory() }
        streamViewController.reloadClosure = { [unowned self] in self.reloadCurrentCategory() }
        streamViewController.toggleClosure = { [unowned self] isGridView in self.toggleGrid(isGridView) }

        streamViewController.loadInitialPage()
    }

    fileprivate func updateInsets() {
        updateInsets(navBar: screen.topInsetView, streamController: streamViewController)

        if !userDidScroll && screen.categoryCardsVisible {
            var offset: CGFloat = CategoryCardListView.Size.height
            if tabBarVisible() {
                offset += ElloNavigationBar.Size.height
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
        positionNavBar(screen.navigationBar, visible: false, withConstraint: screen.navigationBarTopConstraint, animated: true)
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
}

private extension CategoryViewController {

    func setupNavigationItems() {
        let backItem = UIBarButtonItem.backChevron(withController: self)
        elloNavigationItem.leftBarButtonItems = [backItem]
        elloNavigationItem.fixNavBarItemPadding()

        let searchItem = UIBarButtonItem.searchItem(controller: self)
        let gridListItem = UIBarButtonItem.gridListItem(delegate: streamViewController, isGridView: streamViewController.streamKind.isGridView)
        self.gridListItem = gridListItem
        let rightBarButtonItems = [searchItem, gridListItem]
        if !elloNavigationItem.areRightButtonsTheSame(rightBarButtonItems) {
            elloNavigationItem.rightBarButtonItems = rightBarButtonItems
        }
    }

    func loadCategory() {
        pagePromotional = nil
        categoryPromotional = nil
        category?.randomPromotional = nil
        generator?.load()
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
        streamViewController.replacePlaceholder(type, with: items) {
            if self.streamViewController.hasCellItems(for: .categoryHeader) && !self.streamViewController.hasCellItems(for: .categoryPosts) {
                self.streamViewController.replacePlaceholder(.categoryPosts, with: [StreamCellItem(type: .streamLoading)]) {}
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
        let info = allCategories.map { (category: Category) -> CategoryCardListView.CategoryInfo in
            return CategoryCardListView.CategoryInfo(title: category.name, imageURL: category.tileURL)
        }

        let pullToRefreshView = streamViewController.pullToRefreshView
        pullToRefreshView?.isHidden = true
        screen.set(categoriesInfo: info, animated: shouldAnimate) {
            pullToRefreshView?.isHidden = false
        }

        let selectedCategoryIndex = allCategories.index { $0.slug == slug }
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
        guard let category = categoryFor(slug: slug) else { return }
        select(category: category)
    }

    fileprivate func categoryFor(slug: String) -> Category? {
        return allCategories.find { $0.slug == slug }
    }

    func categorySelected(index: Int) {
        guard
            let category = allCategories.safeValue(index), category.id != self.category?.id
        else { return }
        screen.selectCategory(index: index)
        select(category: category)
    }

    func select(category: Category) {
		Tracker.shared.categoryOpened(category.slug)

        var kind: StreamKind?
        switch category.level {
        case .meta:
            if let type = DiscoverType.fromURL(category.slug) {
                kind = .discover(type: type)
            }
        default:
            kind = .category(slug: category.slug)
        }

        guard let streamKind = kind else { return }


        category.randomPromotional = nil
        streamViewController.streamKind = streamKind
        gridListItem?.setImage(isGridView: streamKind.isGridView)
        generator?.reset(streamKind: streamKind, category: category, pagePromotional: nil)
        self.category = category
        self.slug = category.slug
        self.title = category.name
        loadCategory()
        Tracker.shared.screenAppeared(self)
    }
}
