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
            let currentUser: User = stub([:])

            describe("contentInset") {
                var subject: ProfileViewController!
                beforeEach {
                    subject = ProfileViewController(userParam: "42")
                    subject.currentUser = currentUser

                    let parent = HasNavBarController()
                    parent.addChildViewController(subject)
                    showController(parent)
                }

                it("does update the top inset") {
                    expect(subject.streamViewController.contentInset.top) == 128
                }
            }

            context("when displaying the currentUser") {
                var currentUser: User!
                var subject: ProfileViewController!
                var screen: ProfileScreen!

                beforeEach {
                    currentUser = User.stub(["id": "42"])
                    subject = ProfileViewController(currentUser: currentUser)
                    subject.currentUser = currentUser
                    let nav = UINavigationController(rootViewController: UIViewController())
                    nav.pushViewController(subject, animated: false)
                    showController(nav)
                    screen = subject.view as! ProfileScreen
                }

                it("has grid/list and share buttons") {
                    let rightButtons = subject.elloNavigationItem.rightBarButtonItems
                    expect(rightButtons?.count ?? 0) == 2
                }

                it("has back left nav button") {
                    expect(subject.elloNavigationItem.leftBarButtonItems?.count) == 2
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
                                currentUser = User.stub(["id": "42", "isCollaborateable": isCollaborateable, "isHireable": isHireable])
                                subject = ProfileViewController(currentUser: currentUser)
                                subject.currentUser = currentUser
                                showController(subject)
                                screen = subject.view as! ProfileScreen
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
                var currentUser: User!
                var subject: ProfileViewController!
                var screen: ProfileScreen!

                beforeEach {
                    currentUser = User.stub(["id": "not42"])
                    subject = ProfileViewController(userParam: "42")
                    subject.currentUser = currentUser
                    let nav = UINavigationController(rootViewController: UIViewController())
                    nav.pushViewController(subject, animated: false)
                    showController(nav)
                    screen = subject.view as! ProfileScreen
                }

                it("has grid/list and share right nav buttons") {
                    expect(subject.elloNavigationItem.rightBarButtonItems?.count) == 2
                }

                it("has back and more left nav buttons") {
                    expect(subject.elloNavigationItem.leftBarButtonItems?.count) == 4
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
                            ElloProvider.sharedProvider = ElloProvider.RecordedStubbingProvider([
                                RecordedResponse(endpoint: .userStream(userParam: "any"), responseClosure: { _ in
                                    let data = stubbedData("users_user_details")
                                    var json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                                    var user = json["users"] as! [String: Any]
                                    user["is_collaborateable"] = collaborateable
                                    user["is_hireable"] = hireable
                                    json["users"] = user
                                    let modData = try! JSONSerialization.data(withJSONObject: json, options: [])
                                    return .networkResponse(200, modData)
                                }),
                                ])

                            currentUser = User.stub([:])
                            subject = ProfileViewController(userParam: "any")
                            subject.currentUser = currentUser
                            showController(subject)
                            screen = subject.view as! ProfileScreen
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
                var currentUser: User!
                var subject: ProfileViewController!

                beforeEach {
                    ElloProvider.sharedProvider = ElloProvider.RecordedStubbingProvider([
                        RecordedResponse(endpoint: .userStream(userParam: "50"), response: .networkResponse(200,
                            stubbedData("profile__no_sharing")
                            )),
                        ])

                    currentUser = User.stub(["id": "not50"])
                    subject = ProfileViewController(userParam: "50")
                    subject.currentUser = currentUser
                    let nav = UINavigationController(rootViewController: UIViewController())
                    nav.pushViewController(subject, animated: false)
                    showController(nav)
                }

                it("has grid/list right nav buttons") {
                    expect(subject.elloNavigationItem.rightBarButtonItems?.count) == 1
                }

                it("has back and more left nav buttons") {
                    expect(subject.elloNavigationItem.leftBarButtonItems?.count) == 4
                }
            }

            describe("tapping more button") {
                var user: User!
                var subject: ProfileViewController!


                beforeEach {
                    user = User.stub(["id": "42"])
                    subject = ProfileViewController(userParam: user.id)
                    subject.currentUser = currentUser
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
                var user: User!
                var subject: ProfileViewController!

                beforeEach {
                    subject = ProfileViewController(userParam: "42")
                    subject.currentUser = currentUser
                    showController(subject)
                    user = subject.user!
                }

                describe("@moreButton") {
                    it("not selected block") {
                        user.relationshipPriority = .inactive
                        subject.moreButtonTapped()
                        let presentedVC = subject.presentedViewController as! BlockUserModalViewController
                        presentedVC.updateRelationship(.block)
                        expect(user.relationshipPriority) == RelationshipPriority.block
                    }

                    it("not selected mute") {
                        user.relationshipPriority = .inactive
                        subject.moreButtonTapped()
                        let presentedVC = subject.presentedViewController as! BlockUserModalViewController
                        presentedVC.updateRelationship(.mute)
                        expect(user.relationshipPriority) == RelationshipPriority.mute
                    }

                    it("selected block") {
                        user.relationshipPriority = .block
                        subject.moreButtonTapped()
                        let presentedVC = subject.presentedViewController as! BlockUserModalViewController
                        presentedVC.updateRelationship(.inactive)
                        expect(user.relationshipPriority) == RelationshipPriority.inactive
                    }

                    it("selected mute") {
                        user.relationshipPriority = .mute
                        subject.moreButtonTapped()
                        let presentedVC = subject.presentedViewController as! BlockUserModalViewController
                        presentedVC.updateRelationship(.inactive)
                        expect(user.relationshipPriority) == RelationshipPriority.inactive
                    }

                }
            }

            context("with failed request") {
                var user: User!
                var subject: ProfileViewController!

                beforeEach {
                    subject = ProfileViewController(userParam: "42")
                    subject.currentUser = currentUser
                    showController(subject)
                    user = subject.user!
                    ElloProvider.sharedProvider = ElloProvider.ErrorStubbingProvider()
                }

                describe("@moreButton") {
                    it("not selected block") {
                        user.relationshipPriority = .inactive
                        subject.moreButtonTapped()
                        let presentedVC = subject.presentedViewController as! BlockUserModalViewController
                        presentedVC.updateRelationship(.block)
                        expect(user.relationshipPriority).to(equal(RelationshipPriority.inactive))
                    }

                    it("not selected mute") {
                        user.relationshipPriority = .inactive
                        subject.moreButtonTapped()
                        let presentedVC = subject.presentedViewController as! BlockUserModalViewController
                        presentedVC.updateRelationship(.mute)
                        expect(user.relationshipPriority).to(equal(RelationshipPriority.inactive))
                    }

                    it("selected block") {
                        user.relationshipPriority = .block
                        subject.moreButtonTapped()
                        let presentedVC = subject.presentedViewController as! BlockUserModalViewController
                        presentedVC.updateRelationship(.inactive)
                        expect(user.relationshipPriority).to(equal(RelationshipPriority.block))
                    }

                    it("selected mute") {
                        user.relationshipPriority = .mute
                        subject.moreButtonTapped()
                        let presentedVC = subject.presentedViewController as! BlockUserModalViewController
                        presentedVC.updateRelationship(.inactive)
                        expect(user.relationshipPriority).to(equal(RelationshipPriority.mute))
                    }
                }
            }

            context("logged out view") {
                var subject: ProfileViewController!

                beforeEach {
                    subject = ProfileViewController(userParam: "42")
                    subject.currentUser = nil
                    let nav = UINavigationController(rootViewController: UIViewController())
                    nav.pushViewController(subject, animated: false)
                    showController(nav)
                }

                it("should not show ellipses button in navigation") {
                    let elloNavigationItem = subject.elloNavigationItem
                    let leftButtons = elloNavigationItem.leftBarButtonItems
                    expect(leftButtons?.count) == 3
                }
            }
        }
    }
}
