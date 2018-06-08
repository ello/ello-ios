////
///  ProfileHeaderNamesSizeCalculatorSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileHeaderNamesSizeCalculatorSpec: QuickSpec {
    override func spec() {
        describe("ProfileHeaderNamesSizeCalculator") {
            it("should return sensible size for one line of text") {
                let user: User = stub([
                    "name": "Name Name",
                    "username": "name",
                ])
                let calc = ProfileHeaderNamesSizeCalculator()
                var height: CGFloat!
                calc.calculate(StreamCellItem(jsonable: user, type: .streamHeader), width: 320)
                    .done { h in height = h }
                    .catch { _ in }
                expect(height) == 57
            }
            it("should return sensible size for two lines of text") {
                let user: User = stub([
                    "name": "Name Name Name Name Name Name Name Name",
                    "username": "namenamenamenamenamenamenamenamename",
                ])
                let calc = ProfileHeaderNamesSizeCalculator()
                var height: CGFloat!
                calc.calculate(StreamCellItem(jsonable: user, type: .streamHeader), width: 320)
                    .done { h in height = h }
                    .catch { _ in }
                expect(height) == 76
            }
        }
    }
}
