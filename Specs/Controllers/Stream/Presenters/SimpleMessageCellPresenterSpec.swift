////
///  SimpleMessageCellPresenterSpec.swift
//

@testable import Ello
import Quick
import Nimble


class SimpleMessageCellPresenterSpec: QuickSpec {

    override func spec() {
        describe("SimpleMessageCellPresenter") {
            it("configures an error cell") {
                let cell = SimpleMessageCell()
                let item = StreamCellItem(type: .emptyStream(height: 200))
                SimpleMessageCellPresenter.configureEmpty(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                expect(cell.title) == InterfaceString.EmptyStreamText
            }

            it("configures an error message") {
                let cell = SimpleMessageCell()
                let item = StreamCellItem(type: .error(message: "This is an error"))
                SimpleMessageCellPresenter.configureError(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                expect(cell.title) == "This is an error"
            }
        }
    }
}
