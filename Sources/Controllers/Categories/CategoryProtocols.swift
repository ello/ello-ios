////
///  CategoryProtocols.swift
//

protocol CategoryScreenProtocol: StreamableScreenProtocol {
    var topInsetView: UIView { get }
    var categoryCardsVisible: Bool { get }
    func set(categoriesInfo: [CategoryCardListView.CategoryInfo], animated: Bool, completion: @escaping ElloEmptyCompletion)
    func animateCategoriesList(navBarVisible: Bool)
    func scrollToCategory(index: Int)
    func selectCategory(index: Int)
}

protocol CategoryScreenDelegate: class {
    func categorySelected(index: Int)
}
