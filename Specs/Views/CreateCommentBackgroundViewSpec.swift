////
///  CreateCommentBackgroundViewSpec.swift
//

@testable import Ello
import Quick
import Nimble


class CreateCommentBackgroundViewSpec: QuickSpec {
    override func spec() {
        describe("basic view stuff") {
            it("is a view") {
                expect(CreateCommentBackgroundView()).to(beAKindOf(UIView.self))
                expect(CreateCommentBackgroundView(frame: .zero)).to(beAKindOf(UIView.self))
            }
        }
    }
}
