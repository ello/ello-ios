////
///  CategoryCardListViewSpec.swift
//

@testable import Ello
import Quick
import Nimble


class CategoryCardListViewSpec: QuickSpec {
    class MockCategoryCardListDelegate: CategoryCardListDelegate {
        var selectedIndex: Int?
        func categoryCardSelected(_ index: Int) {
            selectedIndex = index
        }
    }

    override func spec() {
        var subject: CategoryCardListView!
        var delegate: MockCategoryCardListDelegate!
        beforeEach {
            subject = CategoryCardListView(frame: CGRect(origin: .zero, size: CGSize(width: 320, height: CategoryCardListView.Size.height)))
            let infoA = CategoryCardListView.CategoryInfo(
                title: "Art",
                imageURL: nil
            )
            let infoB = CategoryCardListView.CategoryInfo(
                title: "Lorem ipsum dolor sit amet",
                imageURL: nil
            )
            subject.categoriesInfo = [infoA, infoB, infoA, infoB]
            delegate = MockCategoryCardListDelegate()
            subject.delegate = delegate
        }

        describe("CategoryCardListView") {
            it("should have a valid snapshot") {
                expectValidSnapshot(subject, named: "CategoryCardListView", device: .custom(subject.frame.size))
            }

            describe("CategoryCardListDelegate") {
                it("informs delegates of category selection") {
                    let button = subviewThatMatches(subject, test: { $0 is UIButton }) as! UIButton
                    button.sendActions(for: .touchUpInside)
                    expect(delegate.selectedIndex) == 0
                }
            }
        }
    }
}
