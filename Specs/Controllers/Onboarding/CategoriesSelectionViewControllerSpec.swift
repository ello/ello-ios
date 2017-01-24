////
///  CategoriesSelectionViewControllerSpec.swift
//

@testable import Ello
import Quick
import Nimble


class CategoriesSelectionViewControllerSpec: QuickSpec {
    override func spec() {
        var subject: CategoriesSelectionViewController!
        beforeEach {
            subject = CategoriesSelectionViewController()
            subject.onboardingData = OnboardingData()
        }
        describe("CategoriesSelectionViewController") {
            var categories: [Ello.Category]!
            beforeEach {
                let category: Ello.Category = stub(["name": "Art"])
                categories = [category]
                subject.categoriesSelectionChanged(selection: categories)
            }

            it("saves selected categories from streamViewController") {
                expect(subject.selectedCategories) == categories
            }
            it("submitting categories saves categories to onboardingData") {
                subject.onboardingWillProceed(abort: false, proceedClosure: { _ in })
                expect(subject.onboardingData.categories) == categories
            }
        }
    }
}
