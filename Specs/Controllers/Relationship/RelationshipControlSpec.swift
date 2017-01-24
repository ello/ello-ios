////
///  RelationshipControlSpec.swift
//

@testable import Ello
import Quick
import Nimble
import Moya
import Nimble_Snapshots


class RelationshipControlSpec: QuickSpec {
    override func spec() {
        describe("RelationshipControl") {
            var subject: RelationshipControl!
            var presentingController: UIViewController!
            var relationshipController: RelationshipController!
            beforeEach {
                subject = RelationshipControl()
                presentingController = UIViewController()
                showController(presentingController)
                relationshipController = RelationshipController(presentingController: presentingController)
                subject.relationshipDelegate = relationshipController
            }

            describe("snapshots") {
                let relationships: [(RelationshipControlStyle, RelationshipPriority)] = [
                    (.default, .following),
                    (.default, .starred),
                    (.default, .mute),
                    (.default, .none),
                    (.profileView, .following),
                    (.profileView, .starred),
                    (.profileView, .mute),
                    (.profileView, .none),
                ]
                for (style, relationship) in relationships {
                    it("setting style to \(style) and relationshipPriority to \(relationship)") {
                        subject.style = style
                        subject.relationshipPriority = relationship
                        expectValidSnapshot(subject, named: "style_\(style)_relationshipPriority_\(relationship)", device: .custom(subject.intrinsicContentSize))
                    }
                }
            }

            describe("intrinsicContentSize()") {
                it("should calculate when showStarButton=false") {
                    subject.showStarButton = false
                    let expectedSize = CGSize(width: 105, height: 30)
                    expect(subject.intrinsicContentSize) == expectedSize
                    subject.frame = CGRect(origin: .zero, size: expectedSize)
                    subject.layoutIfNeeded()
                    expect(subject.starButton.frame) == CGRect.zero
                    expect(subject.followingButton.frame) == CGRect(x: 0, y: 0, width: 105, height: 30)
                }
                it("should calculate when showStarButton=true") {
                    subject.showStarButton = true
                    let expectedSize = CGSize(width: 142, height: 30)
                    expect(subject.intrinsicContentSize) == expectedSize
                    subject.frame = CGRect(origin: .zero, size: expectedSize)
                    subject.layoutIfNeeded()
                    expect(subject.starButton.frame) == CGRect(x: 112, y: 0, width: 30, height: 30)
                    expect(subject.followingButton.frame) == CGRect(x: 0, y: 0, width: 105, height: 30)
                }
            }

            describe("button targets") {

                context("not muted") {

                    describe("tapping the following button") {

                        for relationshipPriority in [RelationshipPriority.inactive, RelationshipPriority.none, RelationshipPriority.null] {
                            context("RelationshipPriority.\(relationshipPriority)") {

                                it("unfollows the user") {
                                    subject.relationshipPriority = relationshipPriority
                                    subject.followingButton.sendActions(for: .touchUpInside)
                                    expect(subject.relationshipPriority) == RelationshipPriority.following
                                }
                            }
                        }

                        context("RelationshipPriority.following") {

                            it("unfollows the user") {
                                subject.relationshipPriority = .following
                                subject.followingButton.sendActions(for: .touchUpInside)
                                expect(subject.relationshipPriority) == RelationshipPriority.inactive
                            }
                        }

                        context("RelationshipPriority.starred") {

                            it("unstars the user") {
                                subject.relationshipPriority = .starred
                                subject.followingButton.sendActions(for: .touchUpInside)
                                expect(subject.relationshipPriority) == RelationshipPriority.following
                            }
                        }
                    }

                    describe("tapping the starred button") {

                        for relationshipPriority in [RelationshipPriority.inactive, RelationshipPriority.none, RelationshipPriority.null] {
                            context("RelationshipPriority.\(relationshipPriority)") {

                                it("stars the user") {
                                    subject.relationshipPriority = relationshipPriority
                                    subject.starButton.sendActions(for: .touchUpInside)
                                    expect(subject.relationshipPriority) == RelationshipPriority.starred
                                }
                            }
                        }

                        context("RelationshipPriority.following") {

                            it("stars the user") {
                                subject.relationshipPriority = .following
                                subject.starButton.sendActions(for: .touchUpInside)
                                expect(subject.relationshipPriority) == RelationshipPriority.starred
                            }
                        }

                        context("RelationshipPriority.starred") {

                            it("unstars the user") {
                                subject.relationshipPriority = .starred
                                subject.starButton.sendActions(for: .touchUpInside)
                                expect(subject.relationshipPriority) == RelationshipPriority.following
                            }
                        }
                    }
                }

                context("muted") {

                    describe("tapping the main button") {

                        it("launches the block modal") {
                            subject.relationshipPriority = .mute
                            subject.followingButton.sendActions(for: .touchUpInside)
                            let presentedVC = relationshipController.presentingController?.presentedViewController as? BlockUserModalViewController
                            expect(presentedVC).notTo(beNil())
                        }
                    }
                }
            }
        }
    }
}
