////
///  CreateProfileScreenSpec.swift
//

@testable import Ello
import Quick
import Nimble


class CreateProfileScreenSpec: QuickSpec {
    class MockDelegate: CreateProfileDelegate {
        var didAssignName = false
        var didAssignBio = false
        var didAssignLinks = false
        var didAssignCoverImage = false
        var didAssignAvatar = false

        func presentController(controller: UIViewController) {}
        func dismissController() {}

        func assignName(name: String?) {
            didAssignName = true
        }
        func assignBio(bio: String?) {
            didAssignBio = true
        }
        func assignLinks(links: String?) {
            didAssignLinks = true
        }
        func assignCoverImage(image: ImageRegionData) {
            didAssignCoverImage = true
        }
        func assignAvatar(image: ImageRegionData) {
            didAssignAvatar = true
        }
    }
    override func spec() {
        describe("CreateProfileScreen") {
            var subject: CreateProfileScreen!
            var delegate: MockDelegate!
            beforeEach {
                subject = CreateProfileScreen()
                delegate = MockDelegate()
                subject.delegate = delegate
                showView(subject)
            }
            context("snapshots") {
                validateAllSnapshots(named: "CreateProfileScreen", record: true) { return subject }
            }
            context("snapshots setting existing data") {
                validateAllSnapshots(named: "CreateProfileScreen", record: true) {
                    subject.name = "name"
                    subject.bio = "bio bio bio bio bio bio bio bio bio bio bio bio bio bio bio bio bio"
                    subject.links = "links links links links links links links links links links links links"
                    subject.linksValid = true
                    subject.coverImage = ImageRegionData(image: UIImage.imageWithColor(.blueColor(), size: CGSize(width: 1000, height: 1000)))
                    subject.avatarImage = ImageRegionData(image: specsImage("specs-avatar"))
                }
            }
        }
    }
}
