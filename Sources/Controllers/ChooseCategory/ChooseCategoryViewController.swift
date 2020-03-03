////
///  ChooseCategoryViewController.swift
//

class ChooseCategoryViewController: StreamableViewController {
    private var _mockScreen: ChooseCategoryScreenProtocol?
    var screen: ChooseCategoryScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return fetchScreen(_mockScreen) }
    }

    var generator: ChooseCategoryGenerator!
    weak var delegate: ChooseCategoryControllerDelegate?
    var selectedIds: Set<String>?
    var categoryFilter: ((Category) -> Bool)?

    enum Usage {
        case omnibar
        case roleAdmin
    }

    init(currentUser: User, category: Category?, usage: Usage) {
        super.init(nibName: nil, bundle: nil)
        self.generator = ChooseCategoryGenerator(
            currentUser: currentUser,
            category: category,
            usage: usage,
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
    }

    override func loadView() {
        let screen = ChooseCategoryScreen()
        screen.navigationBar.title = InterfaceString.Community.Choose
        screen.delegate = self

        view = screen
        viewContainer = screen.streamContainer
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        streamViewController.streamKind = .chooseCategory
        streamViewController.reloadClosure = { [weak self] in self?.generator?.load(reload: true) }

        streamViewController.showLoadingSpinner()
        generator.load(reload: false)
    }

    private func updateInsets() {
        updateInsets(navBar: screen.navigationBar)
    }

    override func showNavBars(animated: Bool) {
        super.showNavBars(animated: animated)
        positionNavBar(
            screen.navigationBar,
            visible: true,
            withConstraint: screen.navigationBarTopConstraint,
            animated: animated
        )
        updateInsets()
    }

    override func hideNavBars(animated: Bool) {
        super.hideNavBars(animated: animated)
        positionNavBar(
            screen.navigationBar,
            visible: false,
            withConstraint: screen.navigationBarTopConstraint,
            animated: animated
        )
        updateInsets()
    }
}

extension ChooseCategoryViewController: ChooseCategoryResponder {
    func categoryChosen(_ category: Category) {
        delegate?.categoryChosen(category)
        let shouldGoBack = delegate?.chooseCategoryShouldGoBack?() ?? true
        if shouldGoBack {
            ElloHUD.showLoadingHudInView(view)
            delay(0.3, block: backButtonTapped)
        }
    }
}

extension ChooseCategoryViewController: StreamDestination {

    var isPagingEnabled: Bool {
        get { return streamViewController.isPagingEnabled }
        set { streamViewController.isPagingEnabled = newValue }
    }

    func replacePlaceholder(
        type: StreamCellType.PlaceholderType,
        items: [StreamCellItem],
        completion: @escaping Block
    ) {
        let filteredItems: [StreamCellItem]
        if type == .streamItems, let categoryFilter = categoryFilter {
            filteredItems = items.filter { item in
                guard let category = item.jsonable as? Category else { return true }
                return categoryFilter(category)
            }
        }
        else {
            filteredItems = items
        }

        streamViewController.replacePlaceholder(
            type: type,
            items: filteredItems,
            completion: completion
        )

        if type == .streamItems {
            streamViewController.doneLoading()
        }
    }

    func setPlaceholders(items: [StreamCellItem]) {
        streamViewController.clearForInitialLoad(newItems: items)
    }

    func setPrimary(jsonable: Model) {
    }

    func primaryModelNotFound() {
        self.streamViewController.doneLoading()
    }

    func setPagingConfig(responseConfig: ResponseConfig) {
        streamViewController.responseConfig = responseConfig
    }
}

extension ChooseCategoryViewController: ChooseCategoryScreenDelegate {
}

extension ChooseCategoryViewController: SearchStreamResponder {

    func searchFieldChanged(text: String) {
        generator.searchString.text = text

        if text.count == 0 {
            streamViewController.batchUpdateFilter(nil)
        }
        else {
            streamViewController.batchUpdateFilter { item in
                guard let category = item.jsonable as? Category else { return true }
                return category.name.lowercased().contains(text.lowercased())
            }
        }
    }
}
