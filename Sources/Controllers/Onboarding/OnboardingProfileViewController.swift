////
///  OnboardingProfileViewController.swift
//

class OnboardingProfileViewController: UIViewController, HasAppController {
    private var _mockScreen: OnboardingProfileScreenProtocol?
    var screen: OnboardingProfileScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return _mockScreen ?? (self.view as! OnboardingProfileScreen) }
    }

    var currentUser: User?

    var appViewController: AppViewController? {
        return findViewController { vc in vc is AppViewController } as? AppViewController
    }

    var onboardingViewController: OnboardingViewController?
    var onboardingData: OnboardingData!
    var didSetName = false
    var didSetBio = false
    var didSetLinks = false
    var linksAreValid = false
    var debouncedLinksValidator = debounce(0.5)
    var didUploadCoverImage = false
    var didUploadAvatarImage = false
    var isProfileValid: Bool {
        return (didSetName ||
            didSetBio ||
            didSetLinks ||
            didUploadCoverImage ||
            didUploadAvatarImage) && (!didSetLinks || linksAreValid)
    }

    override func loadView() {
        let screen = OnboardingProfileScreen()
        screen.delegate = self
        self.view = screen
    }
}

extension OnboardingProfileViewController: OnboardingProfileDelegate {
    func present(controller: UIViewController) {
        present(controller, animated: true, completion: nil)
    }

    func dismissController() {
        dismiss(animated: true, completion: nil)
    }

    func assign(name: String?) -> ValidationState {
        onboardingData.name = name
        didSetName = (name?.isEmpty == false)
        onboardingViewController?.canGoNext = isProfileValid
        return didSetName ? .okSmall : .none
    }

    func assign(bio: String?) -> ValidationState {
        onboardingData.bio = bio
        didSetBio = (bio?.isEmpty == false)
        onboardingViewController?.canGoNext = isProfileValid
        return didSetBio ? .okSmall : .none
    }

    func assign(links: String?) -> ValidationState {
        if let links = links, Validator.hasValidLinks(links) {
            onboardingData.links = links
            didSetLinks = true
            linksAreValid = true
        }
        else {
            onboardingData.links = nil
            if links == nil || links == "" {
                didSetLinks = false
            }
            else {
                didSetLinks = true
            }
            linksAreValid = false
        }
        onboardingViewController?.canGoNext = isProfileValid

        debouncedLinksValidator { [weak self] in
            guard let `self` = self else { return }
            self.screen.linksValid = self.didSetLinks ? self.linksAreValid : nil
        }
        return linksAreValid ? .okSmall : .none
    }

    func assign(coverImage: ImageRegionData) {
        didUploadCoverImage = true
        onboardingData.coverImage = coverImage
        onboardingViewController?.canGoNext = isProfileValid
    }

    func assign(avatarImage: ImageRegionData) {
        didUploadAvatarImage = true
        onboardingData.avatarImage = avatarImage
        onboardingViewController?.canGoNext = isProfileValid
    }
}

extension OnboardingProfileViewController: OnboardingStepController {
    func onboardingStepBegin() {
        didSetName = (onboardingData.name?.isEmpty == false)
        didSetBio = (onboardingData.bio?.isEmpty == false)
        if let links = onboardingData.links {
            didSetLinks = !links.isEmpty
            linksAreValid = Validator.hasValidLinks(links)
        }
        else {
            didSetLinks = false
            linksAreValid = false
        }
        didUploadAvatarImage = (onboardingData.avatarImage != nil)
        didUploadCoverImage = (onboardingData.coverImage != nil)
        onboardingViewController?.hasAbortButton = true
        onboardingViewController?.canGoNext = isProfileValid

        screen.name = onboardingData.name
        screen.bio = onboardingData.bio
        screen.links = onboardingData.links
        screen.coverImage = onboardingData.coverImage
        screen.avatarImage = onboardingData.avatarImage
    }

    func onboardingWillProceed(abort: Bool, proceedClosure: @escaping (_ success: OnboardingViewController.OnboardingProceed) -> Void) {
        var properties: [Profile.Property: Any] = [:]
        if let name = onboardingData.name, didSetName {
            Tracker.shared.enteredOnboardName()
            properties[.name] = name
        }

        if let bio = onboardingData.bio, didSetBio {
            Tracker.shared.enteredOnboardBio()
            properties[.bio] = bio
        }

        if let links = onboardingData.links, didSetLinks {
            Tracker.shared.enteredOnboardLinks()
            properties[.links] = links
        }

        let avatarImage: ImageRegionData? = didUploadAvatarImage ? onboardingData.avatarImage : nil
        if avatarImage != nil {
            Tracker.shared.uploadedOnboardAvatar()
        }

        let coverImage: ImageRegionData? = didUploadCoverImage ? onboardingData.coverImage : nil
        if coverImage != nil {
            Tracker.shared.uploadedOnboardCoverImage()
        }

        guard avatarImage != nil || coverImage != nil || !properties.isEmpty else {
            goToNextStep(abort, proceedClosure: proceedClosure)
            return
        }

        ProfileService().updateUserImages(
            avatarImage: avatarImage, coverImage: coverImage,
            properties: properties)
            .then { _avatarURL, _coverImageURL, user -> Void in
                self.appViewController?.currentUser = user
                self.goToNextStep(abort, proceedClosure: proceedClosure)
            }
            .catch { error in
                proceedClosure(.error)
                let message: String
                if let elloError = (error as NSError).elloError, let messages = elloError.messages {
                    if elloError.attrs?["links"] != nil {
                        self.screen.linksValid = false
                    }
                    message = messages.joined(separator: "\n")
                }
                else {
                    message = InterfaceString.GenericError
                }
                let alertController = AlertViewController(error: message)
                self.appViewController?.present(alertController, animated: true, completion: nil)
            }
    }

    func goToNextStep(_ abort: Bool, proceedClosure: @escaping (_ success: OnboardingViewController.OnboardingProceed) -> Void) {
        guard
            let presenter = onboardingViewController?.appViewController, !abort else {
            proceedClosure(.abort)
            return
        }

        Tracker.shared.inviteFriendsTapped()
        AddressBookController.promptForAddressBookAccess(fromController: self, completion: { result in
            switch result {
            case let .success(addressBook):
                Tracker.shared.contactAccessPreferenceChanged(true)

                let vc = OnboardingInviteViewController(addressBook: addressBook)
                vc.currentUser = self.currentUser
                vc.onboardingViewController = self.onboardingViewController
                self.onboardingViewController?.inviteFriendsController = vc

                proceedClosure(.continue)
            case let .failure(addressBookError):
                guard addressBookError != .cancelled else {
                    proceedClosure(.error)
                    return
                }

                Tracker.shared.contactAccessPreferenceChanged(false)
                let message = addressBookError.rawValue
                let alertController = AlertViewController(error: InterfaceString.Friends.ImportError(message))
                presenter.present(alertController, animated: true, completion: .none)
            }
        },
            cancelCompletion: {
                guard let onboardingView = self.onboardingViewController?.view else { return }
                ElloHUD.hideLoadingHudInView(onboardingView)

                proceedClosure(.continue)
        })
    }
}
