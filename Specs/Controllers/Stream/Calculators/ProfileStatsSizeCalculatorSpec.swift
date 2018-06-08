////
///  ProfileHeaderStatsSizeCalculatorSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileHeaderStatsSizeCalculatorSpec: QuickSpec {
    override func spec() {
        describe("ProfileHeaderStatsSizeCalculator") {
            it("always returns the right number") {
                let user: User = stub([:])
                let calc = ProfileHeaderStatsSizeCalculator()
                var height: CGFloat!
                calc.calculate(StreamCellItem(jsonable: user, type: .streamHeader))
                    .done { h in height = h }
                    .catch { _ in }
                expect(height) == 60
            }
        }
    }
}
