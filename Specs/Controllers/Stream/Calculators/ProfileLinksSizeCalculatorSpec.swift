////
///  ProfileHeaderLinksSizeCalculatorSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileHeaderLinksSizeCalculatorSpec: QuickSpec {
    override func spec() {
        describe("ProfileHeaderLinksSizeCalculator") {
            it("should return sensible size for zero links") {
                let user: User = stub([:])
                user.externalLinksList = []
                let calc = ProfileHeaderLinksSizeCalculator()
                var height: CGFloat?
                calc.calculate(StreamCellItem(jsonable: user, type: .streamHeader), width: 375)
                    .done { h in height = h }
                    .catch { _ in }
                expect(height) == 0
            }

            it("should return sensible size for nil links") {
                let user: User = stub([:])
                user.externalLinksList = nil
                let calc = ProfileHeaderLinksSizeCalculator()
                var height: CGFloat?
                calc.calculate(StreamCellItem(jsonable: user, type: .streamHeader), width: 375)
                    .done { h in height = h }
                    .catch { _ in }
                expect(height) == 0
            }

            it("should return sensible size for links") {
                let links = [
                    ["url": "http://ello.co", "text": "ello.co"],
                ]
                let user: User = stub(["externalLinksList": links])
                let calc = ProfileHeaderLinksSizeCalculator()
                var height: CGFloat?
                calc.calculate(StreamCellItem(jsonable: user, type: .streamHeader), width: 375)
                    .done { h in height = h }
                    .catch { _ in }
                expect(height) == 53
            }

            it("should return sensible size for many links and icons") {
                let links = [
                    ["url": "http://ello.co", "text": "ello.co"],
                    ["url": "http://ello.co", "text": "ello.co"],
                    ["url": "http://ello.co", "text": "ello.co", "icon": "http://social-icons.ello.co/ello.png"],
                ]
                let user: User = stub(["externalLinksList": links])
                let calc = ProfileHeaderLinksSizeCalculator()
                var height: CGFloat?
                calc.calculate(StreamCellItem(jsonable: user, type: .streamHeader), width: 375)
                    .done { h in height = h }
                    .catch { _ in }
                expect(height) == 82
            }

            it("should return sensible size for lots of links and icons") {
                let links = [
                    ["url": "http://ello.co", "text": "ello.co"],
                    ["url": "http://ello.co", "text": "ello.co"],
                    ["url": "http://ello.co", "text": "ello.co"],
                    ["url": "http://ello.co", "text": "ello.co"],
                    ["url": "http://ello.co", "text": "ello.co"],
                    ["url": "http://ello.co", "text": "ello.co"],
                    ["url": "http://ello.co", "text": "ello.co", "icon": "http://social-icons.ello.co/ello.png"],
                    ]
                let user: User = stub(["externalLinksList": links])
                let calc = ProfileHeaderLinksSizeCalculator()
                var height: CGFloat?
                calc.calculate(StreamCellItem(jsonable: user, type: .streamHeader), width: 375)
                    .done { h in height = h }
                    .catch { _ in }
                expect(height) == 198
            }

            it("should return sensible size for links and many icons") {
                let links = [
                    ["url": "http://ello.co", "text": "ello.co"],
                    ["url": "http://ello.co", "text": "ello.co", "icon": "http://social-icons.ello.co/ello.png"],
                    ["url": "http://ello.co", "text": "ello.co", "icon": "http://social-icons.ello.co/ello.png"],
                ]
                let user: User = stub(["externalLinksList": links])
                let calc = ProfileHeaderLinksSizeCalculator()
                var height: CGFloat?
                calc.calculate(StreamCellItem(jsonable: user, type: .streamHeader), width: 375)
                    .done { h in height = h }
                    .catch { _ in }
                expect(height) == 53
            }

            it("should return sensible size for links and lots of icons") {
                let links = [
                    ["url": "http://ello.co", "text": "ello.co"],
                    ["url": "http://ello.co", "text": "ello.co", "icon": "http://social-icons.ello.co/ello.png"],
                    ["url": "http://ello.co", "text": "ello.co", "icon": "http://social-icons.ello.co/ello.png"],
                    ["url": "http://ello.co", "text": "ello.co", "icon": "http://social-icons.ello.co/ello.png"],
                    ["url": "http://ello.co", "text": "ello.co", "icon": "http://social-icons.ello.co/ello.png"],
                    ["url": "http://ello.co", "text": "ello.co", "icon": "http://social-icons.ello.co/ello.png"],
                    ["url": "http://ello.co", "text": "ello.co", "icon": "http://social-icons.ello.co/ello.png"],
                    ]
                let user: User = stub(["externalLinksList": links])
                let calc = ProfileHeaderLinksSizeCalculator()
                var height: CGFloat?
                calc.calculate(StreamCellItem(jsonable: user, type: .streamHeader), width: 375)
                    .done { h in height = h }
                    .catch { _ in }
                expect(height) == 81
            }

            it("should return sensible size for icons") {
                let links = [
                    ["url": "http://ello.co", "text": "ello.co", "icon": "http://social-icons.ello.co/ello.png"],
                ]
                let user: User = stub(["externalLinksList": links])
                let calc = ProfileHeaderLinksSizeCalculator()
                var height: CGFloat?
                calc.calculate(StreamCellItem(jsonable: user, type: .streamHeader), width: 375)
                    .done { h in height = h }
                    .catch { _ in }
                expect(height) == 49
            }
        }
    }
}
