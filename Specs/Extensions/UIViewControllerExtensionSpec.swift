////
///  UIViewControllerExtensionSpec.swift
//

@testable import Ello
import Quick
import Nimble


class UIViewControllerExtensionSpec: QuickSpec {
    override func spec() {
        describe("UIViewController") {
            describe("findParentController") {
                it("should find a parent tab bar controller") {
                    let controller = UIViewController()
                    let navController = UINavigationController(rootViewController: controller)
                    let tabBarController = UITabBarController()
                    tabBarController.viewControllers = [navController]
                    tabBarController.title = "foo"
                    let found: UITabBarController? = controller.findParentController()
                    expect(found).to(equal(tabBarController))
                }

                it("should find a parent controller titled 'foo'") {
                    let controller = UIViewController()
                    let navController = UINavigationController(rootViewController: controller)
                    let tabBarController = UITabBarController()
                    tabBarController.viewControllers = [navController]
                    tabBarController.title = "foo"
                    let found: UIViewController? = controller.findParentController { vc in
                        vc.title == "foo"
                    }
                    expect(found).to(equal(tabBarController))
                }
            }
        }
    }
}
