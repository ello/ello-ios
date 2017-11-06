////
///  ProfileBadgesSizeCalculatorSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileBadgesSizeCalculatorSpec: QuickSpec {
    override func spec() {

        describe("ProfileBadgesSizeCalculator") {

            it("returns 0 if badge count is 0") {
                let user: User = stub([:])
                let calc = ProfileBadgesSizeCalculator()
                var height: CGFloat!
                calc.calculate(StreamCellItem(jsonable: user, type: .streamHeader))
                    .then { h -> Void in height = h }
                    .catch { _ in }
                expect(height) == 0
            }

            it("greater than 0 if badge count > 0") {
                let user: User = stub([:])
                user.badges = [Badge.stub([:])]
                let calc = ProfileBadgesSizeCalculator()
                var height: CGFloat!
                calc.calculate(StreamCellItem(jsonable: user, type: .streamHeader))
                    .then { h -> Void in height = h }
                    .catch { _ in }
                expect(height) > 0
            }
        }
    }
}
