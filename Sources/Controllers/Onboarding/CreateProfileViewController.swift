////
///  CreateProfileViewController.swift
//

public class CreateProfileViewController: UIViewController, HasAppController {
    var mockScreen: CreateProfileScreenProtocol?
    var screen: CreateProfileScreenProtocol { return mockScreen ?? (self.view as! CreateProfileScreenProtocol) }
    var parentAppController: AppViewController?
    var currentUser: User?

    public var onboardingViewController: OnboardingViewController?
    public var onboardingData: OnboardingData!
    var didSetName = false
    var didSetBio = false
    var didSetLinks = false
    var didUploadCoverImage = false
    var didUploadAvatarImage = false
    var didSetAnything: Bool {
        return didSetName ||
            didSetBio ||
            didSetLinks ||
            didUploadCoverImage ||
            didUploadAvatarImage
    }

    override public func loadView() {
        let screen = CreateProfileScreen()
        screen.delegate = self
        self.view = screen
    }
}

extension CreateProfileViewController: CreateProfileDelegate {
    func presentController(controller: UIViewController) {
        presentViewController(controller, animated: true, completion: nil)
    }

    func dismissController() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func assignName(name: String?) {
        onboardingData.name = name
        didSetName = (name?.isEmpty == false)
        onboardingViewController?.canGoNext = didSetAnything
    }

    func assignBio(bio: String?) {
        onboardingData.bio = bio
        didSetBio = (bio?.isEmpty == false)
        onboardingViewController?.canGoNext = didSetAnything
    }

    func assignLinks(links: String?) {
        onboardingData.links = links
        didSetLinks = (links?.isEmpty == false)
        onboardingViewController?.canGoNext = didSetAnything
    }

    func assignCoverImage(image: ImageRegionData) {
        didUploadCoverImage = true
        onboardingData.coverImage = image
        onboardingViewController?.canGoNext = didSetAnything
    }
    func assignAvatar(image: ImageRegionData) {
        didUploadAvatarImage = true
        onboardingData.avatarImage = image
        onboardingViewController?.canGoNext = didSetAnything
    }
}

extension CreateProfileViewController: OnboardingStepController {
    public func onboardingStepBegin() {
        didSetName = (onboardingData.name?.isEmpty == false)
        didSetBio = (onboardingData.bio?.isEmpty == false)
        didSetLinks = (onboardingData.links?.isEmpty == false)
        didUploadAvatarImage = (onboardingData.avatarImage != nil)
        didUploadCoverImage = (onboardingData.coverImage != nil)
        onboardingViewController?.hasAbortButton = true
        onboardingViewController?.canGoNext = didSetAnything

        screen.name = onboardingData.name
        screen.bio = onboardingData.bio
        screen.links = onboardingData.links
        screen.coverImage = onboardingData.coverImage
        screen.avatarImage = onboardingData.avatarImage
    }

    public func onboardingWillProceed(abort: Bool, proceedClosure: (success: OnboardingViewController.OnboardingProceed) -> Void) {
        var properties: [String: AnyObject] = [:]
        if let name = onboardingData.name where didSetName {
            Tracker.sharedTracker.enteredOnboardName()
            properties["name"] = name
        }

        if let bio = onboardingData.bio where didSetBio {
            Tracker.sharedTracker.enteredOnboardBio()
            properties["unsanitized_short_bio"] = bio
        }

        if let links = onboardingData.links where didSetLinks {
            Tracker.sharedTracker.enteredOnboardLinks()
            properties["external_links"] = links
        }

        let avatarImage: ImageRegionData? = didUploadAvatarImage ? onboardingData.avatarImage : nil
        let coverImage: ImageRegionData? = didUploadCoverImage ? onboardingData.coverImage : nil

        guard avatarImage != nil || coverImage != nil || !properties.isEmpty else {
            goToNextStep(abort, proceedClosure: proceedClosure)
            return
        }

        ProfileService().updateUserImages(
            avatarImage: avatarImage, coverImage: coverImage,
            properties: properties,
            success: { _avatarURL, _coverImageURL, user in
                self.parentAppController?.currentUser = user
                self.goToNextStep(abort, proceedClosure: proceedClosure) },
            failure: { error, _ in
                proceedClosure(success: .Error)
                let message: String
                if let elloError = error.elloError, messages = elloError.messages {
                    if elloError.attrs?["links"] != nil {
                        self.screen.linksValid = false
                    }
                    message = messages.joinWithSeparator("\n")
                }
                else {
                    message = InterfaceString.GenericError
                }
                let alertController = AlertViewController(error: message)
                self.parentAppController?.presentViewController(alertController, animated: true, completion: nil)
            })
    }

    func goToNextStep(abort: Bool, proceedClosure: (success: OnboardingViewController.OnboardingProceed) -> Void) {
        guard let
            presenter = onboardingViewController?.parentAppController
        where !abort else {
            proceedClosure(success: .Abort)
            return
        }

        Tracker.sharedTracker.inviteFriendsTapped()
        AddressBookController.promptForAddressBookAccess(fromController: self) { result in
            switch result {
            case let .Success(addressBook):
                Tracker.sharedTracker.contactAccessPreferenceChanged(true)

                let vc = InviteFriendsViewController(addressBook: addressBook)
                vc.currentUser = self.currentUser
                vc.onboardingViewController = self.onboardingViewController
                self.onboardingViewController?.inviteFriendsController = vc

                proceedClosure(success: .Continue)
            case let .Failure(addressBookError):
                guard addressBookError != .Cancelled else {
                    proceedClosure(success: .Error)
                    return
                }

                Tracker.sharedTracker.contactAccessPreferenceChanged(false)
                let message = addressBookError.rawValue
                let alertController = AlertViewController(error: NSString.localizedStringWithFormat(InterfaceString.Friends.ImportErrorTemplate, message) as String)
                presenter.presentViewController(alertController, animated: true, completion: .None)
            }
        }
    }
}
