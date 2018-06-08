////
///  StreamTextCellSizeCalculatorSpec.swift
//

@testable import Ello
import Quick
import Nimble


class StreamTextCellSizeCalculatorSpec: QuickSpec {
    override func spec() {
        var webView: MockUIWebView!
        let mockHeight: CGFloat = 50

        beforeEach {
            webView = MockUIWebView()
            webView.mockHeight = mockHeight
        }

        describe("StreamTextCellSizeCalculator") {
            it("assigns cell height to all cell items") {
                let post = Post.stub([:])

                let items = [
                    StreamCellItem(jsonable: post, type: .text(data: TextRegion(content: ""))),
                    StreamCellItem(jsonable: post, type: .text(data: TextRegion(content: ""))),
                    StreamCellItem(jsonable: post, type: .text(data: TextRegion(content: ""))),
                    StreamCellItem(jsonable: post, type: .text(data: TextRegion(content: ""))),
                ]
                for item in items {
                    let calculator = item.sizeCalculator(streamKind: .following, width: Globals.windowSize.width, columnCount: 1) as! StreamTextCellSizeCalculator
                    calculator.webView = webView
                    
                    var completed = false
                    calculator.begin {
                        completed = true
                    }
                    expect(completed) == true
                    expect(item.calculatedCellHeights.oneColumn) == mockHeight
                }
            }
        }
    }
}
