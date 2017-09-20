////
///  CategoryScreen.swift
//

import SnapKit


class CategoryScreen: HomeSubviewScreen, CategoryScreenProtocol {
    struct Size {
        static let navigationBarHeight: CGFloat = 43
        static let largeNavigationBarHeight: CGFloat = 128
        static let buttonWidth: CGFloat = 40
        static let buttonMargin: CGFloat = 5
    }

    enum NavBarItems {
        case onlyGridToggle
        case all
        case none
    }

    weak var delegate: CategoryScreenDelegate?
    fileprivate let usage: CategoryViewController.Usage

    init(usage: CategoryViewController.Usage) {
        self.usage = usage
        super.init(frame: .zero)
    }

    required init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var isGridView = false {
        didSet {
            gridListButton.setImage(isGridView ? .listView : .gridView, imageStyle: .normal, for: .normal)
        }
    }

    fileprivate let categoryCardList = CategoryCardListView()
    fileprivate let iPhoneBlackBar = UIView()
    fileprivate let searchField = SearchNavBarField()
    fileprivate let searchFieldButton = UIButton()
    fileprivate let backButton = UIButton()
    fileprivate let gridListButton = UIButton()
    fileprivate let shareButton = UIButton()
    fileprivate let navigationContainer = UIView()

    fileprivate var categoryCardTopConstraint: Constraint!
    fileprivate var iPhoneBlackBarTopConstraint: Constraint!
    fileprivate var backVisibleConstraint: Constraint!
    fileprivate var backHiddenConstraint: Constraint!
    fileprivate var shareVisibleConstraint: Constraint!
    fileprivate var shareHiddenConstraint: Constraint!
    fileprivate var allHiddenConstraint: Constraint!

    var topInsetView: UIView {
        if categoryCardsVisible {
            return categoryCardList
        }
        else {
            return navigationBar
        }
    }

    fileprivate var _categoryCardsVisible: Bool = true
    var categoryCardsVisible: Bool {
        set {
            _categoryCardsVisible = newValue
            categoryCardList.isHidden = !categoryCardsVisible
        }
        get { return _categoryCardsVisible && categoryCardList.categoriesInfo.count > 0 }
    }

    override func style() {
        super.style()
        iPhoneBlackBar.backgroundColor = .black
        backButton.setImages(.angleBracket, degree: 180)
        shareButton.alpha = 0
        shareButton.setImage(.share, imageStyle: .normal, for: .normal)
    }

    override func bindActions() {
        super.bindActions()
        categoryCardList.delegate = self
        searchFieldButton.addTarget(self, action: #selector(searchFieldButtonTapped), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        gridListButton.addTarget(self, action: #selector(gridListToggled), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
    }

    override func arrange() {
        super.arrange()
        addSubview(categoryCardList)
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

        if AppSetup.shared.isIphoneX {
            addSubview(iPhoneBlackBar)
            iPhoneBlackBar.snp.makeConstraints { make in
                iPhoneBlackBarTopConstraint = make.top.equalTo(self).constraint
                make.leading.trailing.equalTo(self)
                make.height.equalTo(AppSetup.shared.statusBarHeight + Size.navigationBarHeight)
            }
            iPhoneBlackBar.alpha = 0
        }
        categoryCardList.isHidden = true

        categoryCardList.snp.makeConstraints { make in
            categoryCardTopConstraint = make.top.equalTo(navigationBar.snp.bottom).constraint
            make.leading.trailing.equalTo(self)
            make.height.equalTo(CategoryCardListView.Size.height)
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
            insets.top -= BlackBar.Size.height
            insets.bottom -= 1
            make.bottom.equalTo(navigationBar).inset(insets)
            make.height.equalTo(Size.navigationBarHeight - insets.top - insets.bottom)

            backHiddenConstraint = make.leading.equalTo(navigationBar).inset(insets).constraint
            backVisibleConstraint = make.leading.equalTo(backButton.snp.trailing).offset(insets.left).constraint

            shareHiddenConstraint = make.trailing.equalTo(gridListButton.snp.leading).offset(-insets.right).constraint
            shareVisibleConstraint = make.trailing.equalTo(shareButton.snp.leading).offset(-Size.buttonMargin).constraint
            allHiddenConstraint = make.trailing.equalTo(gridListButton.snp.trailing).offset(-Size.buttonMargin).constraint
        }
        shareVisibleConstraint.deactivate()
        allHiddenConstraint.deactivate()

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

    func set(categoriesInfo newValue: [CategoryCardListView.CategoryInfo], animated: Bool, completion: @escaping Block) {
        categoryCardList.categoriesInfo = newValue
        categoryCardList.isHidden = !categoryCardsVisible

        if categoryCardsVisible && animated {
            showCategoryCardList(completion: completion)
        }
        else {
            completion()
        }
    }

    fileprivate func showCategoryCardList(completion: @escaping Block = {}) {
        let originalY = categoryCardList.frame.origin.y
        categoryCardList.frame.origin.y = -categoryCardList.frame.size.height
        animate(completion: { _ in completion() }) {
            self.categoryCardList.frame.origin.y = originalY
        }
    }

    func animateCategoriesList(navBarVisible: Bool) {
        animate {
            let categoryCardListTop: CGFloat
            if navBarVisible {
                categoryCardListTop = self.navigationBar.frame.height
            }
            else if AppSetup.shared.isIphoneX {
                categoryCardListTop = AppSetup.shared.statusBarHeight
            }
            else {
                categoryCardListTop = 0
            }

            self.categoryCardTopConstraint.update(offset: categoryCardListTop)
            self.categoryCardList.frame.origin.y = categoryCardListTop

            if AppSetup.shared.isIphoneX {
                let iPhoneBlackBarTop = self.categoryCardList.frame.minY - self.iPhoneBlackBar.frame.height
                self.iPhoneBlackBarTopConstraint.update(offset: iPhoneBlackBarTop)
                self.iPhoneBlackBar.frame.origin.y = iPhoneBlackBarTop
                self.iPhoneBlackBar.alpha = navBarVisible ? 0 : 1
            }
        }
    }

    func scrollToCategory(index: Int) {
        self.categoryCardList.scrollToIndex(index + 1, animated: true)
    }

    func selectCategory(index: Int) {
        self.categoryCardList.selectCategory(index: index + 1)
    }

    func searchFieldButtonTapped() {
        delegate?.searchButtonTapped()
    }

    func backTapped() {
        delegate?.backTapped()
    }

    func gridListToggled() {
        delegate?.gridListToggled(sender: gridListButton)
    }

    func shareTapped() {
        delegate?.shareTapped(sender: shareButton)
    }

    func setupNavBar(show: CategoryScreen.NavBarItems, back backVisible: Bool, animated: Bool) {
        let shareButtonAlpha: CGFloat
        let gridButtonAlpha: CGFloat
        switch show {
        case .onlyGridToggle:
            shareHiddenConstraint.activate()
            shareVisibleConstraint.deactivate()
            allHiddenConstraint.deactivate()
            shareButtonAlpha = 0
            gridButtonAlpha = 1
        case .all:
            shareHiddenConstraint.deactivate()
            shareVisibleConstraint.activate()
            allHiddenConstraint.deactivate()
            shareButtonAlpha = 1
            gridButtonAlpha = 1
        case .none:
            shareHiddenConstraint.deactivate()
            shareVisibleConstraint.deactivate()
            allHiddenConstraint.activate()
            shareButtonAlpha = 0
            gridButtonAlpha = 0
        }

        backButton.isHidden = !backVisible
        if backVisible {
            backHiddenConstraint.deactivate()
            backVisibleConstraint.activate()
        }
        else {
            backHiddenConstraint.activate()
            backVisibleConstraint.deactivate()
        }

        animate(animated: animated) {
            self.navigationBar.layoutIfNeeded()
            self.shareButton.alpha = shareButtonAlpha
            self.gridListButton.alpha = gridButtonAlpha
        }
    }

}

extension CategoryScreen: CategoryCardListDelegate {
    func allCategoriesTapped() {
        delegate?.allCategoriesTapped()
    }

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
