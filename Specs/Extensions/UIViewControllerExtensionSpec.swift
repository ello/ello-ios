////
///  UIViewControllerExtensionSpec.swift
//

@testable import Ello
import Quick
import Nimble


class UIViewControllerExtensionSpec: QuickSpec {
    override func spec() {
        describe("findViewController") {
            it("should find a navigation controller") {
                let controller = UIViewController()
                let navController = UINavigationController(rootViewController: controller)
                let tabBarController = UITabBarController()
                tabBarController.viewControllers = [navController]
                tabBarController.title = "foo"
                let found = controller.findViewController { vc in vc is UITabBarController }
                expect(found).to(equal(tabBarController))
            }

            it("should find a controller titled 'foo'") {
                let controller = UIViewController()
                let navController = UINavigationController(rootViewController: controller)
                let tabBarController = UITabBarController()
                tabBarController.viewControllers = [navController]
                tabBarController.title = "foo"
                let found = controller.findViewController { vc in vc.title == "foo" }
                expect(found).to(equal(tabBarController))
            }
        }
    }
}
