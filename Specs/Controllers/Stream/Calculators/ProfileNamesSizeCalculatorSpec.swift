////
///  ProfileNamesSizeCalculatorSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileNamesSizeCalculatorSpec: QuickSpec {
    override func spec() {
        describe("ProfileNamesSizeCalculator") {
            it("should return sensible size for one line of text") {
                let user: User = stub([
                    "name": "Name Name",
                    "username": "name",
                ])
                let calc = ProfileNamesSizeCalculator()
                var height: CGFloat!
                calc.calculate(StreamCellItem(jsonable: user, type: .streamHeader), maxWidth: 320)
                    .then { h -> Void in height = h }
                    .catch { _ in }
                expect(height) == 57
            }
            it("should return sensible size for two lines of text") {
                let user: User = stub([
                    "name": "Name Name Name Name Name Name Name Name",
                    "username": "namenamenamenamenamenamenamenamename",
                ])
                let calc = ProfileNamesSizeCalculator()
                var height: CGFloat!
                calc.calculate(StreamCellItem(jsonable: user, type: .streamHeader), maxWidth: 320)
                    .then { h -> Void in height = h }
                    .catch { _ in }
                expect(height) == 76
            }
        }
    }
}
