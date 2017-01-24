////
///  CategoryScreenSpec.swift
//

@testable import Ello
import Quick
import Nimble


class CategoryScreenSpec: QuickSpec {
    class MockCategoryScreenDelegate: CategoryScreenDelegate {
        var selectedIndex: Int?
        func categorySelected(index: Int) {
            selectedIndex = index
        }
    }

    override func spec() {
        describe("CategoryScreen") {
            var subject: CategoryScreen!
            var delegate: MockCategoryScreenDelegate!
            beforeEach {
                let infoA = CategoryCardListView.CategoryInfo(
                    title: "Art",
                    imageURL: nil
                    )
                let infoB = CategoryCardListView.CategoryInfo(
                    title: "Lorem ipsum dolor sit amet",
                    imageURL: nil
                    )
                subject = CategoryScreen()
                subject.set(categoriesInfo: [infoA, infoB, infoA, infoB], animated: false, completion: {})
                delegate = MockCategoryScreenDelegate()
                subject.delegate = delegate
            }

            describe("snapshots") {
                validateAllSnapshots(named: "CategoryScreen") {
                    return subject
                }
            }

            describe("CategoryScreenDelegate") {
                it("informs delegates of category selection") {
                    let categoryList = subviewThatMatches(subject, test: { $0 is CategoryCardListView }) as! CategoryCardListView
                    let button = subviewThatMatches(categoryList, test: { $0 is UIButton }) as! UIButton
                    button.sendActions(for: .touchUpInside)
                    expect(delegate.selectedIndex) == 0
                }
            }
        }
    }
}
