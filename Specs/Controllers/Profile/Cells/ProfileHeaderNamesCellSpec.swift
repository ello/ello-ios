////
///  ProfileHeaderNamesCellSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileHeaderNamesCellSpec: QuickSpec {
    override func spec() {
        describe("ProfileHeaderNamesCell") {
            it("horizontal snapshots") {
                let subject = ProfileHeaderNamesCell(
                    frame: CGRect(
                        origin: .zero,
                        size: CGSize(width: 375, height: 60)
                    )
                )
                subject.name = "Jim"
                subject.username = "@jimmy"
                expectValidSnapshot(subject, named: "ProfileHeaderNamesCell-horizontal")
            }
            it("vertical snapshots") {
                let subject = ProfileHeaderNamesCell(
                    frame: CGRect(
                        origin: .zero,
                        size: CGSize(width: 300, height: 80)
                    )
                )
                subject.name = "Jimmy Jim Jim Shabadoo"
                subject.username = "@jimmy"
                expectValidSnapshot(subject, named: "ProfileHeaderNamesCell-vertical")
            }
        }
    }
}
