////
///  CategoryListCellPresenter.swift
//

struct CategoryListCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard
            let cell = cell as? CategoryListCell,
            let categoryList = streamCellItem.jsonable as? CategoryList
        else { return }

        cell.categoriesInfo = categoryList.categories.map { (title: $0.name, slug: $0.slug) }
    }

}
