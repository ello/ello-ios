////
///  BadgeCellPresenter.swift
//

struct BadgeCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard
            let cell = cell as? BadgeCell,
            let badge = streamCellItem.jsonable as? Badge
        else { return }

        if badge.isFeatured,
            let categories = badge.categories
        {
            let title = NSAttributedString(featuredIn: categories,
                font: UIFont.defaultFont(),
                color: .black,
                alignment: .left
                )
            cell.attributedTitle = title
        }
        else {
            let title = badge.name
            cell.title = title
        }

        cell.imageURL = badge.imageURL
        cell.url = badge.url
    }

}
