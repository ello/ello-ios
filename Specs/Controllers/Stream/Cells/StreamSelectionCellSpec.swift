////
///  StreamSelectionCellSpec.swift
//

@testable import Ello
import Quick
import Nimble


class StreamSelectionCellSpec: QuickSpec {

    class FakeStreamSelectionCellResponder: UIView, StreamSelectionCellResponder {
        var categoryTapped = false
        var stream: String?

        func streamTapped(_ stream: String) {
            categoryTapped = true
            self.stream = stream
        }
    }

    override func spec() {
        describe("StreamSelectionCell") {
            var subject: StreamSelectionCell!
            var responder: FakeStreamSelectionCellResponder!

            beforeEach {
                responder = FakeStreamSelectionCellResponder()
                let frame = CGRect(origin: .zero, size: CGSize(width: 320, height: StreamSelectionCell.Size.height))
                subject = StreamSelectionCell(frame: frame)
                showView(subject, container: responder)
            }

            describe("actions") {
                it("sends action when tapping on a category") {
                    let categoryButton: UIButton? = subview(of: subject, thatMatches: { button in
                        button.currentAttributedTitle?.string == "Featured"
                    })
                    categoryButton?.sendActions(for: .touchUpInside)
                    expect(responder.categoryTapped) == true
                    expect(responder.stream) == DiscoverType.featured.rawValue
                }
            }

            it("displays categories") {
                expectValidSnapshot(subject)
            }
        }
    }
}
