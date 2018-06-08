////
///  PromotionalHeaderSubscriptionCellPresenter.swift
//

struct PromotionalHeaderSubscriptionCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard
            let cell = cell as? PromotionalHeaderSubscriptionCell,
            let pageHeader = streamCellItem.jsonable as? PageHeader
        else { return }

        if let currentUser = currentUser, let categoryId = pageHeader.categoryId {
            cell.isSubscribed = currentUser.subscribedTo(categoryId: categoryId)
        }
        else {
            cell.isSubscribed = false
        }
    }
}
