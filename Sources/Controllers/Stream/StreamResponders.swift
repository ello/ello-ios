////
///  StreamResponders.swift
//

import PromiseKit
import FLAnimatedImage


@objc
protocol StreamCellResponder: class {
    func streamCellTapped(cell: UICollectionViewCell)
    func artistInviteSubmissionTapped(cell: UICollectionViewCell)
}

@objc
protocol SimpleStreamResponder: class {
    func showSimpleStream(boxedEndpoint: BoxedElloAPI, title: String)
}

@objc
protocol StreamImageCellResponder: class {
    func imageTapped(cell: StreamImageCell)
}

@objc
protocol StreamPostTappedResponder: class {
    func postTappedInStream(_ cell: UICollectionViewCell)
}

@objc
protocol StreamEditingResponder: class {
    func cellDoubleTapped(cell: UICollectionViewCell, location: CGPoint)
    func cellDoubleTapped(cell: UICollectionViewCell, post: Post, location: CGPoint)
    func cellLongPressed(cell: UICollectionViewCell)
}

typealias StreamCellItemGenerator = () -> [StreamCellItem]
protocol StreamViewDelegate: class {
    func streamViewStreamCellItems(jsonables: [Model], defaultGenerator: StreamCellItemGenerator) -> [StreamCellItem]?
    func streamWillPullToRefresh()
    func streamViewDidScroll(scrollView: UIScrollView)
    func streamViewWillBeginDragging(scrollView: UIScrollView)
    func streamViewDidEndDragging(scrollView: UIScrollView, willDecelerate: Bool)
    func streamViewInfiniteScroll() -> Promise<[Model]>?
}

@objc
protocol CategoryResponder: class {
    func categoryCellTapped(cell: UICollectionViewCell)
    func categoryTapped(_ category: Category)
}

@objc
protocol SelectedCategoryResponder: class {
    func categoriesSelectionChanged(selection: [Category])
}

@objc
protocol ChooseCategoryResponder: class {
    func categoryChosen(_ category: Category)
}

@objc
protocol PromotionalHeaderResponder: class {
    func categorySubscribed(categoryId: String)
}

@objc
protocol UserResponder: class {
    func userTappedAuthor(cell: UICollectionViewCell)
    func userTappedReposter(cell: UICollectionViewCell)
    func userTapped(user: User)
}

@objc
protocol WebLinkResponder: class {
    func webLinkTapped(path: String, type: ElloURIWrapper, data: String?)
}

@objc
protocol StreamSelectionCellResponder: class {
    func streamTapped(_ type: String)
}

@objc
protocol SearchStreamResponder: class {
    func searchFieldChanged(text: String)
}

@objc
protocol AnnouncementCellResponder: class {
    func markAnnouncementAsRead(cell: UICollectionViewCell)
}

@objc
protocol AnnouncementResponder: class {
    func markAnnouncementAsRead(announcement: Announcement)
}

@objc
protocol PostCommentsResponder: class {
    func loadCommentsTapped()
}

@objc
protocol PostTappedResponder: class {
    func postTapped(_ post: Post)
    func postTapped(_ post: Post, scrollToComment: ElloComment?)
    func postTapped(_ post: Post, scrollToComments: Bool)
    func postTapped(postId: String)
}

@objc
protocol UserTappedResponder: class {
    func userTapped(_ user: User)
    func userParamTapped(_ param: String, username: String?)
}

@objc
protocol CreatePostResponder: class {
    func createPost(text: String?, fromController: UIViewController)
    func createComment(_ postId: String, text: String?, fromController: UIViewController)
    func editComment(_ comment: ElloComment, fromController: UIViewController)
    func editPost(_ post: Post, fromController: UIViewController)
}

@objc
protocol InviteResponder: class {
    func onInviteFriends()
    func sendInvite(person: LocalPerson, isOnboarding: Bool, completion: @escaping Block)
}

@objc
protocol PostFeaturedResponder: class {
    func categoryPostTapped(streamCellItem: StreamCellItem, categoryPost: CategoryPost)
}
