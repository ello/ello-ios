////
///  CategoryCardListViewSpec.swift
//

@testable import Ello
import Quick
import Nimble


class CategoryCardListViewSpec: QuickSpec {
    class MockCategoryCardListDelegate: CategoryCardListDelegate {
        var selectedIndex: Int?
        var allCategoriesTappedCount = 0
        var editCategoriesTappedCount = 0
        var subscribedCategoriesTappedCount = 0
        func categoryCardSelected(_ index: Int) {
            selectedIndex = index
        }
        func allCategoriesTapped() {
            allCategoriesTappedCount += 1
        }
        func editCategoriesTapped() {
            editCategoriesTappedCount += 1
        }
        func subscribedCategoryTapped() {
            subscribedCategoriesTappedCount += 1
        }
    }

    override func spec() {
        var subject: CategoryCardListView!
        var delegate: MockCategoryCardListDelegate!
        beforeEach {
            subject = CategoryCardListView(frame: CGRect(origin: .zero, size: CGSize(width: 320, height: CategoryCardListView.Size.height)))
            delegate = MockCategoryCardListDelegate()
            subject.delegate = delegate
        }

        describe("CategoryCardListView") {
            context("should have valid snapshot") {
                it("when showing only categories") {
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
                    subject.categoriesInfo = [infoA, infoB]

                    expectValidSnapshot(subject, named: "CategoryCardListView-categories")
                }

                it("when showing only categories with all and subscribed") {
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
                    subject.categoriesInfo = [.all, .subscribed, infoA, infoB]

                    expectValidSnapshot(subject, named: "CategoryCardListView-all")
                }

                it("when showing zero state") {
                    subject.categoriesInfo = [.zeroState]

                    expectValidSnapshot(subject, named: "CategoryCardListView-zeroState")
                }
            }

            describe("CategoryCardListDelegate") {
                it("informs delegates of all category selection") {
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
                    subject.categoriesInfo = [.all, .subscribed, infoA, infoB]

                    let buttons: [UIButton] = subject.findAllSubviews()
                    let button: UIButton! = buttons[0]
                    button.sendActions(for: .touchUpInside)
                    expect(delegate.allCategoriesTappedCount) == 1
                }

                it("informs delegates of subscribed category selection") {
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
                    subject.categoriesInfo = [.all, .subscribed, infoA, infoB]

                    let buttons: [UIButton] = subject.findAllSubviews()
                    let button: UIButton! = buttons[1]
                    button.sendActions(for: .touchUpInside)
                    expect(delegate.subscribedCategoriesTappedCount) == 1
                }

                it("informs delegates of edit selection") {
                    subject.categoriesInfo = [.zeroState]

                    let buttons: [UIButton] = subject.findAllSubviews()
                    let button: UIButton! = buttons.first
                    button.sendActions(for: .touchUpInside)
                    expect(delegate.editCategoriesTappedCount) == 1
                }

                it("informs delegates of category selection") {
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
                    let categoriesInfo = [infoA, infoB]
                    subject.categoriesInfo = [.all, .subscribed] + categoriesInfo

                    let buttons: [UIButton] = subject.findAllSubviews()
                    let button: UIButton! = buttons.last
                    button.sendActions(for: .touchUpInside)
                    expect(delegate.selectedIndex) == categoriesInfo.count - 1
                }
            }
        }
    }
}
