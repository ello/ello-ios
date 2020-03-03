////
///  BaseElloViewControllerSpec.swift
//

@testable import Ello
import Quick
import Nimble


class BaseElloViewControllerSpec: QuickSpec {
    override func spec() {
        describe("BaseElloViewController") {
            describe("isRootViewController") {
                context("is the rootViewController") {
                    it("isRootViewController should return 'true'") {
                        let controller = NotificationsViewController()
                        let navigationController = UINavigationController(
                            rootViewController: controller
                        )

                        expect(controller.isRootViewController()) == true
                        expect(navigationController).toNot(beNil())
                    }
                }

                context("is somewhere in the navigation stack") {
                    it("isRootViewController should return 'false'") {
                        let anyController = UIViewController()
                        let controller = NotificationsViewController()
                        let navController = UINavigationController(
                            rootViewController: anyController
                        )
                        navController.pushViewController(controller, animated: false)
                        expect(controller.isRootViewController()) == false
                    }
                }
            }
        }
    }
}
