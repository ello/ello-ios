////
///  CategoryCardCellPresenterSpec.swift
//

@testable import Ello
import Quick
import Nimble


class CategoryCardCellPresenterSpec: QuickSpec {
    override func spec() {
        describe("CategoryCardCellPresenter") {
            it("sets the card title") {
                let category: Ello.Category = stub(["name": "Art"]) as Ello.Category
                let cell: CategoryCardCell = CategoryCardCell()
                let item: StreamCellItem = StreamCellItem(jsonable: category, type: .categoryCard)

                CategoryCardCellPresenter.configure(cell, streamCellItem: item, streamKind: .categoryPosts(slug: "art"), indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                expect(cell.title) == "Art"
            }
        }
    }
}
