////
///  ProfileHeaderTotalCountAndBadgesCellSpec.swift
//

@testable import Ello
import Quick
import Nimble
import Nimble_Snapshots


class ProfileHeaderTotalCountAndBadgesCellSpec: QuickSpec {
    override func spec() {
        describe("ProfileHeaderTotalCountAndBadgesCell") {
            var badge: Badge!
            beforeEach {
                badge = Badge.lookup(slug: "featured")
            }

            it("only badges") {
                let subject = ProfileHeaderTotalCountAndBadgesCell(
                    frame: CGRect(
                        origin: .zero,
                        size: CGSize(width: 375, height: 60)
                    )
                )
                subject.update(count: "", badges: [badge])
                expectValidSnapshot(subject, named: "ProfileHeaderTotalCountAndBadgesCell-badges")
            }

            it("only total count") {
                let subject = ProfileHeaderTotalCountAndBadgesCell(
                    frame: CGRect(
                        origin: .zero,
                        size: CGSize(width: 375, height: 60)
                    )
                )
                subject.update(count: "2.3M", badges: [])
                expectValidSnapshot(subject, named: "ProfileHeaderTotalCountAndBadgesCell-count")
            }

            it("badges and total count") {
                let subject = ProfileHeaderTotalCountAndBadgesCell(
                    frame: CGRect(
                        origin: .zero,
                        size: CGSize(width: 375, height: 60)
                    )
                )
                subject.update(count: "2.3M", badges: [badge])
                expectValidSnapshot(subject, named: "ProfileHeaderTotalCountAndBadgesCell-both")
            }

            it("only badges half-width") {
                let subject = ProfileHeaderTotalCountAndBadgesCell(
                    frame: CGRect(
                        origin: .zero,
                        size: CGSize(width: 187, height: 60)
                    )
                )
                subject.update(count: "", badges: [badge])
                expectValidSnapshot(
                    subject,
                    named: "ProfileHeaderTotalCountAndBadgesCell-badges-halfwidth"
                )
            }

            it("only total count half-width") {
                let subject = ProfileHeaderTotalCountAndBadgesCell(
                    frame: CGRect(
                        origin: .zero,
                        size: CGSize(width: 187, height: 60)
                    )
                )
                subject.update(count: "2.3M", badges: [])
                expectValidSnapshot(
                    subject,
                    named: "ProfileHeaderTotalCountAndBadgesCell-count-halfwidth"
                )
            }
        }
    }
}
