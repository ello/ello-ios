////
///  DiscoverAllCategoriesViewController.swift
//

class DiscoverAllCategoriesViewController: StreamableViewController {
    override func trackerName() -> String? { return "Discover" }
    override func trackerProps() -> [String: AnyObject]? {
        return ["category": "all" as AnyObject]
    }

    override var tabBarItem: UITabBarItem? {
        get { return UITabBarItem.item(.sparkles, insets: UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)) }
        set { self.tabBarItem = newValue }
    }

    var screen: DiscoverAllCategoriesScreen { return self.view as! DiscoverAllCategoriesScreen }

    required init() {
        super.init(nibName: nil, bundle: nil)

        streamViewController.initialLoadClosure = { [unowned self] in self.loadCategories() }
        streamViewController.streamKind = .allCategories
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        title = InterfaceString.Discover.Title

        if !isRootViewController() {
            let item = UIBarButtonItem.backChevron(withController: self)
            self.elloNavigationItem.leftBarButtonItems = [item]
            self.elloNavigationItem.fixNavBarItemPadding()
        }

        elloNavigationItem.rightBarButtonItem = UIBarButtonItem.searchItem(controller: self)

        let screen = DiscoverAllCategoriesScreen()
        screen.navigationItem = elloNavigationItem
        self.view = screen
        viewContainer = screen.streamContainer
    }

    func loadCategories() {
        CategoryService().loadCategories().onSuccess { [weak self] categories in
            guard let `self` = self else { return }

            let sortedCategories = CategoryList(categories: categories).categories

            self.streamViewController.showInitialJSONAbles(sortedCategories)
        }.ignoreFailures()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.loadInitialPage()
    }

    fileprivate func updateInsets() {
        updateInsets(navBar: screen.navigationBar, streamController: streamViewController)
    }

    override func showNavBars() {
        super.showNavBars()
        positionNavBar(screen.navigationBar, visible: true, withConstraint: screen.navigationBarTopConstraint)
        updateInsets()
    }

    override func hideNavBars() {
        super.hideNavBars()
        positionNavBar(screen.navigationBar, visible: false, withConstraint: screen.navigationBarTopConstraint)
        updateInsets()
    }

}

// MARK: StreamViewDelegate
extension DiscoverAllCategoriesViewController {

    override func streamViewStreamCellItems(jsonables: [JSONAble], defaultGenerator generator: StreamCellItemGenerator) -> [StreamCellItem]? {
        guard let categories = jsonables as? [Category] else { return [] }

        let metaCategories = categories.filter { $0.isMeta }
        let cardCategories = categories.filter { !$0.isMeta }

        let metaCategoryList: CategoryList
        if metaCategories.count > 0 {
            metaCategoryList = CategoryList(categories: metaCategories)
        }
        else {
            metaCategoryList = CategoryList.metaCategories()
        }

        var items: [StreamCellItem] = [StreamCellItem(jsonable: metaCategoryList, type: .categoryList)]
        items += cardCategories.map { StreamCellItem(jsonable: $0, type: .categoryCard) }
        return items
    }
}
