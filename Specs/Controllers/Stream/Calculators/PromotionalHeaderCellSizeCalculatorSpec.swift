////
///  PromotionalHeaderCellSizeCalculatorSpec.swift
//

@testable import Ello
import Quick
import Nimble


class PromotionalHeaderCellSizeCalculatorSpec: QuickSpec {
    override func spec() {
        describe("PromotionalHeaderCellSizeCalculator") {
            describe("should size proportionally according to frame width") {
                let expectations: [(CGFloat, CGFloat)] = [
                    (320, 192),
                    (375, 225),
                    (414, 249),
                ]
                for (frameWidth, calcHeight) in expectations {
                    it("should size width \(frameWidth) to \(calcHeight)") {
                        let calculator = PromotionalHeaderCellSizeCalculator(webView: MockUIWebView())
                        let cellItem = StreamCellItem(jsonable: PagePromotional.stub([:]), type: .categoryPromotionalHeader)
                        calculator.processCells([cellItem], withWidth: frameWidth) {
                            expect(cellItem.calculatedCellHeights.oneColumn) == calcHeight
                        }
                    }
                }

                it("should size correctly with text") {
                    let calculator = PromotionalHeaderCellSizeCalculator()
                    let category: Ello.Category = stub([:])
                    category.body = "Short body."
                    category.ctaCaption = "Read More"
                    let cellItem = StreamCellItem(jsonable: category, type: .categoryPromotionalHeader)
                    calculator.processCells([cellItem], withWidth: 320) {
                        expect(cellItem.calculatedCellHeights.oneColumn) == 192
                    }
                }

                it("should size longer with text") {
                        let calculator = PromotionalHeaderCellSizeCalculator()
                        let category: Ello.Category = stub([:])
                        category.body = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc consectetur molestie faucibus. Phasellus iaculis pellentesque felis eu fringilla. Ut in sollicitudin nisi. Praesent in mauris tortor. Nam interdum, magna eu pellentesque scelerisque, dui ipsum adipiscing ante, vel ullamcorper nisl sapien id arcu. Nullam egestas diam eu felis mollis sit amet cursus enim vehicula. Quisque eu tellus id erat pellentesque consequat. Maecenas fermentum faucibus magna, eget dictum nisi congue sed. Quisque a justo a nisi eleifend facilisis sit amet at augue. Sed a sapien vitae augue hendrerit porta vel eu ligula. Proin enim urna, faucibus in vestibulum tincidunt, commodo sit amet orci. Vestibulum ac sem urna, quis mattis urna. Nam eget ullamcorper ligula. Nam volutpat, arcu vel auctor dignissim, tortor nisi sodales enim, et vestibulum nulla dui id ligula. Nam ullamcorper, augue ut interdum vulputate, eros mauris lobortis sapien, ac sodales dui eros ac elit."
                        category.ctaCaption = "Read More"
                        let cellItem = StreamCellItem(jsonable: category, type: .categoryPromotionalHeader)
                        calculator.processCells([cellItem], withWidth: 320) {
                            expect(cellItem.calculatedCellHeights.oneColumn) > 192
                        }
                }
            }
        }
    }
}
