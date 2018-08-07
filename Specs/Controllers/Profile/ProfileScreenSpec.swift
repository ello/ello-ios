////
///  ProfileScreenSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileScreenSpec: QuickSpec {

    class MockDelegate: ProfileScreenDelegate {
        func roleAdminTapped() {}
        func mentionTapped() {}
        func hireTapped() {}
        func editTapped() {}
        func inviteTapped() {}
        func collaborateTapped() {}
    }

    override func spec() {
        describe("ProfileScreen") {
            var subject: ProfileScreen!

            beforeEach {
                subject = ProfileScreen()
                subject.coverImage = specImage(named: "specs-cover.jpg")
            }

            context("snapshots") {

                context("ghost - loading") {
                    validateAllSnapshots(named: "ProfileScreen_ghost") {
                        subject.hasRoleAdminButton = false
                        subject.coverImage = nil
                        subject.showNavBars(animated: false)
                        return subject
                    }
                }

                context("current user") {
                    validateAllSnapshots(named: "ProfileScreen_is_current_user") {
                        let user = User.stub(["username": "Archer", "relationshipPriority": "self"])
                        subject.hasRoleAdminButton = false
                        subject.configureButtonsForCurrentUser()
                        subject.relationshipControl.relationshipPriority = user.relationshipPriority
                        subject.showNavBars(animated: false)
                        return subject
                    }
                }

                context("not current user") {

                    it("current user is role admin") {
                        let user = User.stub(["username": "Archer", "relationshipPriority": "friend"])
                        subject.hasRoleAdminButton = true
                        subject.configureButtonsForNonCurrentUser(isHireable: true, isCollaborateable: true)
                        subject.relationshipControl.relationshipPriority = user.relationshipPriority
                        subject.showNavBars(animated: false)

                        expectValidSnapshot(subject, named: "ProfileScreen_current_user_is_role_admin", device: .phone6_Portrait)
                    }

                    it("is hireable not collaborateable") {
                        let user = User.stub(["username": "Archer", "relationshipPriority": "friend"])
                        subject.hasRoleAdminButton = false
                        subject.configureButtonsForNonCurrentUser(isHireable: true, isCollaborateable: false)
                        subject.relationshipControl.relationshipPriority = user.relationshipPriority
                        subject.showNavBars(animated: false)

                        expectValidSnapshot(subject, named: "ProfileScreen_not_current_user_is_hireable", device: .phone6_Portrait)
                    }

                    it("is collaborateable not hireable") {
                        let user = User.stub(["username": "Archer", "relationshipPriority": "friend"])
                        subject.hasRoleAdminButton = false
                        subject.configureButtonsForNonCurrentUser(isHireable: false, isCollaborateable: true)
                        subject.relationshipControl.relationshipPriority = user.relationshipPriority
                        subject.showNavBars(animated: false)

                        expectValidSnapshot(subject, named: "ProfileScreen_not_current_user_is_collaborateable", device: .phone6_Portrait)
                    }

                    it("is hireable and collaborateable") {
                        let user = User.stub(["username": "Archer", "relationshipPriority": "friend"])
                        subject.hasRoleAdminButton = false
                        subject.configureButtonsForNonCurrentUser(isHireable: true, isCollaborateable: true)
                        subject.relationshipControl.relationshipPriority = user.relationshipPriority
                        subject.showNavBars(animated: false)

                        expectValidSnapshot(subject, named: "ProfileScreen_not_current_user_hireable_and_collaborateable", device: .phone6_Portrait)
                    }

                    it("is mentionable") {
                        let user = User.stub(["username": "Archer", "relationshipPriority": "noise"])
                        subject.hasRoleAdminButton = false
                        subject.configureButtonsForNonCurrentUser(isHireable: false, isCollaborateable: false)
                        subject.relationshipControl.relationshipPriority = user.relationshipPriority
                        subject.showNavBars(animated: false)

                        expectValidSnapshot(subject, named: "ProfileScreen_not_current_user_is_mentionable", device: .phone6_Portrait)
                    }
                }
            }
        }
    }

}
