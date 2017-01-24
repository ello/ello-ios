////
///  ElloNavigationControllerSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ElloNavigationControllerSpec: QuickSpec {
    override func spec() {
        var controller = ElloNavigationController()

        describe("NotificationsViewController NavigationController") {
            beforeEach() {
                controller = UIStoryboard.storyboardWithId(.notifications) as! ElloNavigationController
                controller.currentUser = User.stub(["id": "fakeuser"])
            }

            it("has a tab bar item") {
                expect(controller.tabBarItem).notTo(beNil())
            }

            it("has a selected tab bar item") {
               expect(controller.tabBarItem!.selectedImage).notTo(beNil())
            }
        }

        describe("ProfileViewController NavigationController") {
            beforeEach() {
                controller = UIStoryboard.storyboardWithId(.profile) as! ElloNavigationController
                controller.currentUser = User.stub(["id": "fakeuser"])
            }

            it("has a tab bar item") {
                expect(controller.tabBarItem).notTo(beNil())
            }

            it("has a selected tab bar item") {
               expect(controller.tabBarItem!.selectedImage).notTo(beNil())
            }
        }

        describe("OmnibarViewController NavigationController") {
            beforeEach() {
                controller = UIStoryboard.storyboardWithId(.omnibar) as! ElloNavigationController
                controller.currentUser = User.stub(["id": "fakeuser"])
            }

            it("has a tab bar item") {
                expect(controller.tabBarItem).notTo(beNil())
            }

            it("has a selected tab bar item") {
               expect(controller.tabBarItem!.selectedImage).notTo(beNil())
            }
        }
    }
}
