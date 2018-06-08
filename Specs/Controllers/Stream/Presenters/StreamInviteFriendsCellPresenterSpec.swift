////
///  StreamInviteFriendsCellPresenterSpec.swift
//

@testable import Ello
import Quick
import Nimble

class StreamInviteFriendsCellPresenterSpec: QuickSpec {

    override func spec() {
        describe("StreamInviteFriendsCellPresenter") {
            var cell: StreamInviteFriendsCell = StreamInviteFriendsCell.loadFromNib()
            var person: LocalPerson = stub([:])
            var item: StreamCellItem = stub([:])

            beforeEach {
                cell = StreamInviteFriendsCell.loadFromNib()
                cell.inviteCache = InviteCache()
                person = stub(["name": "The Devil", "id": 666, "emails": ["666@gmail.com"]])
                item = StreamCellItem(jsonable: person, type: StreamCellType.inviteFriends)
            }

            it("sets the person and name label correctly") {
                StreamInviteFriendsCellPresenter.configure(cell, streamCellItem: item, streamKind: StreamKind.following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)
                expect(cell.nameLabel.text) == "The Devil"
                expect(cell.person) == person
            }

            it("sets the button text to Invite if not in the cache") {
                expect(cell.inviteButton.titleLabel?.text) == "Invite"
            }

            // not 100% sure why this isn't doing what I expect it to
            it("sets the button text to Re-send if in the cache") {
                cell.inviteCache?.saveInvite(person.identifier)
                StreamInviteFriendsCellPresenter.configure(cell, streamCellItem: item, streamKind: StreamKind.following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)
                expect(cell.inviteButton.titleLabel?.text) == "Re-send"
            }
        }
    }
}
