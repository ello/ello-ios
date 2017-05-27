////
///  ProfileTotalCountSizeCalculatorSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileTotalCountSizeCalculatorSpec: QuickSpec {
    override func spec() {

        describe("ProfileTotalCountSizeCalculator") {

            it("returns 0 if totalViewsCount is nil") {
                let user: User = stub([:])
                let calc = ProfileTotalCountSizeCalculator()
                var height: CGFloat!
                calc.calculate(StreamCellItem(jsonable: user, type: .header))
                    .thenFinally { h in height = h }
                    .catch { _ in }
                expect(height) == 0
            }

            it("returns 0 if totalViewsCount is zero") {
                let user: User = stub(["totalViewsCount": 0])
                let calc = ProfileTotalCountSizeCalculator()
                var height: CGFloat!
                calc.calculate(StreamCellItem(jsonable: user, type: .header))
                    .thenFinally { h in height = h }
                    .catch { _ in }
                expect(height) == 0
            }

            it("greater than 0 if totalViewsCount > 0") {
                let user: User = stub(["totalViewsCount": 1])
                let calc = ProfileTotalCountSizeCalculator()
                var height: CGFloat!
                calc.calculate(StreamCellItem(jsonable: user, type: .header))
                    .thenFinally { h in height = h }
                    .catch { _ in }
                expect(height) > 0
            }
        }
    }
}
