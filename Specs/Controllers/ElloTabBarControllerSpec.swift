////
///  ElloTabBarControllerSpec.swift
//

@testable import Ello
import SwiftyUserDefaults
import Quick
import Nimble


class ElloTabBarControllerSpec: QuickSpec {

    override func spec() {
        var subject: ElloTabBarController!
        var tabBarItem: UITabBarItem
        let child1root = UIViewController()
        let scrollView = UIScrollView()
        scrollView.contentSize = CGSize(width: 2000, height: 2000)
        child1root.view.addSubview(scrollView)
        let child1 = UINavigationController(rootViewController: child1root)
        tabBarItem = child1.tabBarItem
        tabBarItem.image = UIImage.imageWithColor(.black)
        tabBarItem.selectedImage = UIImage.imageWithColor(.black)

        let child2 = UINavigationController(rootViewController: UIViewController())
        tabBarItem = child2.tabBarItem
        tabBarItem.image = UIImage.imageWithColor(.black)
        tabBarItem.selectedImage = UIImage.imageWithColor(.black)

        let child3 = UINavigationController(rootViewController: UIViewController())
        tabBarItem = child3.tabBarItem
        tabBarItem.image = UIImage.imageWithColor(.black)
        tabBarItem.selectedImage = UIImage.imageWithColor(.black)

        let child4 = UINavigationController(rootViewController: UIViewController())
        tabBarItem = child4.tabBarItem
        tabBarItem.image = UIImage.imageWithColor(.black)
        tabBarItem.selectedImage = UIImage.imageWithColor(.black)

        let child5 = UINavigationController(rootViewController: UIViewController())
        tabBarItem = child5.tabBarItem
        tabBarItem.image = UIImage.imageWithColor(.black)
        tabBarItem.selectedImage = UIImage.imageWithColor(.black)

        describe("ElloTabBarController") {

            beforeEach {
                subject = ElloTabBarController()
                subject.currentUser = User.stub(["username": "foo"])
                _ = subject.view
            }

            it("sets home as the selected tab") {
                if let navigationController = subject.selectedViewController as? ElloNavigationController {
                    navigationController.currentUser = User.stub(["username": "foo"])
                    if let firstController = navigationController.topViewController as? BaseElloViewController {
                        expect(firstController).to(beAKindOf(HomeViewController.self))
                    }
                    else {
                        fail("navigation controller doesn't have a topViewController, or it isn't a BaseElloViewController")
                    }
                }
                else {
                    fail("tab bar controller does not have a selectedViewController, or it isn't a ElloNavigationController")
                }
            }

            context("selecting tab bar items") {

                beforeEach {
                    subject = ElloTabBarController()
                    subject.currentUser = User.stub(["username": "foo"])
                    let children = subject.childViewControllers
                    for child in children {
                        child.removeFromParentViewController()
                    }
                    subject.addChildViewController(child1)
                    subject.addChildViewController(child2)
                    subject.addChildViewController(child3)
                    subject.addChildViewController(child4)
                    subject.addChildViewController(child5)
                    _ = subject.view
                }

                it("should load child1") {
                    subject.tabBar(subject.tabBar, didSelect: ElloTab(rawValue: 0)!)
                    expect(subject.selectedViewController).to(equal(child1))
                    expect(child1.isViewLoaded).to(beTrue())
                }

                it("should load child2") {
                    subject.tabBar(subject.tabBar, didSelect: ElloTab(rawValue: 1)!)
                    expect(subject.selectedViewController).to(equal(child2))
                    expect(child2.isViewLoaded).to(beTrue())
                }

                it("should load child3") {
                    subject.tabBar(subject.tabBar, didSelect: ElloTab(rawValue: 2)!)
                    expect(subject.selectedViewController).to(equal(child3))
                    expect(child3.isViewLoaded).to(beTrue())
                }

                describe("tapping the item twice") {
                    it("should pop to the root view controller") {
                        let vc1 = child2.topViewController
                        let vc2 = UIViewController()
                        child2.pushViewController(vc2, animated: false)

                        subject.tabBar(subject.tabBar, didSelect: ElloTab(rawValue: 0)!)
                        expect(subject.selectedViewController).to(equal(child1))

                        subject.tabBar(subject.tabBar, didSelect: ElloTab(rawValue: 1)!)
                        expect(subject.selectedViewController).to(equal(child2))
                        expect(child2.topViewController).to(equal(vc2))

                        subject.tabBar(subject.tabBar, didSelect: ElloTab(rawValue: 1)!)
                        expect(child2.topViewController).to(equal(vc1))
                    }
                }

                describe("tapping notification item") {
                    var responder: NotificationObserver!
                    var responded = false

                    beforeEach {
                        responder = NotificationObserver(notification: NewContentNotifications.reloadNotifications) {
                            responded = true
                        }
                        subject = ElloTabBarController()
                        subject.currentUser = User.stub(["username": "foo"])
                        let children = subject.childViewControllers
                        for child in children {
                            child.removeFromParentViewController()
                        }
                        subject.addChildViewController(child1)
                        subject.addChildViewController(child2)
                        subject.addChildViewController(child3)
                        subject.addChildViewController(child4)
                        subject.addChildViewController(child5)
                        subject.selectedTab = .discover
                    }

                    afterEach {
                        responder.removeObserver()
                        responded = false
                    }

                    it("should not notify after one tap") {
                        subject.tabBar(subject.tabBar, didSelect: .notifications)
                        expect(responded) == false
                    }

                    it("should notify after two taps") {
                        subject.newNotificationsAvailable = true
                        subject.tabBar(subject.tabBar, didSelect: .notifications)
                        subject.tabBar(subject.tabBar, didSelect: .notifications)
                        expect(responded) == true
                    }
                }
            }

            context("showing the narration") {
                var prevTabValues: [ElloTab: Bool?]!

                beforeEach {
                    prevTabValues = [
                        ElloTab.home: GroupDefaults[ElloTab.home.narrationDefaultKey].bool,
                        ElloTab.discover: GroupDefaults[ElloTab.discover.narrationDefaultKey].bool,
                        ElloTab.omnibar: GroupDefaults[ElloTab.omnibar.narrationDefaultKey].bool,
                        ElloTab.notifications: GroupDefaults[ElloTab.notifications.narrationDefaultKey].bool,
                        ElloTab.profile: GroupDefaults[ElloTab.profile.narrationDefaultKey].bool
                    ]

                    subject = ElloTabBarController()
                    subject.currentUser = User.stub(["username": "foo"])
                    let children = subject.childViewControllers
                    for child in children {
                        child.removeFromParentViewController()
                    }
                    subject.addChildViewController(child1)
                    subject.addChildViewController(child2)
                    subject.addChildViewController(child3)
                    subject.addChildViewController(child4)
                    subject.addChildViewController(child5)
                    _ = subject.view
                }

                afterEach {
                    for (tab, value) in prevTabValues {
                        GroupDefaults[tab.narrationDefaultKey] = value
                    }
                }

                it("should never change the key") {
                    expect(ElloTab.home.narrationDefaultKey) == "ElloTabBarControllerDidShowNarrationStream"
                    expect(ElloTab.discover.narrationDefaultKey) == "ElloTabBarControllerDidShowNarrationDiscover"
                    expect(ElloTab.omnibar.narrationDefaultKey) == "ElloTabBarControllerDidShowNarrationOmnibar"
                    expect(ElloTab.notifications.narrationDefaultKey) == "ElloTabBarControllerDidShowNarrationNotifications"
                    expect(ElloTab.profile.narrationDefaultKey) == "ElloTabBarControllerDidShowNarrationProfile"
                }

                it("should set the narration values") {
                    let tab = ElloTab.home
                    ElloTabBarController.didShowNarration(tab, false)
                    expect(GroupDefaults[tab.narrationDefaultKey].bool).to(beFalse())
                    ElloTabBarController.didShowNarration(tab, true)
                    expect(GroupDefaults[tab.narrationDefaultKey].bool).to(beTrue())
                }
                it("should get the narration values") {
                    let tab = ElloTab.home
                    GroupDefaults[tab.narrationDefaultKey] = false
                    expect(ElloTabBarController.didShowNarration(tab)).to(beFalse())
                    GroupDefaults[tab.narrationDefaultKey] = true
                    expect(ElloTabBarController.didShowNarration(tab)).to(beTrue())
                }
                it("should NOT show the narrationView when changing to a tab that has already shown the narrationView") {
                    ElloTabBarController.didShowNarration(.home, true)
                    ElloTabBarController.didShowNarration(.discover, true)
                    ElloTabBarController.didShowNarration(.omnibar, true)
                    ElloTabBarController.didShowNarration(.notifications, true)
                    ElloTabBarController.didShowNarration(.profile, true)

                    subject.tabBar(subject.tabBar, didSelect: ElloTab(rawValue: 1)!)
                    expect(subject.selectedViewController).to(equal(child2))
                    expect(subject.shouldShowNarration).to(beFalse())
                    expect(subject.isShowingNarration).to(beFalse())
                }
                it("should show the narrationView when changing to a tab that hasn't shown the narrationView yet") {
                    ElloTabBarController.didShowNarration(.home, false)
                    ElloTabBarController.didShowNarration(.discover, false)
                    ElloTabBarController.didShowNarration(.omnibar, false)
                    ElloTabBarController.didShowNarration(.notifications, false)
                    ElloTabBarController.didShowNarration(.profile, false)

                    subject.tabBar(subject.tabBar, didSelect: ElloTab(rawValue: 0)!)
                    expect(subject.selectedViewController).to(equal(child1), description: "selectedViewController")
                    expect(subject.shouldShowNarration).to(beTrue(), description: "shouldShowNarration")
                    expect(subject.isShowingNarration).to(beTrue(), description: "isShowingNarration")
                }
            }
        }
    }
}
