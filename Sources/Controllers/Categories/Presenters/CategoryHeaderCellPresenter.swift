////
///  CategoryHeaderCellPresenter.swift
//

struct CategoryHeaderCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard
            let cell = cell as? CategoryHeaderCell,
            let pageHeader = streamCellItem.jsonable as? PageHeader
        else { return }

        let isSubscribed: Bool
        if let currentUser = currentUser, let categoryId = pageHeader.categoryId {
            isSubscribed = currentUser.subscribedTo(categoryId: categoryId)
        }
        else {
            isSubscribed = false
        }

       let config = CategoryHeaderCell.Config(pageHeader: pageHeader, isSubscribed: isSubscribed)
       cell.config = config
    }
}
