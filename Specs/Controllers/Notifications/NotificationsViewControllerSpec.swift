////
///  NotificationsViewControllerSpec.swift
//

@testable import Ello
import Quick
import Nimble


class FakeNavigationController: UINavigationController {
    var pushedViewController: UIViewController?

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushedViewController = viewController
        super.pushViewController(viewController, animated: false)
    }
}


class NotificationsViewControllerSpec: QuickSpec {
    override func spec() {
        describe("NotificationsViewController") {
            var subject: NotificationsViewController!

            beforeEach {
                subject = NotificationsViewController()
            }

            describe("can open notification links") {
                it("can open notifications/posts/12") {
                    let navigationController = FakeNavigationController(rootViewController: subject)
                    subject.respondToNotification(["posts", "12"])
                    expect(navigationController.children.count).to(equal(2))
                }
                it("can open notifications/users/12") {
                    let navigationController = FakeNavigationController(rootViewController: subject)
                    subject.respondToNotification(["users", "12"])
                    expect(navigationController.children.count).to(equal(2))
                }
                it("can handle unknown links") {
                    let navigationController = UINavigationController(rootViewController: subject)
                    subject.respondToNotification(["flibbity", "jibbet"])
                    expect(navigationController.children.count) == 1
                }
            }

            context("when receiving a reload notification") {
                it("should always reload") {
                    let navigationController = UINavigationController(rootViewController: subject)
                    showController(navigationController)
                    subject.hasNewContent = true
                    postNotification(NewContentNotifications.reloadNotifications, value: ())
                    expect(subject.hasNewContent) == false
                }
            }
        }
    }
}
