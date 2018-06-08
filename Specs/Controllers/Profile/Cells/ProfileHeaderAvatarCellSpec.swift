////
///  ProfileHeaderAvatarCellSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileHeaderAvatarCellSpec: QuickSpec {
    override func spec() {
        describe("ProfileHeaderAvatarCell") {
            it("snapshots") {
                let subject = ProfileHeaderAvatarCell(frame: CGRect(
                    origin: .zero,
                    size: CGSize(width: 375, height: 255)
                ))
                subject.avatarImage = specImage(named: "specs-avatar")!
                expectValidSnapshot(subject, named: "ProfileHeaderAvatarCell")
            }
        }
    }
}
