////
///  OnboardingViewController.swift
//

import PINRemoteImage


class OnboardingViewController: BaseElloViewController, HasAppController {
    fileprivate enum OnboardingDirection: CGFloat {
        case left = -1
        case right = 1
    }
    enum OnboardingProceed {
        case `continue`
        case abort
        case error
    }

    var mockScreen: OnboardingScreenProtocol?
    var screen: OnboardingScreenProtocol { return mockScreen ?? (self.view as! OnboardingScreenProtocol) }

    var parentAppController: AppViewController?
    var inviteFriendsController: InviteFriendsViewController? {
        willSet {
            guard inviteFriendsController == nil else {
                fatalError("inviteFriendsController should only be set once")
            }
        }
        didSet {
            onboardingViewControllers.append(inviteFriendsController!)
        }
    }
    var isTransitioning: Bool { return transitioningViewController != nil }
    let onboardingData = OnboardingData()
    var visibleViewController: UIViewController?
    fileprivate var transitioningViewController: UIViewController?
    fileprivate var visibleViewControllerIndex: Int = 0
    fileprivate var onboardingViewControllers = [UIViewController]()

    var hasAbortButton: Bool {
        get { return screen.hasAbortButton }
        set { screen.hasAbortButton = newValue }
    }
    var canGoNext: Bool {
        get { return screen.canGoNext }
        set { screen.canGoNext = newValue }
    }
    var prompt: String? {
        get { return screen.prompt }
        set { screen.prompt = newValue }
    }

    override func didSetCurrentUser() {
        super.didSetCurrentUser()

        if let currentUser = currentUser {
            onboardingData.name = currentUser.name
            onboardingData.bio = currentUser.profile?.shortBio
            if let links = currentUser.externalLinksList {
                onboardingData.links = links.reduce("") { (memo: String, link) in
                    if memo.characters.count == 0 {
                        return link.url.absoluteString
                    }
                    else {
                        return "\(memo), \(link.url.absoluteString)"
                    }
                }
            }

            if let url = currentUser.avatarURL(), url.absoluteString !~ "ello-default"
            {
                PINRemoteImageManager.shared().downloadImage(with: url, options: []) { result in
                    if let animatedImage = result?.animatedImage {
                        self.onboardingData.avatarImage = ImageRegionData(image: animatedImage.posterImage, data: animatedImage.data, contentType: "image/gif")
                    }
                    else if let image = result?.image {
                        self.onboardingData.avatarImage = ImageRegionData(image: image)
                    }
                }
            }

            if let url = currentUser.coverImageURL(), url.absoluteString !~ "ello-default"
            {
                PINRemoteImageManager.shared().downloadImage(with: url, options: []) { result in
                    if let animatedImage = result?.animatedImage {
                        self.onboardingData.coverImage = ImageRegionData(image: animatedImage.posterImage, data: animatedImage.data, contentType: "image/gif")
                    }
                    else if let image = result?.image {
                        self.onboardingData.coverImage = ImageRegionData(image: image)
                    }
                }
            }
        }

        for controller in onboardingViewControllers {
            if let controller = controller as? ControllerThatMightHaveTheCurrentUser {
                controller.currentUser = currentUser
            }
        }
    }

    override func loadView() {
        let screen = OnboardingScreen()
        screen.delegate = self
        self.view = screen
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupOnboardingControllers()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        visibleViewController?.view.frame.origin.y = screen.controllerContainer.bounds.origin.y
        visibleViewController?.view.frame.size.height = screen.controllerContainer.bounds.size.height
        transitioningViewController?.view.frame.origin.y = screen.controllerContainer.bounds.origin.y
        transitioningViewController?.view.frame.size.height = screen.controllerContainer.bounds.size.height
    }

}

private extension OnboardingViewController {

    func setupOnboardingControllers() {
        let categoriesController = CategoriesSelectionViewController()
        categoriesController.parentAppController = parentAppController
        categoriesController.onboardingViewController = self
        categoriesController.currentUser = currentUser
        addOnboardingViewController(categoriesController)

        let createProfileController = CreateProfileViewController()
        createProfileController.parentAppController = parentAppController
        createProfileController.onboardingViewController = self
        createProfileController.currentUser = currentUser
        addOnboardingViewController(createProfileController)
    }

}

extension OnboardingViewController: OnboardingDelegate {
    func nextAction() { proceedToNextStep(abort: false) }
    func abortAction() { proceedToNextStep(abort: true) }
}

// MARK: Child View Controller handling
extension OnboardingViewController {
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize: CGSize) -> CGSize {
        return screen.controllerContainer.frame.size
    }
}

// MARK: Button Actions
extension OnboardingViewController {

    func proceedToNextStep(abort: Bool) {
        if visibleViewController is CategoriesSelectionViewController {
            Tracker.shared.completedCategories()
            if abort {
                Tracker.shared.skippedNameBio()
            }
        }
        else if visibleViewController is CreateProfileViewController {
            Tracker.shared.addedNameBio()
            if abort {
                Tracker.shared.skippedContactImport()
            }
        }
        else if visibleViewController is InviteFriendsViewController {
            Tracker.shared.completedContactImport()
        }

        let proceedClosure: (_ success: OnboardingProceed) -> Void
        if abort {
            proceedClosure = { _ in
                self.doneOnboarding()
            }
        }
        else {
            proceedClosure = { success in
                ElloHUD.hideLoadingHudInView(self.view)
                if success == .continue {
                    self.goToNextStep()
                }
                else if success == .abort {
                    self.doneOnboarding()
                }
            }
        }

        ElloHUD.showLoadingHudInView(self.view)
        let onboardingStep = visibleViewController as! OnboardingStepController
        onboardingStep.onboardingWillProceed(abort: abort, proceedClosure: proceedClosure)
    }

}

// MARK: Screen transitions
extension OnboardingViewController {

    fileprivate func addOnboardingViewController(_ viewController: UIViewController) {
        if visibleViewController == nil {
            showFirstViewController(viewController)
        }

        onboardingViewControllers.append(viewController)
    }

    fileprivate func showFirstViewController(_ viewController: UIViewController) {
        Tracker.shared.screenAppeared(viewController)

        prepareOnboardingController(viewController)

        addChildViewController(viewController)
        screen.controllerContainer.addSubview(viewController.view)
        viewController.view.frame = screen.controllerContainer.bounds
        viewController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        viewController.didMove(toParentViewController: self)

        visibleViewController = viewController
        visibleViewControllerIndex = 0
    }

}

// MARK: Moving through the screens
extension OnboardingViewController {

    func goToNextStep() {
        self.visibleViewControllerIndex += 1

        if let nextViewController = onboardingViewControllers.safeValue(visibleViewControllerIndex) {
            goToController(nextViewController, direction: .right)
        }
        else {
            doneOnboarding()
        }
    }

    func goToPreviousStep() {
        self.visibleViewControllerIndex -= 1

        if self.visibleViewControllerIndex == -1 {
            self.visibleViewControllerIndex = 0
            return
        }

        if let prevViewController = onboardingViewControllers.safeValue(visibleViewControllerIndex) {
            goToController(prevViewController, direction: .left)
        }
    }

    fileprivate func doneOnboarding() {
        parentAppController?.doneOnboarding()
    }

    func goToController(_ viewController: UIViewController) {
        goToController(viewController, direction: .right)
    }

}

// MARK: Controller transitions
extension OnboardingViewController {

    fileprivate func goToController(_ viewController: UIViewController, direction: OnboardingDirection) {
        guard let visibleViewController = visibleViewController else { return }

        if let step = OnboardingStep(rawValue: visibleViewControllerIndex) {
            screen.styleFor(step: step)
        }

        prepareOnboardingController(viewController)

        transitionFromViewController(visibleViewController, toViewController: viewController, direction: direction)
    }

    fileprivate func prepareOnboardingController(_ viewController: UIViewController) {
        guard let onboardingStep = viewController as? OnboardingStepController else { return }
        onboardingStep.onboardingData = onboardingData
        onboardingStep.onboardingStepBegin()
    }

    fileprivate func transitionFromViewController(_ visibleViewController: UIViewController, toViewController nextViewController: UIViewController, direction: OnboardingDirection) {
        if isTransitioning {
            return
        }

        Tracker.shared.screenAppeared(nextViewController)

        visibleViewController.willMove(toParentViewController: nil)
        addChildViewController(nextViewController)

        nextViewController.view.alpha = 1
        nextViewController.view.frame = CGRect(
                x: direction.rawValue * screen.controllerContainer.frame.width,
                y: 0,
                width: screen.controllerContainer.frame.width,
                height: screen.controllerContainer.frame.height
            )

        transitioningViewController = nextViewController
        transitionControllers(
            from: visibleViewController,
            to: nextViewController,
            duration: 0.4,
            options: UIViewAnimationOptions(),
            animations: {
                self.screen.controllerContainer.insertSubview(nextViewController.view, aboveSubview: visibleViewController.view)
                visibleViewController.view.frame.origin.x = -direction.rawValue * visibleViewController.view.frame.width
                nextViewController.view.frame.origin.x = 0
            },
            completion: { _ in
                nextViewController.didMove(toParentViewController: self)
                visibleViewController.removeFromParentViewController()
                self.visibleViewController = nextViewController
                self.transitioningViewController = nil
            })
    }

}
