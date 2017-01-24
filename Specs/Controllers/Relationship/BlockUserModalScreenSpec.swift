////
///  BlockUserModalScreenSpec.swift
//

@testable import Ello
import Quick
import Nimble


class BlockUserModalScreenSpec: QuickSpec {
    class FakeBlockUserModalController: UIViewController, BlockUserModalDelegate {
        var relationshipPriority: RelationshipPriority?
        var calledFlagTapped = false
        var calledCloseModal = false

        func updateRelationship(_ newRelationship: RelationshipPriority) {
            relationshipPriority = newRelationship
        }
        func flagTapped() {
            calledFlagTapped = true
        }
        func closeModal() {
            calledCloseModal = true
        }
    }

    override func spec() {
        describe("BlockUserModalScreen") {
            var subject: BlockUserModalScreen!
            var controller: FakeBlockUserModalController!
            var muteButton: UIButton!
            var blockButton: UIButton!
            var flagButton: UIButton!

            func setupScreen(atName: String = "@archer", relationshipPriority: RelationshipPriority = .inactive) {
                let config = BlockUserModalConfig(userId: "666", userAtName: atName, relationshipPriority: relationshipPriority, changeClosure: { _ in })
                controller = FakeBlockUserModalController()
                subject = BlockUserModalScreen(config: config)
                controller.view = subject
                showController(controller)

                muteButton = (subviewThatMatches(subject) { ($0 as? UIButton)?.currentTitle == InterfaceString.Relationship.MuteButton })
                blockButton = (subviewThatMatches(subject) { ($0 as? UIButton)?.currentTitle == InterfaceString.Relationship.BlockButton })
                flagButton = (subviewThatMatches(subject) { ($0 as? UIButton)?.currentTitle == InterfaceString.Relationship.FlagButton })
            }

            beforeEach {
                setupScreen(relationshipPriority: .inactive)
            }

            describe("snapshots") {
                beforeEach {
                    setupScreen(atName: "@foo", relationshipPriority: .following)
                }
                validateAllSnapshots(named: "BlockUserModalScreen") { return subject }
            }

            describe("button targets") {

                describe("@muteButton") {
                    it("not selected") {
                        setupScreen(atName: "@archer", relationshipPriority: .following)
                        muteButton.sendActions(for: UIControlEvents.touchUpInside)
                        expect(controller.relationshipPriority).to(equal(RelationshipPriority.mute))
                    }

                    it("selected") {
                        setupScreen(atName: "@archer", relationshipPriority: .mute)
                        muteButton.sendActions(for: UIControlEvents.touchUpInside)
                        expect(controller.relationshipPriority).to(equal(RelationshipPriority.inactive))
                    }
                }

                describe("@blockButton") {
                    it("not selected") {
                        setupScreen(atName: "@archer", relationshipPriority: .following)
                        blockButton.sendActions(for: UIControlEvents.touchUpInside)
                        expect(controller.relationshipPriority).to(equal(RelationshipPriority.block))
                    }

                    it("selected") {
                        setupScreen(atName: "@archer", relationshipPriority: .block)
                        blockButton.sendActions(for: UIControlEvents.touchUpInside)
                        expect(controller.relationshipPriority).to(equal(RelationshipPriority.inactive))
                    }
                }

                describe("@flagButton") {
                    it("triggers") {
                        flagButton.sendActions(for: UIControlEvents.touchUpInside)
                        expect(controller.calledFlagTapped) == true
                    }
                }
            }
        }
    }
}
