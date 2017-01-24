////
///  DeepLinkingSpec.swift
//

@testable import Ello
import Quick
import Nimble


class DeepLinkingSpec: QuickSpec {

    class FakeNavController: UINavigationController {

        var pushCalled = false
        var pushedVC: UIViewController?

        override func pushViewController(_ viewController: UIViewController, animated: Bool) {
            pushCalled = true
            pushedVC = viewController
        }
    }

    override func spec() {
        describe("DeepLinking") {

            var fakeNavController: FakeNavController!
            var fakeCurrentUser: User!

            beforeEach {
                fakeNavController = FakeNavController(nibName: nil, bundle: nil)
                fakeCurrentUser = User.stub([:])
            }

            describe("showDiscover()") {

                it("pushes a DiscoverAllCategoriesViewController") {
                    DeepLinking.showDiscover(navVC: fakeNavController, currentUser: fakeCurrentUser)

                    expect(fakeNavController.pushCalled) == true
                    expect(fakeNavController.pushedVC).to(beAnInstanceOf(DiscoverAllCategoriesViewController.self))
                }

                it("does not push a new DiscoverAllCategoriesViewController if DiscoverAllCategoriesViewController is being viewed") {
                    let existing = DiscoverAllCategoriesViewController()
                    fakeNavController.viewControllers = [existing]

                    DeepLinking.showDiscover(navVC: fakeNavController, currentUser: fakeCurrentUser)

                    expect(fakeNavController.pushCalled) == false
                    expect(fakeNavController.pushedVC).to(beNil())
                }
            }

            describe("showSettings()") {

                it("pushes a SettingsContainerViewController") {
                    DeepLinking.showSettings(navVC: fakeNavController, currentUser: fakeCurrentUser)

                    expect(fakeNavController.pushCalled) == true
                    expect(fakeNavController.pushedVC).to(beAnInstanceOf(SettingsContainerViewController.self))
                }
            }

            describe("showCategory()") {

                it("pushes a CategoryViewController") {
                    DeepLinking.showCategory(navVC: fakeNavController, currentUser: fakeCurrentUser, slug: "art")

                    expect(fakeNavController.pushCalled) == true
                    expect(fakeNavController.pushedVC).to(beAnInstanceOf(CategoryViewController.self))
                }

                it("uses existing CategoryViewController when deep linking to a new category") {
                    let existing = CategoryViewController(slug: "art")
                    let art = Category.stub(["slug" : "art"])
                    let design = Category.stub(["slug" : "design"])
                    existing.allCategories = [art, design]
                    fakeNavController.viewControllers = [existing]

                    DeepLinking.showCategory(navVC: fakeNavController, currentUser: fakeCurrentUser, slug: "design")

                    let catVC = fakeNavController.viewControllers.first as? CategoryViewController

                    expect(fakeNavController.pushCalled) == false
                    expect(fakeNavController.pushedVC).to(beNil())
                    expect(catVC).to(beAnInstanceOf(CategoryViewController.self))
                    expect(catVC?.slug) == "design"
                }

                it("does not push a new CategoryViewController if already on that screen") {
                    let existing = CategoryViewController(slug: "art")
                    fakeNavController.viewControllers = [existing]

                    DeepLinking.showCategory(navVC: fakeNavController, currentUser: fakeCurrentUser, slug: "art")

                    expect(fakeNavController.pushCalled) == false
                    expect(fakeNavController.pushedVC).to(beNil())
                }
            }

            describe("showProfile()") {

                it("pushes a ProfileViewController") {
                    DeepLinking.showProfile(navVC: fakeNavController, currentUser: fakeCurrentUser, username: "666")

                    expect(fakeNavController.pushCalled) == true
                    expect(fakeNavController.pushedVC).to(beAnInstanceOf(ProfileViewController.self))
                }

                it("does not push a new ProfileViewController if ProfileViewController is being viewed") {
                    let existing = ProfileViewController(userParam: "~666", username: "666")
                    fakeNavController.viewControllers = [existing]

                    DeepLinking.showProfile(navVC: fakeNavController, currentUser: fakeCurrentUser, username: "666")

                    expect(fakeNavController.pushCalled) == false
                    expect(fakeNavController.pushedVC).to(beNil())
                }
            }

            describe("showPostDetail()") {

                it("pushes a PostDetailViewController") {
                    DeepLinking.showPostDetail(navVC: fakeNavController, currentUser: fakeCurrentUser, token: "123")

                    expect(fakeNavController.pushCalled) == true
                    expect(fakeNavController.pushedVC).to(beAnInstanceOf(PostDetailViewController.self))
                }

                it("pushes a new PostDetailViewController if viewing another post") {
                    let existing = PostDetailViewController(postParam: "~123")
                    fakeNavController.viewControllers = [existing]

                    DeepLinking.showPostDetail(navVC: fakeNavController, currentUser: fakeCurrentUser, token: "something-different")

                    expect(fakeNavController.pushCalled) == true
                    expect(fakeNavController.pushedVC).to(beAnInstanceOf(PostDetailViewController.self))
                }

                it("does not push a new PostDetailViewController if already viewing that post") {
                    let existing = PostDetailViewController(postParam: "~123")
                    fakeNavController.viewControllers = [existing]

                    DeepLinking.showPostDetail(navVC: fakeNavController, currentUser: fakeCurrentUser, token: "123")

                    expect(fakeNavController.pushCalled) == false
                    expect(fakeNavController.pushedVC).to(beNil())
                }
            }

            describe("showSearch()") {

                it("pushes a SearchViewController") {
                    DeepLinking.showSearch(navVC: fakeNavController, currentUser: fakeCurrentUser, terms: "cats")

                    expect(fakeNavController.pushCalled) == true
                    expect(fakeNavController.pushedVC).to(beAnInstanceOf(SearchViewController.self))
                }

                it("does not push a new SearchViewController if SearchViewController is being viewed") {
                    let existing = SearchViewController()
                    fakeNavController.viewControllers = [existing]

                    DeepLinking.showSearch(navVC: fakeNavController, currentUser: fakeCurrentUser, terms: "cats")

                    expect(fakeNavController.pushCalled) == false
                    expect(fakeNavController.pushedVC).to(beNil())
                }

                it("uses an existing SearchViewController if SearchViewController is being viewed") {
                    let existing = SearchViewController()
                    existing.searchForPosts("dogs")
                    fakeNavController.viewControllers = [existing]

                    expect(existing.searchText) == "dogs"

                    DeepLinking.showSearch(navVC: fakeNavController, currentUser: fakeCurrentUser, terms: "cats")

                    expect(existing.searchText) == "cats"
                    expect(fakeNavController.pushedVC).to(beNil())
                }
            }

            describe("alreadyOnCurrentCategory()") {

                it("returns true if the category is being shown") {
                    let existing = CategoryViewController(slug: "art")
                    fakeNavController.viewControllers = [existing]

                    let onCategory = DeepLinking.alreadyOnCurrentCategory(navVC: fakeNavController, slug: "art")

                    expect(onCategory) == true
                }

                it("returns false if viewing a different category") {
                    let existing = CategoryViewController(slug: "art")
                    fakeNavController.viewControllers = [existing]

                    let onCategory = DeepLinking.alreadyOnCurrentCategory(navVC: fakeNavController, slug: "different-category")

                    expect(onCategory) == false
                }

                it("returns false if not viewing any category") {
                    let onCategory = DeepLinking.alreadyOnCurrentCategory(navVC: fakeNavController, slug: "art")

                    expect(onCategory) == false
                }
            }

            describe("alreadyOnUserProfile()") {

                it("returns true if the profile is being shown") {
                    let existing = ProfileViewController(userParam: "~666", username: "666")
                    fakeNavController.viewControllers = [existing]

                    let onProfile = DeepLinking.alreadyOnUserProfile(navVC: fakeNavController, userParam: "~666")

                    expect(onProfile) == true
                }

                it("returns false if viewing a different profile") {
                    let existing = ProfileViewController(userParam: "~888", username: "888")
                    fakeNavController.viewControllers = [existing]

                    let onProfile = DeepLinking.alreadyOnUserProfile(navVC: fakeNavController, userParam: "~666")

                    expect(onProfile) == false
                }

                it("returns false if not viewing any profile") {
                    let onProfile = DeepLinking.alreadyOnUserProfile(navVC: fakeNavController, userParam: "other")

                    expect(onProfile) == false
                }
            }

            describe("alreadyOnPostDetail()") {

                it("returns true if the post detail is being shown") {
                    let existing = PostDetailViewController(postParam: "~123")
                    fakeNavController.viewControllers = [existing]

                    let onPostDetail = DeepLinking.alreadyOnPostDetail(navVC: fakeNavController, postParam: "~123")

                    expect(onPostDetail) == true
                }

                it("returns false if viewing a different post detail") {
                    let existing = PostDetailViewController(postParam: "~123")
                    fakeNavController.viewControllers = [existing]

                    let onPostDetail = DeepLinking.alreadyOnPostDetail(navVC: fakeNavController, postParam: "~999")

                    expect(onPostDetail) == false
                }

                it("returns false if not viewing any post detail") {
                    let onPostDetail = DeepLinking.alreadyOnPostDetail(navVC: fakeNavController, postParam: "other-param")

                    expect(onPostDetail) == false
                }
            }
        }
    }
}

