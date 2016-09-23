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
                validateAllSnapshots(named: "CreateProfileScreen") { return subject }
            }
            context("snapshots setting existing data") {
                validateAllSnapshots(named: "CreateProfileScreen with data") {
                    subject.name = "name"
                    subject.bio = "bio bio bio bio bio bio bio bio bio bio bio bio bio bio bio bio bio"
                    subject.links = "links links links links links links links links links links links links"
                    subject.linksValid = true
                    subject.coverImage = ImageRegionData(image: UIImage.imageWithColor(.blueColor(), size: CGSize(width: 1000, height: 1000))!)
                    subject.avatarImage = ImageRegionData(image: specImage(named: "specs-avatar")!)
                    return subject
                }
            }
            context("setting text") {
                it("should notify delegate of name change") {
                    let textView: ClearTextView! = subviewThatMatches(subject) { ($0 as? ClearTextView)?.placeholder?.contains("Name") ?? false }
                    subject.textView(textView, shouldChangeTextInRange: NSRange(location: 0, length: 0), replacementText: "!")
                    expect(delegate.didAssignName) == true
                }
                it("should notify delegate of bio change") {
                    let textView: ClearTextView! = subviewThatMatches(subject) { ($0 as? ClearTextView)?.placeholder?.contains("Bio") ?? false }
                    subject.textView(textView, shouldChangeTextInRange: NSRange(location: 0, length: 0), replacementText: "!")
                    expect(delegate.didAssignBio) == true
                }
                it("should notify delegate of link change") {
                    let textView: ClearTextView! = subviewThatMatches(subject) { ($0 as? ClearTextView)?.placeholder?.contains("Links") ?? false }
                    subject.textView(textView, shouldChangeTextInRange: NSRange(location: 0, length: 0), replacementText: "!")
                    expect(delegate.didAssignLinks) == true
                }
                it("should notify delegate of avatar change") {
                    let image = ImageRegionData(image: UIImage.imageWithColor(.blueColor()))
                    subject.setImage(image, target: .Avatar, updateDelegate: true)
                    expect(subject.didAssignAvatar) == true
                }
                it("should notify delegate of coverImage change") {
                    let image = ImageRegionData(image: UIImage.imageWithColor(.blueColor()))
                    subject.setImage(image, target: .CoverImage, updateDelegate: true)
                    expect(subject.didAssignCoverImage) == true
                }
            }
        }
    }
}
