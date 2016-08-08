////
///  StreamCellType.swift
//

import Foundation

public typealias CellConfigClosure = (
    cell: UICollectionViewCell,
    streamCellItem: StreamCellItem,
    streamKind: StreamKind,
    indexPath: NSIndexPath,
    currentUser: User?
) -> Void

// MARK: Equatable
public func == (lhs: StreamCellType, rhs: StreamCellType) -> Bool {
    return lhs.identifier == rhs.identifier
}

public enum StreamCellType: Equatable {
    case Category
    case CategoryCard
    case SeeAllCategories
    case CategoryList
    case ColumnToggle
    case CommentHeader
    case Conversation
    case ConversationMemberSelection
    case CreateComment
    case Embed(data: Regionable?)
    case FollowAll(data: FollowAllCounts?)
    case Footer
    case Header
    case Image(data: Regionable?)
    case InviteFriends
    case Notification
    case OnboardingHeader(data: (String, String)?)
    case Placeholder
    case ProfileHeader
    case SeeMoreComments
    case Spacer(height: CGFloat)
    case FullWidthSpacer(height: CGFloat)
    case StreamLoading
    case Text(data: Regionable?)
    case Toggle
    case Unknown
    case UserAvatars
    case UserListItem

    public enum PlaceholderType {
        case CategoryList
        case PeopleToFollow

        case ProfileHeader
        case ProfilePosts

        case PostCommentBar
        case PostComments
        case PostHeader
        case PostLovers
        case PostReposters
        case PostSocialPadding
    }

    static let all = [
        Category, SeeAllCategories,
        CategoryCard,
        CategoryList,
        ColumnToggle,
        CommentHeader,
        Conversation,
        ConversationMemberSelection,
        CreateComment,
        Embed(data: nil),
        FollowAll(data: nil),
        Footer,
        Header,
        Image(data: nil),
        InviteFriends,
        Notification,
        OnboardingHeader(data: nil),
        ProfileHeader,
        SeeMoreComments,
        Spacer(height: 0.0),
        FullWidthSpacer(height: 0.0),
        Placeholder,
        StreamLoading,
        Text(data: nil),
        Toggle,
        Unknown,
        UserAvatars,
        UserListItem
    ]

    public var data: Any? {
        switch self {
        case let Embed(data): return data
        case let FollowAll(data): return data
        case let Image(data): return data
        case let OnboardingHeader(data): return data
        case let Text(data): return data
        default: return nil
        }
    }

    // this is just stupid...
    public var identifier: String {
        return "\(self)"
    }

    public var name: String {
        switch self {
        case Category, SeeAllCategories: return CategoryCell.reuseIdentifier
        case CategoryCard: return CategoryCardCell.reuseIdentifier
        case CategoryList: return CategoryListCell.reuseIdentifier
        case ColumnToggle: return ColumnToggleCell.reuseIdentifier
        case CommentHeader, Header: return StreamHeaderCell.reuseIdentifier
        case Conversation: return ConversationCell.reuseIdentifier
        case ConversationMemberSelection: return ConversationMemberSelectionCell.reuseIdentifier
        case CreateComment: return StreamCreateCommentCell.reuseIdentifier
        case Embed: return StreamEmbedCell.reuseEmbedIdentifier
        case FollowAll: return FollowAllCell.reuseIdentifier
        case Footer: return StreamFooterCell.reuseIdentifier
        case Image: return StreamImageCell.reuseIdentifier
        case InviteFriends: return StreamInviteFriendsCell.reuseIdentifier
        case Notification: return NotificationCell.reuseIdentifier
        case OnboardingHeader: return OnboardingHeaderCell.reuseIdentifier
        case Placeholder: return "Placeholder"
        case ProfileHeader: return ProfileHeaderCell.reuseIdentifier
        case SeeMoreComments: return StreamSeeMoreCommentsCell.reuseIdentifier
        case Spacer: return "StreamSpacerCell"
        case FullWidthSpacer: return "StreamSpacerCell"
        case StreamLoading: return StreamLoadingCell.reuseIdentifier
        case Text: return StreamTextCell.reuseIdentifier
        case Toggle: return StreamToggleCell.reuseIdentifier
        case Unknown: return "StreamUnknownCell"
        case UserAvatars: return UserAvatarsCell.reuseIdentifier
        case UserListItem: return UserListItemCell.reuseIdentifier
        }
    }

    public var selectable: Bool {
        switch self {
        case Category,
             CategoryCard,
             Conversation,
             SeeAllCategories,
             CreateComment,
             Header,
             InviteFriends,
             Notification,
             SeeMoreComments,
             Toggle,
             UserListItem:
            return true
        default: return false
        }
    }

    public var configure: CellConfigClosure {
        switch self {
        case Category: return CategoryCellPresenter.configure
        case CategoryCard: return CategoryCardCellPresenter.configure
        case Conversation: return ConversationCellPresenter.configure
        case ConversationMemberSelection: return ConversationMemberSelectionCellPresenter.configure
        case SeeAllCategories: return SeeAllCategoriesCellPresenter.configure
        case CategoryList: return CategoryListCellPresenter.configure
        case ColumnToggle: return ColumnToggleCellPresenter.configure
        case CommentHeader, Header: return StreamHeaderCellPresenter.configure
        case CreateComment: return StreamCreateCommentCellPresenter.configure
        case Embed: return StreamEmbedCellPresenter.configure
        case FollowAll: return FollowAllCellPresenter.configure
        case Footer: return StreamFooterCellPresenter.configure
        case Image: return StreamImageCellPresenter.configure
        case InviteFriends: return StreamInviteFriendsCellPresenter.configure
        case Notification: return NotificationCellPresenter.configure
        case OnboardingHeader: return OnboardingHeaderCellPresenter.configure
        case ProfileHeader: return ProfileHeaderCellPresenter.configure
        case Spacer: return { (cell, _, _, _, _) in cell.backgroundColor = .whiteColor() }
        case FullWidthSpacer: return { (cell, _, _, _, _) in cell.backgroundColor = .whiteColor() }
        case StreamLoading: return StreamLoadingCellPresenter.configure
        case Text: return StreamTextCellPresenter.configure
        case Toggle: return StreamToggleCellPresenter.configure
        case Unknown: return ProfileHeaderCellPresenter.configure
        case UserAvatars: return UserAvatarsCellPresenter.configure
        case UserListItem: return UserListItemCellPresenter.configure
        default: return { _ in }
        }
    }

    public var classType: UICollectionViewCell.Type {
        switch self {
        case Category, SeeAllCategories: return CategoryCell.self
        case CategoryCard: return CategoryCardCell.self
        case CategoryList: return CategoryListCell.self
        case ColumnToggle: return ColumnToggleCell.self
        case CommentHeader, Header: return StreamHeaderCell.self
        case Conversation: return ConversationCell.self
        case ConversationMemberSelection: return ConversationMemberSelectionCell.self
        case CreateComment: return StreamCreateCommentCell.self
        case Embed: return StreamEmbedCell.self
        case FollowAll: return FollowAllCell.self
        case Footer: return StreamFooterCell.self
        case Image: return StreamImageCell.self
        case InviteFriends: return StreamInviteFriendsCell.self
        case Notification: return NotificationCell.self
        case OnboardingHeader: return OnboardingHeaderCell.self
        case Placeholder: return UICollectionViewCell.self
        case ProfileHeader: return ProfileHeaderCell.self
        case SeeMoreComments: return StreamSeeMoreCommentsCell.self
        case StreamLoading: return StreamLoadingCell.self
        case Text: return StreamTextCell.self
        case Toggle: return StreamToggleCell.self
        case Unknown, Spacer, FullWidthSpacer: return UICollectionViewCell.self
        case UserAvatars: return UserAvatarsCell.self
        case UserListItem: return UserListItemCell.self
        }
    }

    public var oneColumnHeight: CGFloat {
        switch self {
        case Category, SeeAllCategories:
            return 56
        case CategoryCard:
            return 110
        case CategoryList:
            return 66
        case ColumnToggle:
            return 40
        case CommentHeader,
             InviteFriends,
             SeeMoreComments:
            return 60
        case Conversation:
            return 50
        case CreateComment,
             FollowAll:
            return 75
        case Footer:
            return 44
        case Header:
            return 70
        case Notification:
            return 117
        case OnboardingHeader:
            return 120
        case let Spacer(height):
            return height
        case let FullWidthSpacer(height):
            return height
        case StreamLoading,
             UserAvatars:
            return 50
        case Toggle:
            return 40
        case UserListItem, ConversationMemberSelection:
            return 85
        default: return 0
        }
    }

    public var multiColumnHeight: CGFloat {
        switch self {
        case Header,
            Notification:
            return 60
        default:
            return oneColumnHeight
        }
    }

    public var isFullWidth: Bool {
        switch self {
        case Category,
             SeeAllCategories,
             CategoryList,
             ColumnToggle,
             Conversation,
             ConversationMemberSelection,
             CreateComment,
             FollowAll,
             FullWidthSpacer,
             InviteFriends,
             OnboardingHeader,
             ProfileHeader,
             SeeMoreComments,
             StreamLoading,
             UserAvatars,
             UserListItem:
            return true
        case CategoryCard,
             CommentHeader,
             Embed,
             Footer,
             Header,
             Image,
             Notification,
             Placeholder,
             Spacer,
             Text,
             Toggle,
             Unknown:
            return false
        }
    }

    public var collapsable: Bool {
        switch self {
        case Image, Text, Embed: return true
        default: return false
        }
    }

    static func registerAll(collectionView: UICollectionView) {
        let noNibTypes = [
            Category,
            SeeAllCategories,
            CategoryCard,
            CategoryList,
            CreateComment,
            Conversation,
            ConversationMemberSelection,
            FollowAll(data: nil),
            Notification,
            Placeholder,
            OnboardingHeader(data: nil),
            Spacer(height: 0.0),
            FullWidthSpacer(height: 0.0),
            StreamLoading,
            Unknown
        ]
        for type in all {
            if noNibTypes.indexOf(type) != nil {
                collectionView.registerClass(type.classType, forCellWithReuseIdentifier: type.name)
            } else {
                let nib = UINib(nibName: type.name, bundle: NSBundle(forClass: type.classType))
                collectionView.registerNib(nib, forCellWithReuseIdentifier: type.name)
            }
        }
    }
}
