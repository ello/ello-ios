////
///  PostFeaturedByCellPresenter.swift
//

struct PostFeaturedByCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard
            let cell = cell as? PostFeaturedByCell,
            let post = streamCellItem.jsonable as? Post,
            let featuredBy = post.featuredBy
        else { return }

        cell.text = "\(InterfaceString.Post.FeaturedBy) \(featuredBy.atName)"
    }
}
