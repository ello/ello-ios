////
///  CategoryViewControllerSpec.swift
//

@testable import Ello
import Quick
import Nimble
import SnapKit


class CategoryViewControllerSpec: QuickSpec {
    class MockCategoryScreen: CategoryScreenProtocol {        
        var showSubscribed: Bool = true
        var showEditButton: Bool = true
        var categoriesLoaded: Bool = false

        let topInsetView = UIView()
        let streamContainer = Container()
        var isGridView = true
        var navigationBarTopConstraint: Constraint!
        let navigationBar = ElloNavigationBar()
        var categoryTitles: [String] = []
        var scrollTo: CategoryScreen.Selection?
        var select: CategoryScreen.Selection?
        var showShare: CategoryScreen.NavBarItems = .all
        var showBack = false

        func set(categoriesInfo: [CategoryCardListView.CategoryInfo], completion: @escaping Block) {
            categoryTitles = categoriesInfo.map { $0.title }
        }
        func toggleCategoriesList(navBarVisible: Bool, animated: Bool) {}
        func scrollToCategory(_ selection: CategoryScreen.Selection) {
            scrollTo = selection
        }

        func selectCategory(_ selection: CategoryScreen.Selection) {
            select = selection
        }

        func viewForStream() -> UIView {
            return streamContainer
        }

        func setupNavBar(back backVisible: Bool, animated: Bool) {
            self.showBack = backVisible
        }
    }

    override func spec() {
        describe("CategoryViewController") {
            let currentUser: User = stub([:])
            var subject: CategoryViewController!
            var screen: MockCategoryScreen!

            beforeEach {
                let category: Ello.Category = Ello.Category.stub([:])
                subject = CategoryViewController(currentUser: currentUser, slug: category.slug)
                screen = MockCategoryScreen()
                subject.screen = screen
                showController(subject)
            }

            it("shows the back button when necessary") {
                let category: Ello.Category = Ello.Category.stub([:])
                subject = CategoryViewController(currentUser: currentUser, slug: category.slug)
                screen = MockCategoryScreen()
                subject.screen = screen

                let nav = UINavigationController(rootViewController: UIViewController())
                nav.pushViewController(subject, animated: false)
                showController(nav)
                expect(screen.showBack) == true
            }

            context("set(subscribedCategories:)") {
                context("builds category list") {
                    it("is logged out") {
                        subject = CategoryViewController(currentUser: nil, slug: "art")
                        screen = MockCategoryScreen()
                        subject.screen = screen
                        subject.set(subscribedCategories: [
                            Category.stub(["name": "Art"])
                            ])
                        expect(screen.categoryTitles) == ["All", "Art"]
                    }
                    it("is logged in with subscribed categories") {
                        subject = CategoryViewController(currentUser: User.stub(["followedCategoryIds": ["1"]]), slug: "art")
                        screen = MockCategoryScreen()
                        subject.screen = screen
                        subject.set(subscribedCategories: [
                            Category.stub(["name": "Art"])
                            ])
                        expect(screen.categoryTitles) == ["All", "Subscribed", "Art"]
                    }
                    it("is logged in with no subscribed categories") {
                        subject = CategoryViewController(currentUser: User.stub([:]), slug: "art")
                        screen = MockCategoryScreen()
                        subject.screen = screen
                        subject.set(subscribedCategories: [
                            Category.stub(["name": "Art"])
                            ])
                        expect(screen.categoryTitles) == ["All", "Art", InterfaceString.Discover.ZeroState]
                    }
                }
            }
        }
    }
}
