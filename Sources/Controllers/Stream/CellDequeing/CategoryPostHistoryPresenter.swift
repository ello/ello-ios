////
///  CategoryPostHistoryCellPresenter.swift
//

struct CategoryPostHistoryCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard
            let cell = cell as? CategoryPostHistoryCell,
            let categoryPost = streamCellItem.type.data as? CategoryPost,
            let post = streamCellItem.jsonable as? Post
        else { return }

        var labels: [CategoryPostHistoryCell.Label] = []
        // Featured by ___ in ___
        if let category = categoryPost.category,
            let featuredBy = categoryPost.featuredBy,
            featuredBy.id == categoryPost.submittedBy?.id
        {
            labels.append(.featuredByIn(featuredBy, category))
        }
        // Featured by ___
        else if let featuredBy = categoryPost.featuredBy {
            labels.append(.featuredBy(featuredBy))
        }

        // Posted into ___
        if let category = categoryPost.category, categoryPost.submittedBy?.id =?= post.author?.id {
            labels.append(.postedInto(category))
        }
        // Added to ___ by ___
        else if let category = categoryPost.category, let submittedBy = categoryPost.submittedBy, submittedBy.id != categoryPost.featuredBy?.id {
            labels.append(.addedToBy(category, submittedBy))
        }

        cell.labels = labels
    }

}
