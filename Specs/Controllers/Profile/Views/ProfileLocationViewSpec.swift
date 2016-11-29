////
///  ProfileLocationViewSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileLocationViewSpec: QuickSpec {

    override func spec() {
        fdescribe("ProfileLocationView") {
            it("snapshots") {
                let subject = ProfileLocationView(frame: CGRect(
                    origin: .zero,
                    size: CGSize(width: 375, height: ProfileLocationView.Size.height)
                ))
                subject.location = "Denver, CO"
                expectValidSnapshot(subject, named: "ProfileLocationView", device: .Custom(subject.frame.size))
            }
        }
    }
}

