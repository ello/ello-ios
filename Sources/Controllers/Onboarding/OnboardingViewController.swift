////
///  OnboardingViewController.swift
//

import PINRemoteImage


public class OnboardingViewController: BaseElloViewController, HasAppController {
    private enum OnboardingDirection: CGFloat {
        case Left = -1
        case Right = 1
    }
    public enum OnboardingProceed {
        case Continue
        case Abort
        case Error
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
    private var visibleViewController: UIViewController?
    private var transitioningViewController: UIViewController?
    private var visibleViewControllerIndex: Int = 0
    private var onboardingViewControllers = [UIViewController]()

    public var hasAbortButton: Bool {
        get { return screen.hasAbortButton }
        set { screen.hasAbortButton = newValue }
    }
    public var canGoNext: Bool {
        get { return screen.canGoNext }
        set { screen.canGoNext = newValue }
    }
    public var prompt: String? {
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
                    if (memo ?? "").characters.count == 0 {
                        return link["url"] ?? ""
                    }
                    else if let url = link["url"] {
                        return "\(memo), \(url)"
                    }
                    else {
                        return memo
                    }
                }
            }

            if let url = currentUser.avatarURL()
            where url.absoluteString !~ "ello-default"
            {
                PINRemoteImageManager.sharedImageManager().downloadImageWithURL(url) { result in
                    if let animatedImage = result.animatedImage {
                        self.onboardingData.avatarImage = ImageRegionData(image: animatedImage.posterImage, data: animatedImage.data, contentType: "image/gif")
                    }
                    else if let image = result.image {
                        self.onboardingData.avatarImage = ImageRegionData(image: image)
                    }
                }
            }

            if let url = currentUser.coverImageURL()
            where url.absoluteString !~ "ello-default"
            {
                PINRemoteImageManager.sharedImageManager().downloadImageWithURL(url) { result in
                    if let animatedImage = result.animatedImage {
                        self.onboardingData.coverImage = ImageRegionData(image: animatedImage.posterImage, data: animatedImage.data, contentType: "image/gif")
                    }
                    else if let image = result.image {
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

    override public func loadView() {
        let screen = OnboardingScreen()
        screen.delegate = self
        self.view = screen
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupOnboardingControllers()
    }

    override public func viewDidLayoutSubviews() {
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
    public func nextAction() { proceedToNextStep(abort: false) }
    public func abortAction() { proceedToNextStep(abort: true) }
}

// MARK: Child View Controller handling
extension OnboardingViewController {
    override public func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize: CGSize) -> CGSize {
        return screen.controllerContainer.frame.size
    }
}

// MARK: Button Actions
extension OnboardingViewController {

    public func proceedToNextStep(abort abort: Bool) {
        if visibleViewController is CategoriesSelectionViewController {
            Tracker.sharedTracker.completedCategories()
            if abort {
                Tracker.sharedTracker.skippedNameBio()
            }
        }
        else if visibleViewController is CreateProfileViewController {
            Tracker.sharedTracker.addedNameBio()
            if abort {
                Tracker.sharedTracker.skippedContactImport()
            }
        }
        else if visibleViewController is InviteFriendsViewController {
            Tracker.sharedTracker.completedContactImport()
        }

        let proceedClosure: (success: OnboardingProceed) -> Void
        if abort {
            proceedClosure = { _ in
                self.doneOnboarding()
            }
        }
        else {
            proceedClosure = { success in
                ElloHUD.hideLoadingHudInView(self.view)
                if success == .Continue {
                    self.goToNextStep()
                }
                else if success == .Abort {
                    self.doneOnboarding()
                }
            }
        }

        ElloHUD.showLoadingHudInView(self.view)
        let onboardingStep = visibleViewController as! OnboardingStepController
        onboardingStep.onboardingWillProceed(abort, proceedClosure: proceedClosure)
    }

}

// MARK: Screen transitions
extension OnboardingViewController {

    private func showFirstViewController(viewController: UIViewController) {
        Tracker.sharedTracker.screenAppeared(viewController)

        prepareOnboardingController(viewController)

        addChildViewController(viewController)
        screen.controllerContainer.addSubview(viewController.view)
        viewController.view.frame = screen.controllerContainer.bounds
        viewController.view.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        viewController.didMoveToParentViewController(self)

        visibleViewController = viewController
        visibleViewControllerIndex = 0
    }

    private func addOnboardingViewController(viewController: UIViewController) {
        if visibleViewController == nil {
            showFirstViewController(viewController)
        }

        onboardingViewControllers.append(viewController)
    }

}

// MARK: Moving through the screens
extension OnboardingViewController {

    public func goToNextStep() {
        self.visibleViewControllerIndex += 1

        if let nextViewController = onboardingViewControllers.safeValue(visibleViewControllerIndex) {
            goToController(nextViewController, direction: .Right)
        }
        else {
            doneOnboarding()
        }
    }

    public func goToPreviousStep() {
        self.visibleViewControllerIndex -= 1

        if self.visibleViewControllerIndex == -1 {
            self.visibleViewControllerIndex = 0
            return
        }

        if let prevViewController = onboardingViewControllers.safeValue(visibleViewControllerIndex) {
            goToController(prevViewController, direction: .Left)
        }
    }

    private func doneOnboarding() {
        parentAppController?.doneOnboarding()
    }

    public func goToController(viewController: UIViewController) {
        goToController(viewController, direction: .Right)
    }

}

// MARK: Controller transitions
extension OnboardingViewController {

    private func goToController(viewController: UIViewController, direction: OnboardingDirection) {
        guard let visibleViewController = visibleViewController else { return }

        if let step = OnboardingStep(rawValue: visibleViewControllerIndex) {
            screen.styleFor(step: step)
        }

        prepareOnboardingController(viewController)

        transitionFromViewController(visibleViewController, toViewController: viewController, direction: direction)
    }

    private func prepareOnboardingController(viewController: UIViewController) {
        guard let onboardingStep = viewController as? OnboardingStepController else { return }
        onboardingStep.onboardingData = onboardingData
        onboardingStep.onboardingStepBegin()
    }

    private func transitionFromViewController(visibleViewController: UIViewController, toViewController nextViewController: UIViewController, direction: OnboardingDirection) {
        if isTransitioning {
            return
        }

        Tracker.sharedTracker.screenAppeared(nextViewController)

        visibleViewController.willMoveToParentViewController(nil)
        addChildViewController(nextViewController)

        nextViewController.view.alpha = 1
        nextViewController.view.frame = CGRect(
                x: direction.rawValue * screen.controllerContainer.frame.width,
                y: 0,
                width: screen.controllerContainer.frame.width,
                height: screen.controllerContainer.frame.height
            )

        transitioningViewController = nextViewController
        transition(
            from: visibleViewController,
            to: nextViewController,
            duration: 0.4,
            options: .TransitionNone,
            animations: {
                self.screen.controllerContainer.insertSubview(nextViewController.view, aboveSubview: visibleViewController.view)
                visibleViewController.view.frame.origin.x = -direction.rawValue * visibleViewController.view.frame.width
                nextViewController.view.frame.origin.x = 0
            },
            completion: { _ in
                nextViewController.didMoveToParentViewController(self)
                visibleViewController.removeFromParentViewController()
                self.visibleViewController = nextViewController
                self.transitioningViewController = nil
            })
    }

}
