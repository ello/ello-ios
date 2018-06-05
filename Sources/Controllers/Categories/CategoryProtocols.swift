////
///  CategoryProtocols.swift
//

protocol CategoryScreenDelegate: class {
    func scrollToTop()
    func backButtonTapped()
    func shareTapped(sender: UIView)
    func gridListToggled(sender: UIButton)
    func allCategoriesTapped()
    func editCategoriesTapped()
    func subscribedCategoryTapped()
    func categorySelected(index: Int)
    func searchButtonTapped()
}

protocol CategoryScreenProtocol: StreamableScreenProtocol {
    var topInsetView: UIView { get }
    var showSubscribed: Bool { get set }
    var showEditButton: Bool { get set }
    var isGridView: Bool { get set }
    var categoriesLoaded: Bool { get set }
    func set(categoriesInfo: [CategoryCardListView.CategoryInfo], completion: @escaping Block)
    func toggleCategoriesList(navBarVisible: Bool, animated: Bool)
    func scrollToCategory(_ selection: CategoryScreen.Selection)
    func selectCategory(_ index: CategoryScreen.Selection)
    func setupNavBar(back: Bool, animated: Bool)
}

protocol CategoryDetailDelegate: class {
    func closeController()
    func adminsLoaded(moderators: [User], curators: [User])
}

protocol CategoryDetailScreenProtocol {
    var headerView: UIView { get }
    func updateUsers(moderators: [User], curators: [User])
}
