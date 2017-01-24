////
///  CategoryListCellPresenterSpec.swift
//

@testable import Ello
import Quick
import Nimble


class CategoryListCellPresenterSpec: QuickSpec {
    override func spec() {
        describe("CategoryListCellPresenter") {
            it("sets the categoriesInfo on a cell") {
                let categoryList: CategoryList = CategoryList.metaCategories()
                let cell: CategoryListCell = CategoryListCell()
                let item: StreamCellItem = StreamCellItem(jsonable: categoryList, type: .categoryList)

                CategoryListCellPresenter.configure(cell, streamCellItem: item, streamKind: .categoryPosts(slug: "art"), indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                expect(cell.categoriesInfo.count) == categoryList.categories.count

                expect(cell.categoriesInfo[0].title) == categoryList.categories[0].name
                expect(cell.categoriesInfo[0].slug) == categoryList.categories[0].slug

                expect(cell.categoriesInfo[1].title) == categoryList.categories[1].name
                expect(cell.categoriesInfo[1].slug) == categoryList.categories[1].slug

                expect(cell.categoriesInfo[2].title) == categoryList.categories[2].name
                expect(cell.categoriesInfo[2].slug) == categoryList.categories[2].slug
            }
        }
    }
}
