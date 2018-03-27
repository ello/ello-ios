////
///  CategoryScreenSpec.swift
//

@testable import Ello
import Quick
import Nimble


class CategoryScreenSpec: QuickSpec {
    class MockCategoryScreenDelegate: CategoryScreenDelegate {
        var selectedIndex: Int?
        var allCategoriesTappedCount = 0
        var editCategoriesTappedCount = 0
        var subscribedCategoryTappedCount = 0
        var gridListToggled = 0
        var searchButtonCount = 0
        var shareCount = 0
        var backCount = 0
        var scrollToTopCount = 0

        func categorySelected(index: Int) {
            selectedIndex = index
        }
        func allCategoriesTapped() {
            allCategoriesTappedCount += 1
        }
        func editCategoriesTapped() {
            editCategoriesTappedCount += 1
        }
        func subscribedCategoryTapped() {
            subscribedCategoryTappedCount += 1
        }
        func gridListToggled(sender: UIButton) {
            gridListToggled += 1
        }
        func searchButtonTapped() {
            searchButtonCount += 1
        }
        func shareTapped(sender: UIView) {
            shareCount += 1
        }
        func backButtonTapped() {
            backCount += 1
        }
        func scrollToTop() {
            scrollToTopCount += 1
        }
    }

    override func spec() {
        describe("CategoryScreen") {
            var subject: CategoryScreen!
            var delegate: MockCategoryScreenDelegate!
            var categoryInfo: [CategoryCardListView.CategoryInfo]!

            beforeEach {
                let infoA = CategoryCardListView.CategoryInfo(
                    title: "Art",
                    kind: .category,
                    imageURL: URL(string: "https://example.com")
                    )
                let infoB = CategoryCardListView.CategoryInfo(
                    title: "Lorem ipsum dolor sit amet",
                    kind: .category,
                    imageURL: URL(string: "https://example.com")
                    )
                subject = CategoryScreen(usage: .default)
                categoryInfo = [CategoryCardListView.CategoryInfo.all, infoA, infoB, infoA, infoB]
                subject.set(categoriesInfo: categoryInfo, completion: {})
                delegate = MockCategoryScreenDelegate()
                subject.delegate = delegate
            }

            describe("snapshots") {
                validateAllSnapshots(named: "CategoryScreen") { return subject }

                describe("snapshots on home screen") {
                    beforeEach {
                        subject = CategoryScreen(usage: .largeNav)
                        subject.set(categoriesInfo: categoryInfo, completion: {})
                    }
                    validateAllSnapshots(named: "CategoryScreen HomeScreen") { return subject }
                }
            }

            describe("CategoryScreenDelegate") {
                it("informs delegates of all categories selection") {
                    let categoryList: CategoryCardListView! = subject.findSubview()
                    let buttons: [UIButton] = categoryList.findAllSubviews()
                    let button: UIButton! = buttons.first
                    button.sendActions(for: .touchUpInside)
                    expect(delegate.allCategoriesTappedCount) == 1
                }
                it("informs delegates of category selection") {
                    let categoryList: CategoryCardListView! = subject.findSubview()
                    let buttons: [UIButton] = categoryList.findAllSubviews()
                    let button: UIButton! = buttons.last
                    button.sendActions(for: .touchUpInside)
                    expect(delegate.selectedIndex) == categoryInfo.count - 2  // minus an extra for .all info
                }
            }
        }
    }
}
