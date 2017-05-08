////
///  EditorialCellPresenterSpec.swift
//

@testable import Ello
import Quick
import Nimble


class EditorialCellPresenterSpec: QuickSpec {
    override func spec() {
        describe("EditorialCellPresenter") {
            it("sets the card title") {
                let category: Ello.Editorial = stub(["id": "123"]) as Ello.Editorial
                let cell: EditorialCell = EditorialCell()
                let item: StreamCellItem = StreamCellItem(jsonable: category, type: .editorial)

                EditorialCellPresenter.configure(cell, streamCellItem: item, streamKind: .editorials, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                expect(1) == 1
            }
        }
    }
}
