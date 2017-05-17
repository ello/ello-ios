////
///  StreamCellType.swift
//

typealias CellConfigClosure = (
    _ cell: UICollectionViewCell,
    _ streamCellItem: StreamCellItem,
    _ streamKind: StreamKind,
    _ indexPath: IndexPath,
    _ currentUser: User?
) -> Void

// MARK: Equatable
func == (lhs: StreamCellType, rhs: StreamCellType) -> Bool {
    return lhs.equalityIdentifier == rhs.equalityIdentifier
}

enum StreamCellType: Equatable {
    case announcement
    case badge
    case categoryCard
    case selectableCategoryCard
    case categoryList
    case categoryPromotionalHeader
    case commentHeader
    case createComment
    case editorial(Editorial.Kind)
    case embed(data: Regionable?)
    case footer
    case header
    case image(data: Regionable?)
    case inviteFriends
    case onboardingInviteFriends
    case emptyStream(height: CGFloat)
    case loadMoreComments
    case noPosts
    case notification
    case pagePromotionalHeader
    case placeholder
    case profileHeader
    case profileHeaderGhost
    case search(placeholder: String)
    case seeMoreComments
    case spacer(height: CGFloat)
    case fullWidthSpacer(height: CGFloat)
    case streamLoading
    case text(data: Regionable?)
    case textHeader(NSAttributedString?)
    case toggle
    case unknown
    case userAvatars
    case userListItem

    enum PlaceholderType {
        case categoryList
        case categoryHeader
        case categoryPosts
        case peopleToFollow

        case announcements
        case notifications

        case editorials

        case profileHeader
        case profilePosts

        case postCommentBar
        case postComments
        case postLoadingComments
        case postHeader
        case postLovers
        case postReposters
        case postSocialPadding
        case postRelatedPosts

        case cellNotFound
    }

    static let all: [StreamCellType] = [
        .badge,
        .categoryCard,
        .categoryPromotionalHeader,
        .selectableCategoryCard,
        .categoryList,
        .commentHeader,
        .createComment,
        .embed(data: nil),
        .emptyStream(height: 282),
        .footer,
        .header,
        .image(data: nil),
        .inviteFriends,
        .onboardingInviteFriends,
        .loadMoreComments,
        .noPosts,
        .notification,
        .pagePromotionalHeader,
        .announcement,
        .editorial(.external),
        .editorial(.postStream),
        .editorial(.post),
        .editorial(.invite),
        .editorial(.join),
        .profileHeader,
        .profileHeaderGhost,
        .search(placeholder: ""),
        .seeMoreComments,
        .spacer(height: 0.0),
        .fullWidthSpacer(height: 0.0),
        .placeholder,
        .streamLoading,
        .text(data: nil),
        .textHeader(nil),
        .toggle,
        .unknown,
        .userAvatars,
        .userListItem
    ]

    var data: Any? {
        switch self {
        case let .embed(data): return data
        case let .image(data): return data
        case let .text(data): return data
        case let .textHeader(data): return data
        default: return nil
        }
    }

    // this is just stupid...
    var equalityIdentifier: String {
        return "\(self)"
    }

    var reuseIdentifier: String {
        switch self {
        case .badge: return BadgeCell.reuseIdentifier
        case .categoryCard: return CategoryCardCell.reuseIdentifier
        case .categoryPromotionalHeader, .pagePromotionalHeader: return CategoryHeaderCell.reuseIdentifier
        case .selectableCategoryCard: return CategoryCardCell.selectableReuseIdentifier
        case .categoryList: return CategoryListCell.reuseIdentifier
        case .commentHeader, .header: return StreamHeaderCell.reuseIdentifier
        case .createComment: return StreamCreateCommentCell.reuseIdentifier
        case .embed: return StreamEmbedCell.reuseEmbedIdentifier
        case .emptyStream: return EmptyStreamCell.reuseEmbedIdentifier
        case .footer: return StreamFooterCell.reuseIdentifier
        case .image: return StreamImageCell.reuseIdentifier
        case .inviteFriends, .onboardingInviteFriends: return StreamInviteFriendsCell.reuseIdentifier
        case .loadMoreComments: return StreamLoadMoreCommentsCell.reuseIdentifier
        case .noPosts: return NoPostsCell.reuseIdentifier
        case .notification: return NotificationCell.reuseIdentifier
        case .placeholder: return "Placeholder"
        case .announcement: return AnnouncementCell.reuseIdentifier
        case let .editorial(kind): return kind.reuseIdentifier
        case .profileHeader: return ProfileHeaderCell.reuseIdentifier
        case .profileHeaderGhost: return ProfileHeaderGhostCell.reuseIdentifier
        case .search: return SearchStreamCell.reuseIdentifier
        case .seeMoreComments: return StreamSeeMoreCommentsCell.reuseIdentifier
        case .spacer: return "StreamSpacerCell"
        case .fullWidthSpacer: return "StreamSpacerCell"
        case .streamLoading: return StreamLoadingCell.reuseIdentifier
        case .text: return StreamTextCell.reuseIdentifier
        case .textHeader: return TextHeaderCell.reuseIdentifier
        case .toggle: return StreamToggleCell.reuseIdentifier
        case .unknown: return "StreamUnknownCell"
        case .userAvatars: return UserAvatarsCell.reuseIdentifier
        case .userListItem: return UserListItemCell.reuseIdentifier
        }
    }

    var selectable: Bool {
        switch self {
        case .announcement,
             .badge,
             .categoryCard,
             .createComment,
             .editorial,
             .header,
             .inviteFriends,
             .loadMoreComments,
             .notification,
             .onboardingInviteFriends,
             .seeMoreComments,
             .selectableCategoryCard,
             .toggle,
             .userListItem:
            return true
        default: return false
        }
    }

    var configure: CellConfigClosure {
        switch self {
        case .badge: return BadgeCellPresenter.configure
        case .categoryCard: return CategoryCardCellPresenter.configure
        case .categoryPromotionalHeader: return CategoryHeaderCellPresenter.configure
        case .selectableCategoryCard: return CategoryCardCellPresenter.configure
        case .categoryList: return CategoryListCellPresenter.configure
        case .commentHeader, .header: return StreamHeaderCellPresenter.configure
        case .createComment: return StreamCreateCommentCellPresenter.configure
        case .emptyStream: return EmptyStreamCellPresenter.configure
        case .embed: return StreamEmbedCellPresenter.configure
        case .footer: return StreamFooterCellPresenter.configure
        case .image: return StreamImageCellPresenter.configure
        case .inviteFriends, .onboardingInviteFriends: return StreamInviteFriendsCellPresenter.configure
        case .noPosts: return NoPostsCellPresenter.configure
        case .notification: return NotificationCellPresenter.configure
        case .pagePromotionalHeader: return PagePromotionalHeaderCellPresenter.configure
        case .announcement: return AnnouncementCellPresenter.configure
        case .editorial: return EditorialCellPresenter.configure
        case .profileHeader: return ProfileHeaderCellPresenter.configure
        case .search: return SearchStreamCellPresenter.configure
        case .spacer: return { (cell, _, _, _, _) in cell.backgroundColor = .white }
        case .fullWidthSpacer: return { (cell, _, _, _, _) in cell.backgroundColor = .white }
        case .streamLoading: return StreamLoadingCellPresenter.configure
        case .text: return StreamTextCellPresenter.configure
        case .textHeader: return TextHeaderCellPresenter.configure
        case .toggle: return StreamToggleCellPresenter.configure
        case .userAvatars: return UserAvatarsCellPresenter.configure
        case .userListItem: return UserListItemCellPresenter.configure
        default: return { _ in }
        }
    }

    var classType: UICollectionViewCell.Type {
        switch self {
        case .badge: return BadgeCell.self
        case .categoryCard: return CategoryCardCell.self
        case .categoryPromotionalHeader, .pagePromotionalHeader: return CategoryHeaderCell.self
        case .selectableCategoryCard: return CategoryCardCell.self
        case .categoryList: return CategoryListCell.self
        case .commentHeader, .header: return StreamHeaderCell.self
        case .createComment: return StreamCreateCommentCell.self
        case .embed: return StreamEmbedCell.self
        case .emptyStream: return EmptyStreamCell.self
        case .footer: return StreamFooterCell.self
        case .image: return StreamImageCell.self
        case .inviteFriends, .onboardingInviteFriends: return StreamInviteFriendsCell.self
        case .loadMoreComments: return StreamLoadMoreCommentsCell.self
        case .noPosts: return NoPostsCell.self
        case .notification: return NotificationCell.self
        case .placeholder: return UICollectionViewCell.self
        case .announcement: return AnnouncementCell.self
        case let .editorial(kind): return kind.classType
        case .profileHeader: return ProfileHeaderCell.self
        case .profileHeaderGhost: return ProfileHeaderGhostCell.self
        case .search: return SearchStreamCell.self
        case .seeMoreComments: return StreamSeeMoreCommentsCell.self
        case .streamLoading: return StreamLoadingCell.self
        case .text: return StreamTextCell.self
        case .textHeader: return TextHeaderCell.self
        case .toggle: return StreamToggleCell.self
        case .unknown, .spacer, .fullWidthSpacer: return UICollectionViewCell.self
        case .userAvatars: return UserAvatarsCell.self
        case .userListItem: return UserListItemCell.self
        }
    }

    var oneColumnHeight: CGFloat {
        switch self {
        case .badge:
            return 64
        case .categoryPromotionalHeader, .pagePromotionalHeader:
            return 150
        case .categoryCard, .selectableCategoryCard:
            let width = UIWindow.windowWidth()
            let aspect = CategoryCardCell.Size.aspect
            return ceil(width / aspect)
        case .categoryList:
            return CategoryListCell.Size.height
        case .commentHeader,
             .inviteFriends,
             .onboardingInviteFriends,
             .seeMoreComments:
            return 60
        case .createComment:
            return 75
        case let .emptyStream(height):
            return height
        case .footer:
            return 44
        case .header:
            return 70
        case .loadMoreComments:
            return StreamLoadMoreCommentsCell.Size.height
        case .noPosts:
            return 215
        case .notification:
            return 117
        case .editorial:
            let width = UIWindow.windowWidth()
            let aspect = EditorialCell.Size.aspect
            return ceil(width / aspect)
        case .announcement:
            return 200
        case let .spacer(height):
            return height
        case let .fullWidthSpacer(height):
            return height
        case .search:
            return 68
        case .streamLoading,
             .userAvatars:
            return 50
        case .textHeader:
            return 75
        case .toggle:
            return 40
        case .userListItem:
            return 85
        default: return 0
        }
    }

    var multiColumnHeight: CGFloat {
        switch self {
        case .categoryCard, .selectableCategoryCard:
            let windowWidth = UIWindow.windowWidth()
            let columnCount = CGFloat(Window.columnCountFor(width: windowWidth))
            let columnSpacing: CGFloat = 1
            let width = (UIWindow.windowWidth() - columnSpacing * (columnCount - 1)) / columnCount
            let aspect = CategoryCardCell.Size.aspect
            return ceil(width / aspect)
        case .header,
            .notification:
            return 60
        default:
            return oneColumnHeight
        }
    }

    var isFullWidth: Bool {
        switch self {
        case .badge,
             .categoryPromotionalHeader,
             .categoryList,
             .createComment,
             .fullWidthSpacer,
             .inviteFriends,
             .onboardingInviteFriends,
             .emptyStream,
             .loadMoreComments,
             .noPosts,
             .notification,
             .pagePromotionalHeader,
             .announcement,
             .editorial,
             .profileHeader,
             .profileHeaderGhost,
             .search,
             .seeMoreComments,
             .streamLoading,
             .textHeader,
             .userAvatars,
             .userListItem:
            return true
        case .categoryCard,
             .selectableCategoryCard,
             .commentHeader,
             .embed,
             .footer,
             .header,
             .image,
             .placeholder,
             .spacer,
             .text,
             .toggle,
             .unknown:
            return false
        }
    }

    var collapsable: Bool {
        switch self {
        case .image, .text, .embed: return true
        default: return false
        }
    }

    static func registerAll(_ collectionView: UICollectionView) {
        let noNibTypes: [StreamCellType] = [
            .badge,
            .categoryCard,
            .categoryPromotionalHeader,
            .selectableCategoryCard,
            .categoryList,
            .createComment,
            .emptyStream(height: 282),
            .fullWidthSpacer(height: 0.0),
            .loadMoreComments,
            .notification,
            .pagePromotionalHeader,
            .announcement,
            .editorial(.external),
            .editorial(.postStream),
            .editorial(.post),
            .editorial(.invite),
            .editorial(.join),
            .placeholder,
            .profileHeader,
            .profileHeaderGhost,
            .search(placeholder: ""),
            .spacer(height: 0.0),
            .text(data: nil),
            .streamLoading,
            .textHeader(nil),
            .unknown,
        ]
        for type in all {
            if noNibTypes.index(of: type) != nil {
                collectionView.register(type.classType, forCellWithReuseIdentifier: type.reuseIdentifier)
            } else {
                let nib = UINib(nibName: type.reuseIdentifier, bundle: Bundle(for: type.classType))
                collectionView.register(nib, forCellWithReuseIdentifier: type.reuseIdentifier)
            }
        }
    }
}
