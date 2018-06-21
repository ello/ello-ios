////
///  CategoryScreen.swift
//

import SnapKit


class CategoryScreen: HomeSubviewScreen, CategoryScreenProtocol {
    struct Size {
        static let navigationBarHeight: CGFloat = 43
        static let buttonWidth: CGFloat = 40
        static let buttonMargin: CGFloat = 5
        static let gradientMidpoint: Float = 0.4
        static var categoryCardListInset: CGFloat { return CategoryCardListView.Size.spacing }
    }

    enum NavBarItems {
        case onlyGridToggle
        case all
        case none
    }

    enum Selection {
        case all
        case subscribed
        case category(Int)
    }

    typealias Usage = CategoryViewController.Usage

    weak var delegate: CategoryScreenDelegate?
    var topInsetView: UIView {
        if usage == .detail {
            return navigationBar
        }
        else {
            return categoryCardList
        }
    }
    var showSubscribed: Bool = false
    var showEditButton: Bool = false { didSet { updateEditButton() } }
    var isGridView = false {
        didSet {
            gridListButton.setImage(isGridView ? .listView : .gridView, imageStyle: .normal, for: .normal)
        }
    }
    var categoriesLoaded: Bool = false { didSet { updateEditButton() } }

    private let usage: Usage

    init(usage: Usage) {
        self.usage = usage
        super.init(frame: .default)
    }

    required init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let categoryCardList = CategoryCardListView()
    private let iPhoneBlackBar = UIView()
    private let searchField = SearchNavBarField()
    private let searchFieldButton = UIButton()
    private let backButton = UIButton()
    private let editCategoriesButton = StyledButton(style: .clearWhite)
    private let editCategoriesGradient = CategoryScreen.generateGradientLayer()
    private let gridListButton = UIButton()
    private let shareButton = UIButton()
    private let navigationContainer = Container()

    private var categoryCardTopConstraint: Constraint!
    private var iPhoneBlackBarTopConstraint: Constraint!
    private var backVisibleConstraint: Constraint!
    private var backHiddenConstraint: Constraint!

    private var navBarVisible = true
    private var categoryCardListTop: CGFloat {
        if navBarVisible && usage == .largeNav {
            return ElloNavigationBar.Size.discoverLargeHeight - 1
        }
        else if navBarVisible {
            return ElloNavigationBar.Size.height - 1
        }
        else if Globals.isIphoneX {
            return Globals.statusBarHeight
        }
        else {
            return 0
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        editCategoriesGradient.frame = editCategoriesButton.bounds
    }

    override func style() {
        super.style()
        iPhoneBlackBar.backgroundColor = .black
        backButton.setImages(.backChevron)
        shareButton.setImage(.share, imageStyle: .normal, for: .normal)
        editCategoriesButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 10)
        editCategoriesButton.isHidden = true
        categoryCardList.isHidden = usage == .detail
    }

    override func setText() {
        navigationBar.title = ""
        editCategoriesButton.title = InterfaceString.Edit
    }

    override func bindActions() {
        super.bindActions()
        categoryCardList.delegate = self
        searchFieldButton.addTarget(self, action: #selector(searchFieldButtonTapped), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        gridListButton.addTarget(self, action: #selector(gridListToggled), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        editCategoriesButton.addTarget(self, action: #selector(editCategoriesTapped), for: .touchUpInside)
    }

    override func arrange() {
        super.arrange()
        addSubview(categoryCardList)
        editCategoriesButton.layer.insertSublayer(editCategoriesGradient, at: 0)
        addSubview(editCategoriesButton)
        addSubview(navigationBar)

        navigationContainer.addSubview(searchField)
        navigationContainer.addSubview(searchFieldButton)
        navigationBar.addSubview(backButton)
        navigationBar.addSubview(navigationContainer)
        navigationBar.addSubview(gridListButton)
        navigationBar.addSubview(shareButton)

        if usage == .largeNav {
            navigationBar.sizeClass = .discoverLarge
            arrangeHomeScreenNavBar(type: .discover, navigationBar: navigationBar)
        }

        if Globals.isIphoneX {
            addSubview(iPhoneBlackBar)
            iPhoneBlackBar.snp.makeConstraints { make in
                iPhoneBlackBarTopConstraint = make.top.equalTo(self).constraint
                make.leading.trailing.equalTo(self)
                make.height.equalTo(Globals.statusBarHeight + Size.navigationBarHeight)
            }
            iPhoneBlackBar.alpha = 0
        }

        categoryCardList.snp.makeConstraints { make in
            categoryCardTopConstraint = make.top.equalTo(self).offset(categoryCardListTop).constraint
            make.leading.trailing.equalTo(self)
            make.height.equalTo(CategoryCardListView.Size.height)
        }

        editCategoriesButton.snp.makeConstraints { make in
            make.top.bottom.equalTo(categoryCardList).inset(Size.categoryCardListInset)
            make.trailing.equalTo(self)
        }

        backButton.snp.makeConstraints { make in
            make.leading.bottom.equalTo(navigationBar)
            make.height.equalTo(Size.navigationBarHeight)
            make.width.equalTo(36.5)
        }

        searchField.snp.makeConstraints { make in
            var insets: UIEdgeInsets
            if usage == .largeNav {
                insets = SearchNavBarField.Size.largeNavSearchInsets
            }
            else {
                insets = SearchNavBarField.Size.searchInsets
            }
            insets.top -= StatusBar.Size.height
            insets.bottom -= 1
            make.bottom.equalTo(navigationBar).inset(insets)
            make.height.equalTo(Size.navigationBarHeight - insets.tops)

            backHiddenConstraint = make.leading.equalTo(navigationBar).inset(insets).constraint
            backVisibleConstraint = make.leading.equalTo(backButton.snp.trailing).offset(insets.left).constraint

            make.trailing.equalTo(shareButton.snp.leading).offset(-Size.buttonMargin)
        }

        navigationContainer.snp.makeConstraints { make in
            make.leading.equalTo(searchField).offset(-SearchNavBarField.Size.searchInsets.left)
            make.bottom.equalTo(navigationBar)
            make.height.equalTo(Size.navigationBarHeight)
            make.trailing.equalTo(gridListButton.snp.leading)
        }

        searchFieldButton.snp.makeConstraints { make in
            make.edges.equalTo(navigationContainer)
        }
        gridListButton.snp.makeConstraints { make in
            make.height.equalTo(Size.navigationBarHeight)
            make.bottom.equalTo(navigationBar)
            make.trailing.equalTo(navigationBar).offset(-Size.buttonMargin)
            make.width.equalTo(Size.buttonWidth)
        }
        shareButton.snp.makeConstraints { make in
            make.top.bottom.width.equalTo(gridListButton)
            make.trailing.equalTo(gridListButton.snp.leading)
        }

        navigationBar.snp.makeConstraints { make in
            let intrinsicHeight = navigationBar.sizeClass.height
            make.height.equalTo(intrinsicHeight - 1).priority(Priority.required)
        }
    }

    func set(categoriesInfo newValue: [CategoryCardListView.CategoryInfo], completion: @escaping Block) {
        categoryCardList.categoriesInfo = newValue

        if navBarVisible {
            completion()
            return
        }

        let editCategoriesButtonY = categoryCardListTop + Size.categoryCardListInset
        let originalY = categoryCardList.frame.origin.y
        categoryCardList.frame.origin.y = originalY - categoryCardList.frame.size.height
        editCategoriesButton.frame.origin.y = editCategoriesButtonY - editCategoriesButton.frame.height
        elloAnimate {
            self.editCategoriesButton.frame.origin.y = editCategoriesButtonY
            self.categoryCardList.frame.origin.y = originalY
        }.done(completion)
    }

    private func updateEditButton() {
        let actuallyShowEditButton = showEditButton && categoriesLoaded
        editCategoriesButton.isVisible = actuallyShowEditButton
        let rightInset = actuallyShowEditButton ? editCategoriesButton.frame.width * CGFloat(1 - Size.gradientMidpoint) : 0
        categoryCardList.rightInset = rightInset
    }

    func toggleCategoriesList(navBarVisible: Bool, animated: Bool) {
        self.navBarVisible = navBarVisible
        elloAnimate(animated: animated) {
            self.categoryCardTopConstraint.update(offset: self.categoryCardListTop)
            self.categoryCardList.frame.origin.y = self.categoryCardListTop
            self.editCategoriesButton.frame.origin.y = self.categoryCardListTop + Size.categoryCardListInset

            if Globals.isIphoneX {
                let iPhoneBlackBarTop = self.categoryCardList.frame.minY - self.iPhoneBlackBar.frame.height
                self.iPhoneBlackBarTopConstraint.update(offset: iPhoneBlackBarTop)
                self.iPhoneBlackBar.frame.origin.y = iPhoneBlackBarTop
                self.iPhoneBlackBar.alpha = navBarVisible ? 0 : 1
            }
        }
    }

    func scrollToCategory(_ selection: Selection) {
        switch selection {
        case .all:
            self.categoryCardList.scrollToIndex(0, animated: true)
        case .subscribed:
            self.categoryCardList.scrollToIndex(1, animated: true)
        case let .category(index):
            let offset = showSubscribed ? 2 : 1
            self.categoryCardList.scrollToIndex(index + offset, animated: true)
        }
    }

    func selectCategory(_ selection: Selection) {
        switch selection {
        case .all:
            self.categoryCardList.selectCategory(index: 0)
        case .subscribed:
            self.categoryCardList.selectCategory(index: 1)
        case let .category(index):
            let offset = showSubscribed ? 2 : 1
            self.categoryCardList.selectCategory(index: index + offset)
        }
    }

    @objc
    func searchFieldButtonTapped() {
        delegate?.searchButtonTapped()
    }

    @objc
    func backButtonTapped() {
        delegate?.backButtonTapped()
    }

    @objc
    func gridListToggled() {
        delegate?.gridListToggled(sender: gridListButton)
    }

    @objc
    func shareTapped() {
        delegate?.shareTapped(sender: shareButton)
    }

    func setupNavBar(back backVisible: Bool, animated: Bool) {
        backButton.isVisible = backVisible
        backVisibleConstraint.set(isActivated: backVisible)
        backHiddenConstraint.set(isActivated: !backVisible)

        elloAnimate(animated: animated) {
            self.navigationBar.layoutIfNeeded()
        }
    }
}

extension CategoryScreen: CategoryCardListDelegate {
    @objc
    func allCategoriesTapped() {
        delegate?.allCategoriesTapped()
    }

    @objc
    func editCategoriesTapped() {
        delegate?.editCategoriesTapped()
    }

    @objc
    func subscribedCategoryTapped() {
        delegate?.subscribedCategoryTapped()
    }

    @objc
    func categoryCardSelected(_ index: Int) {
        delegate?.categorySelected(index: index)
    }
}

extension CategoryScreen: HomeScreenNavBar {
    @objc
    func homeScreenScrollToTop() {
        delegate?.scrollToTop()
    }
}

extension CategoryScreen {
    private static func generateGradientLayer() -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.locations = [0, NSNumber(value: CategoryScreen.Size.gradientMidpoint), 1]
        layer.colors = [
            UIColor(hex: 0x000000, alpha: 0).cgColor,
            UIColor(hex: 0x000000, alpha: 1).cgColor,
            UIColor(hex: 0x000000, alpha: 1).cgColor,
        ]
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        return layer
    }
}
