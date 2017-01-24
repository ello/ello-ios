////
///  EmptyStreamCellPresenterSpec.swift
//

@testable import Ello
import Quick
import Nimble


class EmptyStreamCellPresenterSpec: QuickSpec {

    override func spec() {
        describe("EmptyStreamCellPresenter") {
            it("configures the cell") {
                let cell = EmptyStreamCell()
                let item = StreamCellItem(type: .emptyStream(height: 200))
                EmptyStreamCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                expect(cell.title) == InterfaceString.EmptyStreamText
            }
        }
    }
}
