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

        func present(controller: UIViewController) {}
        func dismissController() {}

        func assign(name: String?) -> ValidationState {
            didAssignName = true
            return (name?.isEmpty == false) ? ValidationState.ok : ValidationState.none
        }
        func assign(bio: String?) -> ValidationState {
            didAssignBio = true
            return (bio?.isEmpty == false) ? ValidationState.ok : ValidationState.none
        }
        func assign(links: String?) -> ValidationState {
            didAssignLinks = true
            return (links?.isEmpty == false) ? ValidationState.ok : ValidationState.none
        }
        func assign(coverImage: ImageRegionData) {
            didAssignCoverImage = true
        }
        func assign(avatarImage: ImageRegionData) {
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
                    subject.coverImage = ImageRegionData(image: UIImage.imageWithColor(.blue, size: CGSize(width: 1000, height: 1000))!)
                    subject.avatarImage = ImageRegionData(image: specImage(named: "specs-avatar")!)
                    return subject
                }
            }
            context("setting text") {
                it("should notify delegate of name change") {
                    let textView: ClearTextView! = subviewThatMatches(subject) { ($0 as? ClearTextView)?.placeholder?.contains("Name") ?? false }
                    _ = subject.textView(textView, shouldChangeTextIn: NSRange(location: 0, length: 0), replacementText: "!")
                    expect(delegate.didAssignName) == true
                }
                it("should notify delegate of bio change") {
                    let textView: ClearTextView! = subviewThatMatches(subject) { ($0 as? ClearTextView)?.placeholder?.contains("Bio") ?? false }
                    _ = subject.textView(textView, shouldChangeTextIn: NSRange(location: 0, length: 0), replacementText: "!")
                    expect(delegate.didAssignBio) == true
                }
                it("should notify delegate of link change") {
                    let textView: ClearTextView! = subviewThatMatches(subject) { ($0 as? ClearTextView)?.placeholder?.contains("Links") ?? false }
                    _ = subject.textView(textView, shouldChangeTextIn: NSRange(location: 0, length: 0), replacementText: "!")
                    expect(delegate.didAssignLinks) == true
                }
                it("should notify delegate of avatar change") {
                    let image = ImageRegionData(image: UIImage.imageWithColor(.blue)!)
                    subject.setImage(image, target: .avatar, updateDelegate: true)
                    expect(delegate.didAssignAvatar) == true
                }
                it("should notify delegate of coverImage change") {
                    let image = ImageRegionData(image: UIImage.imageWithColor(.blue)!)
                    subject.setImage(image, target: .coverImage, updateDelegate: true)
                    expect(delegate.didAssignCoverImage) == true
                }
            }
        }
    }
}
