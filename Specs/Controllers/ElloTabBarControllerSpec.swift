
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

        describe("initialization") {

            beforeEach {
                subject = ElloTabBarController.instantiateFromStoryboard()
            }

            it("can be instantiated from storyboard") {
                expect(subject).notTo(beNil())
            }

            it("is a ElloTabBarController") {
                expect(subject).to(beAKindOf(ElloTabBarController.self))
            }

        }

        describe("-viewDidLoad") {

            beforeEach {
                subject = ElloTabBarController.instantiateFromStoryboard()
                _ = subject.view
            }

            it("sets friends as the selected tab") {
                if let navigationController = subject.selectedViewController as? ElloNavigationController {
                    navigationController.currentUser = User.stub(["username": "foo"])
                    if let firstController = navigationController.topViewController as? BaseElloViewController {
                        expect(firstController).to(beAKindOf(StreamContainerViewController.self))
                    }
                    else {
                        fail("navigation controller doesn't have a topViewController, or it isn't a BaseElloViewController")
                    }
                }
                else {
                    fail("tab bar controller does not have a selectedViewController, or it isn't a ElloNavigationController")
                }
            }

        }

        context("selecting tab bar items") {

            beforeEach {
                subject = ElloTabBarController.instantiateFromStoryboard()
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
                subject.tabBar(subject.tabBar, didSelect: child1.tabBarItem)
                expect(subject.selectedViewController).to(equal(child1))
                expect(child1.isViewLoaded).to(beTrue())
            }

            it("should load child2") {
                subject.tabBar(subject.tabBar, didSelect: child2.tabBarItem)
                expect(subject.selectedViewController).to(equal(child2))
                expect(child2.isViewLoaded).to(beTrue())
            }

            it("should load child3") {
                subject.tabBar(subject.tabBar, didSelect: child3.tabBarItem)
                expect(subject.selectedViewController).to(equal(child3))
                expect(child3.isViewLoaded).to(beTrue())
            }

            describe("tapping the item twice") {
                it("should pop to the root view controller") {
                    let vc1 = child2.topViewController
                    let vc2 = UIViewController()
                    child2.pushViewController(vc2, animated: false)

                    subject.tabBar(subject.tabBar, didSelect: child1.tabBarItem)
                    expect(subject.selectedViewController).to(equal(child1))

                    subject.tabBar(subject.tabBar, didSelect: child2.tabBarItem)
                    expect(subject.selectedViewController).to(equal(child2))
                    expect(child2.topViewController).to(equal(vc2))

                    subject.tabBar(subject.tabBar, didSelect: child2.tabBarItem)
                    expect(child2.topViewController).to(equal(vc1))
                }

                // BAH!  I HATE WRITING IOS SPECS SO MUCH!
                // this code DOES pass when tested by a human.  But when the
                // code is run synchronously, as in the spec, the view hierarchy
                // is not set, and the 'tapping twice' behavior doesn't change the content
                // offset all the way to 0.
                xit("should scroll to the top") {
                    showController(subject)
                    let vc = child1.topViewController
                    scrollView.contentOffset = CGPoint(x: 0, y: 200)

                    subject.tabBar(subject.tabBar, didSelect: child1.tabBarItem)
                    expect(subject.selectedViewController).to(equal(child1))
                    expect(child1.topViewController).to(equal(vc))

                    subject.tabBar(subject.tabBar, didSelect: child1.tabBarItem)
                    expect(child1.topViewController).to(equal(vc))
                    expect(scrollView.contentOffset).toEventually(equal(CGPoint(x: 0, y: 0)))
                }

                // :sad face:, same issue, the async UIScrollView doesn't play nicely
                xcontext("stream tab") {
                    context("red dot visible") {
                        it("posts a NewContentNotifications.reloadStreamContent"){
                            showController(subject)
                            var reloadPosted = false
                            subject.streamsDot?.isHidden = false
                            _ = NotificationObserver(notification: NewContentNotifications.reloadStreamContent) {
                                _ in
                                reloadPosted = true
                            }
                            let vc = child3.topViewController

                            subject.tabBar(subject.tabBar, didSelect: child3.tabBarItem)
                            expect(subject.selectedViewController).to(equal(child3))
                            expect(child3.topViewController).to(equal(vc))

                            subject.tabBar(subject.tabBar, didSelect: child3.tabBarItem)
                            expect(child3.topViewController).to(equal(vc))
                            expect(reloadPosted) == true
                        }
                    }
                }
            }

            describe("tapping notification item") {
                var responder: NotificationObserver!
                var responded = false
                var notificationsItem: UITabBarItem!

                beforeEach {
                    responder = NotificationObserver(notification: NewContentNotifications.reloadNotifications) { _ in
                        responded = true
                    }
                    subject = ElloTabBarController.instantiateFromStoryboard()
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

                    notificationsItem = subject.tabBar.items![ElloTab.notifications.rawValue]
                }

                afterEach {
                    responder.removeObserver()
                    responded = false
                }

                it("should not notify after one tap") {
                    subject.tabBar(subject.tabBar, didSelect: notificationsItem)
                    expect(responded) == false
                }

                it("should notify after two taps") {
                    subject.newNotificationsAvailable = true
                    subject.tabBar(subject.tabBar, didSelect: notificationsItem)
                    subject.tabBar(subject.tabBar, didSelect: notificationsItem)
                    expect(responded) == true
                }
            }
        }

        context("showing the narration") {
            var prevTabValues: [ElloTab: Bool?]!

            beforeEach {
                prevTabValues = [
                    ElloTab.discover: GroupDefaults[ElloTab.discover.narrationDefaultKey].bool,
                    ElloTab.notifications: GroupDefaults[ElloTab.notifications.narrationDefaultKey].bool,
                    ElloTab.stream: GroupDefaults[ElloTab.stream.narrationDefaultKey].bool,
                    ElloTab.profile: GroupDefaults[ElloTab.profile.narrationDefaultKey].bool,
                    ElloTab.omnibar: GroupDefaults[ElloTab.omnibar.narrationDefaultKey].bool
                ]

                subject = ElloTabBarController.instantiateFromStoryboard()
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
                expect(ElloTab.discover.narrationDefaultKey) == "ElloTabBarControllerDidShowNarrationDiscover"
                expect(ElloTab.notifications.narrationDefaultKey) == "ElloTabBarControllerDidShowNarrationNotifications"
                expect(ElloTab.stream.narrationDefaultKey) == "ElloTabBarControllerDidShowNarrationStream"
                expect(ElloTab.profile.narrationDefaultKey) == "ElloTabBarControllerDidShowNarrationProfile"
                expect(ElloTab.omnibar.narrationDefaultKey) == "ElloTabBarControllerDidShowNarrationOmnibar"
            }

            it("should set the narration values") {
                let tab = ElloTab.stream
                ElloTabBarController.didShowNarration(tab, false)
                expect(GroupDefaults[tab.narrationDefaultKey].bool).to(beFalse())
                ElloTabBarController.didShowNarration(tab, true)
                expect(GroupDefaults[tab.narrationDefaultKey].bool).to(beTrue())
            }
            it("should get the narration values") {
                let tab = ElloTab.stream
                GroupDefaults[tab.narrationDefaultKey] = false
                expect(ElloTabBarController.didShowNarration(tab)).to(beFalse())
                GroupDefaults[tab.narrationDefaultKey] = true
                expect(ElloTabBarController.didShowNarration(tab)).to(beTrue())
            }
            it("should NOT show the narrationView when changing to a tab that has already shown the narrationView") {
                ElloTabBarController.didShowNarration(.discover, true)
                ElloTabBarController.didShowNarration(.notifications, true)
                ElloTabBarController.didShowNarration(.stream, true)
                ElloTabBarController.didShowNarration(.profile, true)
                ElloTabBarController.didShowNarration(.omnibar, true)

                subject.tabBar(subject.tabBar, didSelect: child1.tabBarItem)
                expect(subject.selectedViewController).to(equal(child1))
                expect(subject.shouldShowNarration).to(beFalse())
                expect(subject.isShowingNarration).to(beFalse())
            }
            it("should show the narrationView when changing to a tab that hasn't shown the narrationView yet") {
                ElloTabBarController.didShowNarration(.discover, false)
                ElloTabBarController.didShowNarration(.notifications, false)
                ElloTabBarController.didShowNarration(.stream, false)
                ElloTabBarController.didShowNarration(.profile, false)
                ElloTabBarController.didShowNarration(.omnibar, false)

                subject.tabBar(subject.tabBar, didSelect: child1.tabBarItem)
                expect(subject.selectedViewController).to(equal(child1), description: "selectedViewController")
                expect(subject.shouldShowNarration).to(beTrue(), description: "shouldShowNarration")
                expect(subject.isShowingNarration).to(beTrue(), description: "isShowingNarration")
            }
        }

    }
}
