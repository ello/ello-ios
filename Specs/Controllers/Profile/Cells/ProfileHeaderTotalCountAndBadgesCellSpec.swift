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
            it("snapshots") {
                let subject = ProfileHeaderTotalCountAndBadgesCell(frame: CGRect(
                    origin: .zero,
                    size: CGSize(width: 375, height: 60)
                ))
                subject.count = "2.3M"
                expectValidSnapshot(subject, named: "ProfileHeaderTotalCountAndBadgesCell")
            }

            it("half-width") {
                let subject = ProfileHeaderTotalCountAndBadgesCell(frame: CGRect(
                    origin: .zero,
                    size: CGSize(width: 187, height: 60)
                ))
                subject.count = "2.3M"
                expectValidSnapshot(subject, named: "ProfileHeaderTotalCountAndBadgesCell_halfwidth")
            }
        }
    }
}
