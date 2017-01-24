////
///  ProfileTotalCountViewSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileTotalCountViewSpec: QuickSpec {
    override func spec() {
        describe("ProfileTotalCountView") {
            it("snapshots") {
                let subject = ProfileTotalCountView(frame: CGRect(
                    origin: .zero,
                    size: CGSize(width: 375, height: 60)
                ))
                subject.count = "2.3M"
                expectValidSnapshot(subject, named: "ProfileTotalCountView", device: .custom(subject.frame.size))
            }
        }
    }
}
