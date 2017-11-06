////
///  ProfileStatsSizeCalculatorSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileStatsSizeCalculatorSpec: QuickSpec {
    override func spec() {
        describe("ProfileStatsSizeCalculator") {
            it("always returns 70") {
                let user: User = stub([:])
                let calc = ProfileStatsSizeCalculator()
                var height: CGFloat!
                calc.calculate(StreamCellItem(jsonable: user, type: .streamHeader))
                    .then { h -> Void in height = h }
                    .catch { _ in }
                expect(height) == 60
            }
        }
    }
}
