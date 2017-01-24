////
///  StreamInviteFriendsCellSpec.swift
//

@testable import Ello
import Quick
import Nimble

class StreamInviteFriendsCellSpec: QuickSpec {

    override func spec() {
        let subject: StreamInviteFriendsCell = StreamInviteFriendsCell.loadFromNib()

        describe("initialization") {

            describe("nib") {

                it("IBOutlets are not nil") {
                    expect(subject.inviteButton).notTo(beNil())
                    expect(subject.nameLabel).notTo(beNil())
                }
            }
        }
    }

}
