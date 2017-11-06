////
///  ProfileBioSizeCalculatorSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileBioSizeCalculatorSpec: QuickSpec {
    override func spec() {
        describe("ProfileBioSizeCalculator") {
            it("should return sensible size for an empty bio") {
                let user: User = stub([
                    "formattedShortBio": "",
                ])
                let calc = ProfileBioSizeCalculator()
                var height: CGFloat?
                calc.calculate(StreamCellItem(jsonable: user, type: .streamHeader), maxWidth: 320)
                    .then { h -> Void in height = h }
                    .catch { _ in }
                expect(height) == 0
            }

            it("should return sensible size for a nil bio") {
                let user: User = stub([:])
                user.formattedShortBio = nil
                let calc = ProfileBioSizeCalculator()
                var height: CGFloat?
                calc.calculate(StreamCellItem(jsonable: user, type: .streamHeader), maxWidth: 320)
                    .then { h -> Void in height = h }
                    .catch { _ in }
                expect(height) == 0
            }

            xit("should return sensible size for a bio") {
                let user: User = stub([
                    "formattedShortBio": "<p>bio</p>",
                ])
                let calc = ProfileBioSizeCalculator()
                var height: CGFloat?
                calc.calculate(StreamCellItem(jsonable: user, type: .streamHeader), maxWidth: 320)
                    .then { h -> Void in height = h }
                    .catch { _ in }
                expect(height).toEventually(beGreaterThan(40))
            }
        }
    }
}
