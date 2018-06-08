////
///  ProfileHeaderBioSizeCalculatorSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileHeaderBioSizeCalculatorSpec: QuickSpec {
    override func spec() {
        describe("ProfileHeaderBioSizeCalculator") {
            it("should return sensible size for an empty bio") {
                let user: User = stub([
                    "formattedShortBio": "",
                ])
                let calc = ProfileHeaderBioSizeCalculator()
                var height: CGFloat?
                calc.calculate(StreamCellItem(jsonable: user, type: .streamHeader), width: 320)
                    .done { h in height = h }
                    .catch { _ in }
                expect(height) == 0
            }

            it("should return sensible size for a nil bio") {
                let user: User = stub([:])
                user.formattedShortBio = nil
                let calc = ProfileHeaderBioSizeCalculator()
                var height: CGFloat?
                calc.calculate(StreamCellItem(jsonable: user, type: .streamHeader), width: 320)
                    .done { h in height = h }
                    .catch { _ in }
                expect(height) == 0
            }

            xit("should return sensible size for a bio") {
                let user: User = stub([
                    "formattedShortBio": "<p>bio</p>",
                ])
                let calc = ProfileHeaderBioSizeCalculator()
                var height: CGFloat?
                calc.calculate(StreamCellItem(jsonable: user, type: .streamHeader), width: 320)
                    .done { h in height = h }
                    .catch { _ in }
                expect(height).toEventually(beGreaterThan(40))
            }
        }
    }
}
