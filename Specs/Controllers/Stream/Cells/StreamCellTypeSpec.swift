////
///  StreamCellTypeSpec.swift
//

@testable import Ello
import Quick
import Nimble


class StreamCellTypeSpec: QuickSpec {

    override func spec() {
        describe("StreamCellType") {

            let expectations: [(
                String,
                type: StreamCellType,
                name: String,
                selectable: Bool,
                classType: AnyClass,
                oneColumnHeight: CGFloat?,
                multiColumnHeight: CGFloat?,
                isFullWidth: Bool,
                collapsable: Bool)] = [
                    ("CategoryCard", type: .categoryCard, name: CategoryCardCell.reuseIdentifier, selectable: true, classType: CategoryCardCell.self, oneColumnHeight: nil, multiColumnHeight: nil, isFullWidth: false, collapsable: false),
                    ("SelectableCategoryCard", type: .selectableCategoryCard, name: CategoryCardCell.selectableReuseIdentifier, selectable: true,classType: CategoryCardCell.self, oneColumnHeight: nil, multiColumnHeight: nil, isFullWidth: false, collapsable: false),
                    ("CategoryList", type: .categoryList, name: CategoryListCell.reuseIdentifier, selectable: false, classType: CategoryListCell.self, oneColumnHeight: 45, multiColumnHeight: 45, isFullWidth: true, collapsable: false),
                    ("CategoryPromotionalHeader", type: .categoryPromotionalHeader, name: CategoryHeaderCell.reuseIdentifier, selectable: false,classType: CategoryHeaderCell.self, oneColumnHeight: 150, multiColumnHeight: 150, isFullWidth: true, collapsable: false),
                    ("CommentHeader", type: .commentHeader, name: StreamHeaderCell.reuseIdentifier, selectable: false,classType: StreamHeaderCell.self, oneColumnHeight: 60, multiColumnHeight: 60, isFullWidth: false, collapsable: false),
                    ("CreateComment", type: .createComment, name: StreamCreateCommentCell.reuseIdentifier, selectable: true,classType: StreamCreateCommentCell.self, oneColumnHeight: 75, multiColumnHeight: 75, isFullWidth: true, collapsable: false),
                    ("Embed", type: .embed(data: nil), name: StreamEmbedCell.reuseEmbedIdentifier, selectable: false,classType: StreamEmbedCell.self, oneColumnHeight: 0, multiColumnHeight: 0, isFullWidth: false, collapsable: true),
                    ("Footer", type: .footer, name: StreamFooterCell.reuseIdentifier, selectable: false,classType: StreamFooterCell.self, oneColumnHeight: 44, multiColumnHeight: 44, isFullWidth: false, collapsable: false),
                    ("Header", type: .header, name: StreamHeaderCell.reuseIdentifier, selectable: true,classType: StreamHeaderCell.self, oneColumnHeight: 70, multiColumnHeight: 60, isFullWidth: false, collapsable: false),
                    ("Image", type: .image(data: nil), name: StreamImageCell.reuseIdentifier, selectable: false,classType: StreamImageCell.self, oneColumnHeight: 0, multiColumnHeight: 0, isFullWidth: false, collapsable: true),
                    ("InviteFriends", type: .inviteFriends, name: StreamInviteFriendsCell.reuseIdentifier, selectable: true,classType: StreamInviteFriendsCell.self, oneColumnHeight: 60, multiColumnHeight: 60, isFullWidth: true, collapsable: false),
                    ("OnboardingInviteFriends", type: .onboardingInviteFriends, name: StreamInviteFriendsCell.reuseIdentifier, selectable: true,classType: StreamInviteFriendsCell.self, oneColumnHeight: 60, multiColumnHeight: 60, isFullWidth: true, collapsable: false),
                    ("EmptyStream", type: .emptyStream(height: 282), name: EmptyStreamCell.reuseEmbedIdentifier, selectable: false,classType: EmptyStreamCell.self, oneColumnHeight: 282, multiColumnHeight: 282, isFullWidth: true, collapsable: false),
                    ("NoPosts", type: .noPosts, name: NoPostsCell.reuseIdentifier, selectable: false,classType: NoPostsCell.self, oneColumnHeight: 215, multiColumnHeight: 215, isFullWidth: true, collapsable: false),
                    ("Notification", type: .notification, name: NotificationCell.reuseIdentifier, selectable: true,classType: NotificationCell.self, oneColumnHeight: 117, multiColumnHeight: 60, isFullWidth: true, collapsable: false),
                    ("PagePromotionalHeader", type: .pagePromotionalHeader, name: CategoryHeaderCell.reuseIdentifier, selectable: false,classType: CategoryHeaderCell.self, oneColumnHeight: 150, multiColumnHeight: 150, isFullWidth: true, collapsable: false),
                    ("Placeholder", type: .placeholder, name: "Placeholder", selectable: false,classType: UICollectionViewCell.self, oneColumnHeight: 0, multiColumnHeight: 0, isFullWidth: false, collapsable: false),
                    ("ProfileHeader", type: .profileHeader, name: ProfileHeaderCell.reuseIdentifier, selectable: false,classType: ProfileHeaderCell.self, oneColumnHeight: 0, multiColumnHeight: 0, isFullWidth: true, collapsable: false),
                    ("ProfileHeaderGhost", type: .profileHeaderGhost, name: ProfileHeaderGhostCell.reuseIdentifier, selectable: false,classType: ProfileHeaderGhostCell.self, oneColumnHeight: 0, multiColumnHeight: 0, isFullWidth: true, collapsable: false),
                    ("Search", type: .search(placeholder: "cats"), name: SearchStreamCell.reuseIdentifier, selectable: false,classType: SearchStreamCell.self, oneColumnHeight: 68, multiColumnHeight: 68, isFullWidth: true, collapsable: false),
                    ("SeeMoreComments", type: .seeMoreComments, name: StreamSeeMoreCommentsCell.reuseIdentifier, selectable: true,classType: StreamSeeMoreCommentsCell.self, oneColumnHeight: 60, multiColumnHeight: 60, isFullWidth: true, collapsable: false),
                    ("Spacer", type: .spacer(height: 50), name: "StreamSpacerCell", selectable: false,classType: UICollectionViewCell.self, oneColumnHeight: 50, multiColumnHeight: 50, isFullWidth: false, collapsable: false),
                    ("FullWidthSpacer", type: .fullWidthSpacer(height: 125), name: "StreamSpacerCell", selectable: false,classType: UICollectionViewCell.self, oneColumnHeight: 125, multiColumnHeight: 125, isFullWidth: true, collapsable: false),
                    ("StreamLoading", type: .streamLoading, name: StreamLoadingCell.reuseIdentifier, selectable: false,classType: StreamLoadingCell.self, oneColumnHeight: 50, multiColumnHeight: 50, isFullWidth: true, collapsable: false),
                    ("Text", type: .text(data: nil), name: StreamTextCell.reuseIdentifier, selectable: false,classType: StreamTextCell.self, oneColumnHeight: 0, multiColumnHeight: 0, isFullWidth: false, collapsable: true),
                    ("TextHeader", type: .textHeader(nil), name: TextHeaderCell.reuseIdentifier, selectable: false,classType: TextHeaderCell.self, oneColumnHeight: 75, multiColumnHeight: 75, isFullWidth: true, collapsable: false),
                    ("Toggle", type: .toggle, name: StreamToggleCell.reuseIdentifier, selectable: true,classType: StreamToggleCell.self, oneColumnHeight: 40, multiColumnHeight: 40, isFullWidth: false, collapsable: false),
                    ("Unknown", type: .unknown, name: "StreamUnknownCell", selectable: false,classType: UICollectionViewCell.self, oneColumnHeight: 0, multiColumnHeight: 0, isFullWidth: false, collapsable: false),
                    ("UserAvatars", type: .userAvatars, name: UserAvatarsCell.reuseIdentifier, selectable: false,classType: UserAvatarsCell.self, oneColumnHeight: 50, multiColumnHeight: 50, isFullWidth: true, collapsable: false),
                    ("UserListItem", type: .userListItem, name: UserListItemCell.reuseIdentifier, selectable: true,classType: UserListItemCell.self, oneColumnHeight: 85, multiColumnHeight: 85, isFullWidth: true, collapsable: false),
            ]

            for (desc, type, name, selectable, classType, oneColumnHeight, multiColumnHeight, isFullWidth, collapsable) in expectations {

                it("\(desc) returns correct values"){
                    // TODO: figure out a way to test for confgure
                    expect(type.reuseIdentifier) == name
                    expect(type.selectable) == selectable
                    expect(type.classType) === classType
                    if let oneColumnHeight = oneColumnHeight {
                        expect(type.oneColumnHeight) == oneColumnHeight
                    }
                    if let multiColumnHeight = multiColumnHeight {
                        expect(type.multiColumnHeight) == multiColumnHeight
                    }
                    expect(type.isFullWidth) == isFullWidth
                    expect(type.collapsable) == collapsable
                }
            }
        }
    }
}
