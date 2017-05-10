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
                let editorial: Ello.Editorial = stub(["id": "123", "title": "Editorial Title"]) as Ello.Editorial
                let cell: EditorialCell = EditorialCell()
                let item: StreamCellItem = StreamCellItem(jsonable: editorial, type: .editorial(.post))

                EditorialCellPresenter.configure(cell, streamCellItem: item, streamKind: .editorials, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                expect(cell.config.title) == editorial.title
            }
        }
    }
}
