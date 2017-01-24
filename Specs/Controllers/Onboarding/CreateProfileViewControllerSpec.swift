////
///  CreateProfileViewControllerSpec.swift
//

@testable import Ello
import Quick
import Nimble


class CreateProfileViewControllerSpec: QuickSpec {
    class MockCreateProfileScreen: CreateProfileScreenProtocol {
        var name: String?
        var bio: String?
        var links: String?
        var linksValid: Bool?
        var coverImage: ImageRegionData?
        var avatarImage: ImageRegionData?
    }
    class MockOnboardingViewController: OnboardingViewController {
    }
    override func spec() {
        var subject: CreateProfileViewController!
        var mockScreen: CreateProfileScreenProtocol!
        var onboardingData: OnboardingData!
        var onboardingViewController: OnboardingViewController!
        beforeEach {
            subject = CreateProfileViewController()
            mockScreen = MockCreateProfileScreen()
            onboardingViewController = MockOnboardingViewController()
            onboardingData = onboardingViewController.onboardingData
            subject.onboardingData = onboardingData
            subject.mockScreen = mockScreen
            subject.onboardingViewController = onboardingViewController
        }

        describe("CreateProfileViewController") {
            describe("onboardingStepBegin()") {
                describe("prepares itself according to onboardingData") {
                    it("does not set 'didSet' vars if nothing is set") {
                        onboardingData.name = ""
                        onboardingData.bio = nil
                        subject.onboardingStepBegin()
                        expect(subject.didSetName) == false
                        expect(subject.didSetLinks) == false
                        expect(subject.didSetBio) == false
                        expect(subject.didUploadCoverImage) == false
                        expect(subject.didUploadAvatarImage) == false
                    }
                    it("set 'didSetName' if name is set") {
                        onboardingData.name = "my name"
                        onboardingData.bio = nil
                        subject.onboardingStepBegin()
                        expect(subject.didSetName) == true
                        expect(subject.didSetLinks) == false
                        expect(subject.didSetBio) == false
                        expect(subject.didUploadCoverImage) == false
                        expect(subject.didUploadAvatarImage) == false
                    }
                    it("sets 'didSet' vars if everything is set") {
                        onboardingData.name = "my name"
                        onboardingData.links = "http://my.links"
                        onboardingData.bio = "my bio"
                        let image = ImageRegionData(image: UIImage.imageWithColor(.blue)!)
                        onboardingData.coverImage = image
                        onboardingData.avatarImage = image
                        subject.onboardingStepBegin()
                        expect(subject.didSetName) == true
                        expect(subject.didSetLinks) == true
                        expect(subject.didSetBio) == true
                        expect(subject.didUploadCoverImage) == true
                        expect(subject.didUploadAvatarImage) == true
                    }
                }
                describe("prepares the screen according to onboardingData") {
                    var image: ImageRegionData!
                    beforeEach {
                        image = ImageRegionData(image: UIImage.imageWithColor(.blue)!)
                        onboardingData.name = "my name"
                        onboardingData.links = "http://my.links"
                        onboardingData.bio = "my bio"
                        onboardingData.coverImage = image
                        onboardingData.avatarImage = image
                        subject.onboardingStepBegin()
                    }

                    it("sets name") {
                        expect(mockScreen.name) == "my name"
                    }
                    it("sets links") {
                        expect(mockScreen.links) == "http://my.links"
                    }
                    it("sets bio") {
                        expect(mockScreen.bio) == "my bio"
                    }
                    it("sets coverImage") {
                        expect(mockScreen.coverImage) == image
                    }
                    it("sets avatar") {
                        expect(mockScreen.avatarImage) == image
                    }
                }
                describe("prepares the onboardingViewController according to onboardingData") {
                    it("if nothing is set, 'canGoNext' is false") {
                        onboardingData.name = ""
                        onboardingData.bio = nil
                        subject.onboardingStepBegin()
                        expect(onboardingViewController.canGoNext) == false
                    }
                    it("if name is set, 'canGoNext' is true") {
                        onboardingData.name = "my name"
                        onboardingData.bio = nil
                        let image = ImageRegionData(image: UIImage.imageWithColor(.blue)!)
                        onboardingData.coverImage = image
                        onboardingData.avatarImage = image
                        subject.onboardingStepBegin()
                        expect(onboardingViewController.canGoNext) == true
                    }
                    it("if everything is set, 'canGoNext' is true") {
                        onboardingData.name = "my name"
                        onboardingData.links = "http://my.links"
                        onboardingData.bio = "my bio"
                        let image = ImageRegionData(image: UIImage.imageWithColor(.blue)!)
                        onboardingData.coverImage = image
                        onboardingData.avatarImage = image
                        subject.onboardingStepBegin()
                        expect(onboardingViewController.canGoNext) == true
                    }
                }
            }
            context("handles changes to name,bio,etc") {
                beforeEach {
                    onboardingViewController.canGoNext = false
                }
                it("forwards name") {
                    _ = subject.assign(name: "my name")
                    expect(onboardingData.name) == "my name"
                    expect(subject.didSetName) == true
                    expect(subject.didSetBio) == false
                    expect(onboardingViewController.canGoNext) == true
                }
                it("forwards links") {
                    _ = subject.assign(links: "http://my.links")
                    expect(onboardingData.links) == "http://my.links"
                    expect(subject.didSetLinks) == true
                    expect(subject.didSetBio) == false
                    expect(onboardingViewController.canGoNext) == true
                }
                it("forwards bio") {
                    _ = subject.assign(bio: "my bio")
                    expect(onboardingData.bio) == "my bio"
                    expect(subject.didSetBio) == true
                    expect(subject.didUploadCoverImage) == false
                    expect(onboardingViewController.canGoNext) == true
                }
                it("forwards coverImage") {
                    let image = ImageRegionData(image: UIImage.imageWithColor(.blue)!)
                    subject.assign(coverImage: image)
                    expect(onboardingData.coverImage) == image
                    expect(subject.didUploadCoverImage) == true
                    expect(subject.didUploadAvatarImage) == false
                    expect(onboardingViewController.canGoNext) == true
                }
                it("forwards avatar") {
                    let image = ImageRegionData(image: UIImage.imageWithColor(.blue)!)
                    subject.assign(avatarImage: image)
                    expect(onboardingData.avatarImage) == image
                    expect(subject.didUploadAvatarImage) == true
                    expect(subject.didSetName) == false
                    expect(onboardingViewController.canGoNext) == true
                }
            }
            context("only submits changed data") {
                var props: [String: AnyObject] = [:]
                beforeEach {
                    ElloProvider.sharedProvider = ElloProvider.RecordedStubbingProvider([
                        RecordedResponse(endpoint: .profileUpdate(body: [:]), responseClosure: { target in
                                if case let .profileUpdate(body) = target {
                                    props = body
                                }
                                return .networkResponse(401, Data())
                            }),
                    ])
                }

                it("changed name") {
                    _ = subject.assign(name: "my name")
                    subject.onboardingWillProceed(abort: false, proceedClosure: { _ in })
                    expect(props["name"] as? String) == "my name"
                }
                it("changed name,links,bio") {
                    _ = subject.assign(name: "my name")
                    _ = subject.assign(links: "http://my.links")
                    _ = subject.assign(bio: "my bio")
                    subject.onboardingWillProceed(abort: false, proceedClosure: { _ in })
                    expect(props["name"] as? String) == "my name"
                    expect(props["external_links"] as? String) == "http://my.links"
                    expect(props["unsanitized_short_bio"] as? String) == "my bio"
                }
                // ElloS3 doesn't support/use the shared provider paradigm
                xit("changed avatar") {}
                xit("changed avatar,name") {}
            }
        }
    }
}
