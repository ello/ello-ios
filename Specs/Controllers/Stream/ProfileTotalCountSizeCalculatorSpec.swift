////
///  ProfileTotalCountSizeCalculatorSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileTotalCountSizeCalculatorSpec: QuickSpec {
    override func spec() {

        describe("ProfileTotalCountSizeCalculator") {

            it("always returns 0") {
                let user: User = stub([:])
                let calc = ProfileTotalCountSizeCalculator()
                var height: CGFloat!
                calc.calculate(StreamCellItem(jsonable: user, type: .header))
                    .onSuccess { h in height = h }
                    .onFail { _ in }
                expect(height) == 0
            }
        }
    }
}

