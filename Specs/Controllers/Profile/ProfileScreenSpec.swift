////
///  ProfileScreenSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileScreenSpec: QuickSpec {

    class MockDelegate: ProfileScreenDelegate {
        func mentionTapped() {}
        func hireTapped() {}
        func editTapped() {}
        func inviteTapped() {}
        func collaborateTapped() {}
    }

    override func spec() {
        describe("ProfileScreen") {
            var subject: ProfileScreen!
            var delegate: MockDelegate!

            beforeEach {
                subject = ProfileScreen()
                delegate = MockDelegate()
                subject.delegate = delegate
                subject.coverImage = specImage(named: "specs-cover.jpg")
            }

            context("snapshots") {

                context("ghost - loading") {
                    validateAllSnapshots(named: "ProfileScreen_ghost") {
                        subject.coverImage = nil
                        subject.showNavBars()
                        return subject
                    }
                }

                context("current user") {

                    validateAllSnapshots(named: "ProfileScreen_is_current_user") {
                        let user = User.stub(["id": "42", "username": "Archer", "relationshipPriority" : "self"])
                        subject.configureButtonsForCurrentUser()
                        subject.relationshipControl.userId = user.id
                        subject.relationshipControl.userAtName = user.atName
                        subject.relationshipControl.relationshipPriority = user.relationshipPriority
                        subject.showNavBars()
                        return subject
                    }
                }

                context("not current user") {

                    it("is hireable not collaborateable") {
                        let user = User.stub(["id": "42", "username": "Archer", "relationshipPriority" : "friend"])
                        subject.configureButtonsForNonCurrentUser(isHireable: true, isCollaborateable: false)
                        subject.relationshipControl.userId = user.id
                        subject.relationshipControl.userAtName = user.atName
                        subject.relationshipControl.relationshipPriority = user.relationshipPriority
                        subject.showNavBars()

                        expectValidSnapshot(subject, named: "ProfileScreen_not_current_user_is_hireable", device: .phone6_Portrait)
                    }

                    it("is collaborateable not hireable") {
                        let user = User.stub(["id": "42", "username": "Archer", "relationshipPriority" : "friend"])
                        subject.configureButtonsForNonCurrentUser(isHireable: false, isCollaborateable: true)
                        subject.relationshipControl.userId = user.id
                        subject.relationshipControl.userAtName = user.atName
                        subject.relationshipControl.relationshipPriority = user.relationshipPriority
                        subject.showNavBars()

                        expectValidSnapshot(subject, named: "ProfileScreen_not_current_user_is_collaborateable", device: .phone6_Portrait)
                    }

                    context("is hireable and collaborateable") {
                        validateAllSnapshots(named: "ProfileScreen_not_current_user_hireable_and_collaborateable") {
                            let user = User.stub(["id": "42", "username": "Archer", "relationshipPriority" : "friend"])
                            subject.configureButtonsForNonCurrentUser(isHireable: true, isCollaborateable: true)
                            subject.relationshipControl.userId = user.id
                            subject.relationshipControl.userAtName = user.atName
                            subject.relationshipControl.relationshipPriority = user.relationshipPriority
                            subject.showNavBars()
                            return subject
                        }
                    }

                    context("is mentionable") {
                        validateAllSnapshots(named: "ProfileScreen_not_current_user_is_mentionable") {
                            let user = User.stub(["id": "42", "username": "Archer", "relationshipPriority" : "noise"])
                            subject.configureButtonsForNonCurrentUser(isHireable: false, isCollaborateable: false)
                            subject.relationshipControl.userId = user.id
                            subject.relationshipControl.userAtName = user.atName
                            subject.relationshipControl.relationshipPriority = user.relationshipPriority
                            subject.showNavBars()
                            return subject
                        }
                    }
                }
            }
        }
    }

}
