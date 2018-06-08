////
///  UserListItemCellPresenterSpec.swift
//

@testable import Ello
import Quick
import Nimble

class UserListItemCellPresenterSpec: QuickSpec {

    override func spec() {
        describe("UserListItemCellPresenter") {
            it("sets the relationship priority and username") {
                let cell: UserListItemCell = UserListItemCell.loadFromNib()
                let user: User = stub([
                    "relationshipPriority": "friend",
                    "username": "sterling_archer"
                    ])
                let item = StreamCellItem(jsonable: user, type: .userListItem)

                UserListItemCellPresenter.configure(cell, streamCellItem: item, streamKind: StreamKind.userStream(userParam: user.id), indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                expect(cell.relationshipControl.relationshipPriority) == RelationshipPriority.following
                expect(cell.usernameLabel.text) == "@sterling_archer"
            }
        }
    }
}
