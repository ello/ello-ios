////
///  ProfileAvatarViewSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileAvatarViewSpec: QuickSpec {
    override func spec() {
        describe("ProfileAvatarView") {
            it("snapshots") {
                let subject = ProfileAvatarView(frame: CGRect(
                    origin: .zero,
                    size: CGSize(width: 375, height: 255)
                ))
                subject.avatarImage = specImage(named: "specs-avatar")!
                expectValidSnapshot(subject, named: "ProfileAvatarView", device: .custom(subject.frame.size))
            }
        }
    }
}

