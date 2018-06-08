////
///  ProfileHeaderStatsCellSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileHeaderStatsCellSpec: QuickSpec {
    override func spec() {
        describe("ProfileHeaderStatsCell") {
            it("snapshots") {
                let subject = ProfileHeaderStatsCell(frame: CGRect(
                    origin: .zero,
                    size: CGSize(width: 375, height: 70)
                    ))
                subject.postsCount = "123"
                subject.followingCount = "4.5K"
                subject.followersCount = "∞"
                subject.lovesCount = "6.8M"
                expectValidSnapshot(subject, named: "ProfileHeaderStatsCell")
            }

            it("highlights button presses") {
                let subject = ProfileHeaderStatsCell(frame: CGRect(
                    origin: .zero,
                    size: CGSize(width: 375, height: 70)
                    ))
                subject.postsCount = "123"
                subject.followingCount = "4.5K"
                subject.followersCount = "∞"
                subject.lovesCount = "6.8M"
                let button: UIButton! = subject.findSubview()
                button.sendActions(for: .touchDown)
                expectValidSnapshot(subject, named: "ProfileHeaderStatsCell-highlighted")
            }
        }
    }
}
