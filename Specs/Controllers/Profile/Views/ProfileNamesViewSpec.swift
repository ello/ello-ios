////
///  ProfileNamesViewSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileNamesViewSpec: QuickSpec {
    override func spec() {
        describe("ProfileNamesView") {
            it("horizontal snapshots") {
                let subject = ProfileNamesView(frame: CGRect(
                    origin: .zero,
                    size: CGSize(width: 375, height: 60)
                    ))
                subject.name = "Jim"
                subject.username = "@jimmy"
                expectValidSnapshot(subject, named: "ProfileNamesView-horizontal", device: .custom(subject.frame.size))
            }
            it("vertical snapshots") {
                let subject = ProfileNamesView(frame: CGRect(
                    origin: .zero,
                    size: CGSize(width: 300, height: 80)
                    ))
                subject.name = "Jimmy Jim Jim Shabadoo"
                subject.username = "@jimmy"
                expectValidSnapshot(subject, named: "ProfileNamesView-vertical", device: .custom(subject.frame.size))
            }
        }
    }
}
