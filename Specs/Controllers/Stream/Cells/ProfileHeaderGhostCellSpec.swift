////
///  ProfileHeaderGhostCellSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileHeaderGhostCellSpec: QuickSpec {
    override func spec() {
        describe("ProfileHeaderGhostCell") {
            it("snapshot") {
                let subject = ProfileHeaderGhostCell()
                expectValidSnapshot(subject, named: "ProfileHeaderGhostCell", device: .custom(CGSize(width: 375, height: ProfileHeaderGhostCell.Size.height)))
            }
        }
    }
}
