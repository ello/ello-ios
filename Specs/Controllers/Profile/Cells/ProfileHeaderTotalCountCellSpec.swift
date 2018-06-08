////
///  ProfileHeaderTotalCountCellSpec.swift
//

@testable import Ello
import Quick
import Nimble
import Nimble_Snapshots


class ProfileHeaderTotalCountCellSpec: QuickSpec {
    override func spec() {
        describe("ProfileHeaderTotalCountCell") {
            it("snapshots") {
                let subject = ProfileHeaderTotalCountCell(frame: CGRect(
                    origin: .zero,
                    size: CGSize(width: 375, height: 60)
                ))
                subject.count = "2.3M"
                expectValidSnapshot(subject, named: "ProfileHeaderTotalCountCell")
            }

            it("half-width") {
                let subject = ProfileHeaderTotalCountCell(frame: CGRect(
                    origin: .zero,
                    size: CGSize(width: 187, height: 60)
                ))
                subject.count = "2.3M"
                expectValidSnapshot(subject, named: "ProfileHeaderTotalCountCell_halfwidth")
            }
        }
    }
}
