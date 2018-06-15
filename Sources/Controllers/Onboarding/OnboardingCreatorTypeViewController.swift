////
///  OnboardingCreatorTypeViewController.swift
//

import PromiseKit


class OnboardingCreatorTypeViewController: BaseElloViewController {
    private var _mockScreen: OnboardingCreatorTypeScreenProtocol?
    var screen: OnboardingCreatorTypeScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return fetchScreen(_mockScreen) }
    }

    var categories: [Category]?
    var creatorType: Profile.CreatorType {
        get { return _creatorType }
        set {
            _creatorType = newValue
            if isViewLoaded {
                screen.updateCreatorType(type: newValue)
            }
        }
    }
    private var _creatorType: Profile.CreatorType = .none

    var onboardingViewController: OnboardingViewController?
    var onboardingData: OnboardingData!
    weak var delegate: DynamicSettingsDelegate?

    override var navigationBarsVisible: Bool? { return true }

    override func loadView() {
        let screen = OnboardingCreatorTypeScreen()
        screen.delegate = self
        screen.showIntroText = false

        view = screen
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let isOnboarding = onboardingViewController != nil
        if isOnboarding {
            screen.topInset = 0
            screen.navigationBar.isHidden = true
        }
        else {
            screen.topInset = ElloNavigationBar.Size.height
            updatesBottomBar = false

            screen.navigationBar.title = InterfaceString.Settings.CreatorType
            screen.navigationBar.leftItems = [.back]
            postNotification(StatusBarNotifications.statusBarVisibility, value: true)
        }

        CategoryService().loadCreatorCategories()
            .done { categories in
                self.categories = categories
                self.screen.creatorCategories = categories.map { $0.name }
                self.screen.updateCreatorType(type: self.creatorType)
            }
            .ignoreErrors()
    }

    override func backButtonTapped() {
        super.backButtonTapped()
        saveCreatorType()
            .done { user in
                self.delegate?.dynamicSettingsUserChanged(user)
            }
            .catch { error in
                let alertController = AlertViewController(confirmation: InterfaceString.GenericError)
                self.appViewController?.present(alertController, animated: true, completion: nil)
            }
    }

    override func updateNavBars(animated: Bool) {
        super.updateNavBars(animated: animated)

        if bottomBarController?.bottomBarVisible == true {
            screen.bottomInset = ElloTabBar.Size.height
        }
        else {
            screen.bottomInset = 0
        }
    }

}

extension OnboardingCreatorTypeViewController: OnboardingCreatorTypeDelegate {

    func creatorTypeChanged(type: OnboardingCreatorTypeScreen.CreatorType) {
        switch type {
        case .none:
            _creatorType = .none
        case .fan:
            _creatorType = .fan
        case let .artist(selections):
            if let categories = categories {
                let selectedCategories = selections.map { categories[$0] }
                _creatorType = .artist(selectedCategories)
            }
            else {
                _creatorType = .none
            }
        }

        onboardingViewController?.canGoNext = _creatorType.isValid
    }

}

extension OnboardingCreatorTypeViewController: OnboardingStepController {

    @discardableResult
    func saveCreatorType() -> Promise<User> {
        let ids: [String]
        if case let .artist(selectedCategories) = creatorType {
            ids = selectedCategories.map { $0.id }
        }
        else {
            ids = []
        }
        return ProfileService().updateUserProfile([.creatorTypeCategoryIds: ids])
    }

    func onboardingStepBegin() {
        onboardingViewController?.hasAbortButton = false
        onboardingViewController?.canGoNext = false

        let onboardingVersion = currentUser?.onboardingVersion ?? 0
        let showAllOnboarding = onboardingVersion < Onboarding.minCreatorTypeVersion
        if showAllOnboarding {
            onboardingViewController?.prompt = InterfaceString.Onboard.CreateAccount
        }
        else {
            onboardingViewController?.prompt = InterfaceString.Submit
        }
        screen.showIntroText = !showAllOnboarding
    }

    func onboardingWillProceed(abort: Bool, proceedClosure: @escaping (_ success: OnboardingViewController.OnboardingProceed) -> Void) {
        guard creatorType.isValid else {
            proceedClosure(.error)
            return
        }

        saveCreatorType()
            .done { _ in
                Tracker.shared.onboardingCreatorTypeSelected(self.creatorType)
                self.onboardingData.creatorType = self.creatorType
                proceedClosure(.continue)
            }
            .catch { _ in
                let alertController = AlertViewController(confirmation: InterfaceString.GenericError)
                self.appViewController?.present(alertController, animated: true, completion: nil)
                proceedClosure(.error)
        }
    }
}
