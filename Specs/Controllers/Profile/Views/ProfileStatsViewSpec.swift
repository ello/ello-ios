////
///  ProfileStatsViewSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileStatsViewSpec: QuickSpec {
    override func spec() {
        describe("ProfileStatsView") {
            it("snapshots") {
                let subject = ProfileStatsView(frame: CGRect(
                    origin: .zero,
                    size: CGSize(width: 375, height: 70)
                    ))
                subject.postsCount = "123"
                subject.followingCount = "4.5K"
                subject.followersCount = "∞"
                subject.lovesCount = "6.8M"
                expectValidSnapshot(subject, named: "ProfileStatsView")
            }

            it("highlights button presses") {
                let subject = ProfileStatsView(frame: CGRect(
                    origin: .zero,
                    size: CGSize(width: 375, height: 70)
                    ))
                subject.postsCount = "123"
                subject.followingCount = "4.5K"
                subject.followersCount = "∞"
                subject.lovesCount = "6.8M"
                let button: UIButton! = subject.findSubview()
                button.sendActions(for: .touchDown)
                expectValidSnapshot(subject, named: "ProfileStatsView-highlighted")
            }
        }
    }
}
