////
///  ProfileViewControllerSpec.swift
//

@testable import Ello
import Moya
import Quick
import Nimble


class ProfileViewControllerSpec: QuickSpec {
    class HasNavBarController: UIViewController, BottomBarController {
        var navigationBarsVisible: Bool? { return true }
        var bottomBarVisible: Bool { return true }
        var bottomBarHeight: CGFloat { return 44 }
        var bottomBarView: UIView { return UIView() }

        func setNavigationBarsVisible(_ visible: Bool, animated: Bool) {
        }

        override func addChildViewController(_ controller: UIViewController) {
            super.addChildViewController(controller)
            view.addSubview(controller.view)
        }
    }

    override func spec() {
        describe("ProfileViewController") {
            var currentUser: User!
            var otherUser: User!

            beforeEach {
                otherUser = User.stub(["id": "42"])
                ElloLinkedStore.shared.setObject(otherUser, forKey: otherUser.id, type: .usersType)
                currentUser = User.stub(["id": "currentUserId", "hasProfileData": true])
            }

            describe("contentInset") {
                var subject: ProfileViewController!

                beforeEach {
                    subject = ProfileViewController(userParam: otherUser.id)
                    subject.currentUser = currentUser
                    otherUser = subject.user

                    let parent = HasNavBarController()
                    parent.addChildViewController(subject)
                    showController(parent)
                }

                it("does update the top inset") {
                    expect(subject.streamViewController.contentInset.top) == 124
                }
            }

            context("when displaying the currentUser") {
                var subject: ProfileViewController!
                var screen: ProfileScreen!

                beforeEach {
                    subject = ProfileViewController(currentUser: currentUser)
                    subject.currentUser = currentUser
                    let nav = UINavigationController(rootViewController: UIViewController())
                    nav.pushViewController(subject, animated: false)
                    showController(nav)
                    screen = subject.view as? ProfileScreen
                }

                it("has grid/list and share buttons") {
                    expect(screen.navigationBar.rightItems.count) == 2
                }

                it("has back left nav button") {
                    expect(screen.navigationBar.leftItems.count) == 1
                }

                context("collaborateable and hireable don't affect currentUser profile") {
                    let expectations: [(Bool, Bool)] = [
                        (true, true),
                        (true, false),
                        (false, true),
                        (false, false),
                        ]
                    for (isCollaborateable, isHireable) in expectations {
                        context("user \(isCollaborateable ? "is" : "is not") collaborateable and \(isHireable ? "is" : "is not") hireable") {
                            beforeEach {
                                currentUser = User.stub([
                                    "isCollaborateable": isCollaborateable,
                                    "isHireable": isHireable,
                                    "hasProfileData": true
                                    ])
                                subject = ProfileViewController(currentUser: currentUser)
                                showController(subject)
                                screen = subject.view as? ProfileScreen
                            }
                            it("has hidden mentionButton") {
                                expect(screen.mentionButton.isHidden) == true
                            }
                            it("has hidden hireButton") {
                                expect(screen.hireButton.isHidden) == true
                            }
                        }
                    }
                }
            }

            context("when NOT displaying the currentUser") {
                var subject: ProfileViewController!
                var screen: ProfileScreen!

                beforeEach {
                    subject = ProfileViewController(userParam: otherUser.id)
                    subject.currentUser = currentUser
                    otherUser = subject.user
                    let nav = UINavigationController(rootViewController: UIViewController())
                    nav.pushViewController(subject, animated: false)
                    showController(nav)
                    screen = subject.view as? ProfileScreen
                }

                it("has grid/list and share right nav buttons") {
                    expect(screen.navigationBar.rightItems.count) == 2
                }

                it("has back and more left nav buttons") {
                    expect(screen.navigationBar.leftItems.count) == 2
                }

                let expectations: [(collaborateable: Bool, hireable: Bool, collaborateButton: Bool, hireButtonVisible: Bool, mentionButtonVisible: Bool)] = [
                    (collaborateable: true, hireable: true, collaborateButton: true, hireButtonVisible: true, mentionButtonVisible: false),
                    (collaborateable: true, hireable: false, collaborateButton: true, hireButtonVisible: false, mentionButtonVisible: false),
                    (collaborateable: false, hireable: true, collaborateButton: false, hireButtonVisible: true, mentionButtonVisible: false),
                    (collaborateable: false, hireable: false, collaborateButton: false, hireButtonVisible: false, mentionButtonVisible: true),
                    ]
                for (collaborateable, hireable, collaborateButton, hireButtonVisible, mentionButtonVisible) in expectations {
                    context("collaborateable \(collaborateable) and hireable \(hireable) affect profile buttons") {
                        beforeEach {
                            let userId = "1234"
                            let user: User = stub([
                                "id": userId,
                                "isCollaborateable": collaborateable,
                                "isHireable": hireable,
                                ])
                            ElloLinkedStore.shared.setObject(user, forKey: user.id, type: .usersType)

                            subject = ProfileViewController(userParam: userId)
                            subject.currentUser = currentUser
                            showController(subject)
                            screen = subject.view as? ProfileScreen
                        }

                        it("user \(collaborateable ? "is" : "is not") collaborateable") {
                            expect(subject.user?.isCollaborateable) == collaborateable
                        }
                        it("has \(collaborateButton ? "visible" : "hidden") collaborateButton") {
                            expect(screen.collaborateButton.isHidden) == !collaborateButton
                        }

                        it("user \(hireable ? "is" : "is not") hireable") {
                            expect(subject.user?.isHireable) == hireable
                        }
                        it("has \(hireButtonVisible ? "visible" : "hidden") hireButton") {
                            expect(screen.hireButton.isHidden) == !hireButtonVisible
                        }

                        it("has \(mentionButtonVisible ? "visible" : "hidden") mentionButton") {
                            expect(screen.mentionButton.isHidden) == !mentionButtonVisible
                        }
                    }
                }
            }

            context("when displaying a private user") {
                var subject: ProfileViewController!
                var screen: ProfileScreen!

                beforeEach {
                    let user: User = stub([
                        "hasSharingEnabled": false
                        ])
                    ElloLinkedStore.shared.setObject(user, forKey: user.id, type: .usersType)
                    subject = ProfileViewController(userParam: user.id)
                    subject.currentUser = currentUser
                    let nav = UINavigationController(rootViewController: UIViewController())
                    nav.pushViewController(subject, animated: false)
                    showController(nav)

                    screen = subject.screen as? ProfileScreen
                }

                it("has grid/list right nav buttons") {
                    expect(screen.navigationBar.rightItems.count) == 1
                }

                it("has back and more left nav buttons") {
                    expect(screen.navigationBar.leftItems.count) == 2
                }
            }

            describe("tapping more button") {
                var subject: ProfileViewController!

                beforeEach {
                    subject = ProfileViewController(userParam: otherUser.id)
                    subject.currentUser = currentUser
                    otherUser = subject.user
                    showController(subject)
                }

                it("launches the block modal") {
                    subject.moreButtonTapped()
                    let presentedVC = subject.presentedViewController
                    expect(presentedVC).notTo(beNil())
                    expect(presentedVC).to(beAKindOf(BlockUserModalViewController.self))
                }
            }


            context("with successful request") {
                var subject: ProfileViewController!

                beforeEach {
                    subject = ProfileViewController(userParam: otherUser.id)
                    subject.currentUser = currentUser
                    otherUser = subject.user
                    showController(subject)
                }

                describe("@moreButton") {
                    it("not selected block") {
                        otherUser.relationshipPriority = .inactive
                        subject.moreButtonTapped()
                        let presentedVC = subject.presentedViewController as! BlockUserModalViewController
                        presentedVC.updateRelationship(.block)
                        expect(otherUser.relationshipPriority) == RelationshipPriority.block
                    }

                    it("not selected mute") {
                        otherUser.relationshipPriority = .inactive
                        subject.moreButtonTapped()
                        let presentedVC = subject.presentedViewController as! BlockUserModalViewController
                        presentedVC.updateRelationship(.mute)
                        expect(otherUser.relationshipPriority) == RelationshipPriority.mute
                    }

                    it("selected block") {
                        otherUser.relationshipPriority = .block
                        subject.moreButtonTapped()
                        let presentedVC = subject.presentedViewController as! BlockUserModalViewController
                        presentedVC.updateRelationship(.inactive)
                        expect(otherUser.relationshipPriority) == RelationshipPriority.inactive
                    }

                    it("selected mute") {
                        otherUser.relationshipPriority = .mute
                        subject.moreButtonTapped()
                        let presentedVC = subject.presentedViewController as! BlockUserModalViewController
                        presentedVC.updateRelationship(.inactive)
                        expect(otherUser.relationshipPriority) == RelationshipPriority.inactive
                    }

                }
            }

            context("with failed request") {
                var subject: ProfileViewController!

                beforeEach {
                    subject = ProfileViewController(userParam: otherUser.id)
                    subject.currentUser = currentUser
                    otherUser = subject.user
                    showController(subject)
                    ElloProvider.moya = ElloProvider.ErrorStubbingProvider()
                }

                describe("@moreButton") {
                    it("not selected block") {
                        otherUser.relationshipPriority = .inactive
                        subject.moreButtonTapped()
                        let presentedVC = subject.presentedViewController as! BlockUserModalViewController
                        presentedVC.updateRelationship(.block)
                        expect(otherUser.relationshipPriority).to(equal(RelationshipPriority.inactive))
                    }

                    it("not selected mute") {
                        otherUser.relationshipPriority = .inactive
                        subject.moreButtonTapped()
                        let presentedVC = subject.presentedViewController as! BlockUserModalViewController
                        presentedVC.updateRelationship(.mute)
                        expect(otherUser.relationshipPriority).to(equal(RelationshipPriority.inactive))
                    }

                    it("selected block") {
                        otherUser.relationshipPriority = .block
                        subject.moreButtonTapped()
                        let presentedVC = subject.presentedViewController as! BlockUserModalViewController
                        presentedVC.updateRelationship(.inactive)
                        expect(otherUser.relationshipPriority).to(equal(RelationshipPriority.block))
                    }

                    it("selected mute") {
                        otherUser.relationshipPriority = .mute
                        subject.moreButtonTapped()
                        let presentedVC = subject.presentedViewController as! BlockUserModalViewController
                        presentedVC.updateRelationship(.inactive)
                        expect(otherUser.relationshipPriority).to(equal(RelationshipPriority.mute))
                    }
                }
            }

            context("logged out view") {
                var subject: ProfileViewController!
                var screen: ProfileScreen!

                beforeEach {
                    subject = ProfileViewController(userParam: otherUser.id)
                    subject.currentUser = nil
                    otherUser = subject.user
                    let nav = UINavigationController(rootViewController: UIViewController())
                    nav.pushViewController(subject, animated: false)
                    showController(nav)

                    screen = subject.screen as? ProfileScreen
                }

                it("should not show ellipses button in navigation") {
                    expect(screen.navigationBar.leftItems.count) == 1
                }
            }
        }
    }
}
