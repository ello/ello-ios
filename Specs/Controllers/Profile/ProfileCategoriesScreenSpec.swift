////
///  ProfileCategoriesScreenSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileCategoriesScreenSpec: QuickSpec {

    override func spec() {

        describe("ProfileCategoriesScreen") {

            context("snapshots") {

                it("renders correctly with 1 category") {
                    let categories = [
                        Category.stub(["name": "Photography", "order": 1])
                    ]

                    let subject = ProfileCategoriesScreen(categories: categories)
                    showView(subject)
                    expectValidSnapshot(subject, named: "ProfileCategoriesScreen_1", device: .phone6_Portrait)
                }

                it("renders correctly with more2 categories") {
                    let categories = [
                        Category.stub(["name": "Photography", "order": 1]),
                        Category.stub(["name": "Art", "order": 2])
                    ]

                    let subject = ProfileCategoriesScreen(categories: categories)
                    showView(subject)
                    expectValidSnapshot(subject, named: "ProfileCategoriesScreen_2", device: .phone6_Portrait)
                }

                it("renders correctly with 3 categories") {
                    let categories = [
                        Category.stub(["name": "Photography", "order": 1]),
                        Category.stub(["name": "Art", "order": 2]),
                        Category.stub(["name": "Painting", "order": 2])
                    ]

                    let subject = ProfileCategoriesScreen(categories: categories)
                    showView(subject)
                    expectValidSnapshot(subject, named: "ProfileCategoriesScreen_3", device: .phone6_Portrait)
                }

                it("renders correctly with more than 3 categories") {
                    let categories = [
                        Category.stub(["name": "Photography", "order": 1]),
                        Category.stub(["name": "Art", "order": 2]),
                        Category.stub(["name": "Painting", "order": 2]),
                        Category.stub(["name": "GIFs", "order": 2]),
                        Category.stub(["name": "Fashion", "order": 1]),
                        Category.stub(["name": "Climbing", "order": 2]),
                        Category.stub(["name": "Drawing", "order": 2]),
                        Category.stub(["name": "Sculpture", "order": 2])
                    ]

                    let subject = ProfileCategoriesScreen(categories: categories)
                    showView(subject)
                    expectValidSnapshot(subject, named: "ProfileCategoriesScreen_3_plus", device: .phone6_Portrait)
                }
            }
        }
    }
}


