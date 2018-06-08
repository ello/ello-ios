////
///  ProfileHeaderLocationCellSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileHeaderLocationCellSpec: QuickSpec {

    override func spec() {
        describe("ProfileHeaderLocationCell") {
            it("snapshots") {
                let subject = ProfileHeaderLocationCell(frame: CGRect(
                    origin: .zero,
                    size: CGSize(width: 375, height: ProfileHeaderLocationCell.Size.height)
                ))
                subject.location = "Denver, CO"
                expectValidSnapshot(subject, named: "ProfileHeaderLocationCell")
            }
        }
    }
}
