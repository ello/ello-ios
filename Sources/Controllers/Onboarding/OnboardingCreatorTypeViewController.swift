////
///  OnboardingCreatorTypeViewController.swift
//

import PromiseKit


class OnboardingCreatorTypeViewController: BaseElloViewController {
    private var _mockScreen: OnboardingCreatorTypeScreenProtocol?
    var screen: OnboardingCreatorTypeScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return _mockScreen ?? (self.view as! OnboardingCreatorTypeScreen) }
    }

    var categories: [Category]?
    var creatorType: Profile.CreatorType {
        get { return _creatorType }
        set {
            _creatorType = newValue
            screen.updateCreatorType(type: newValue)
        }
    }
    fileprivate var _creatorType: Profile.CreatorType = .none

    var onboardingViewController: OnboardingViewController?
    var onboardingData: OnboardingData!
    weak var delegate: DynamicSettingsDelegate?

    override var navigationBarsVisible: Bool? { return true }

    override func loadView() {
        let screen = OnboardingCreatorTypeScreen()
        screen.delegate = self
        self.view = screen
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

            let backItem = UIBarButtonItem.backChevron(withController: self)
            let elloNavigationItem = UINavigationItem()
            elloNavigationItem.title = InterfaceString.Settings.CreatorType
            elloNavigationItem.leftBarButtonItems = [backItem]
            elloNavigationItem.fixNavBarItemPadding()

            screen.navigationItem = elloNavigationItem
            postNotification(StatusBarNotifications.statusBarVisibility, value: true)
        }

        CategoryService().loadCreatorCategories()
            .thenFinally { categories in
                self.categories = categories
                self.screen.creatorCategories = categories.map { $0.name }
                self.screen.updateCreatorType(type: self.creatorType)
            }
            .ignoreErrors()
    }

    @IBAction
    override func backTapped() {
        super.backTapped()
        saveCreatorType()
            .thenFinally { user in
                self.delegate?.dynamicSettingsUserChanged(user)
            }
            .catch { error in
                let alertController = AlertViewController(error: InterfaceString.GenericError)
                self.appViewController?.present(alertController, animated: true, completion: nil)
            }
    }

    override func updateNavBars() {
        super.updateNavBars()

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
        if onboardingVersion < Onboarding.minCreatorTypeVersion {
            onboardingViewController?.prompt = InterfaceString.Onboard.CreateAccount
        }
        else {
            onboardingViewController?.prompt = InterfaceString.Onboard.ImDone
        }
    }

    func onboardingWillProceed(abort: Bool, proceedClosure: @escaping (_ success: OnboardingViewController.OnboardingProceed) -> Void) {
        guard creatorType.isValid else { return }

        saveCreatorType()
            .thenFinally { _ in
                self.onboardingData.creatorType = self.creatorType
                proceedClosure(.continue)
            }
            .catch { _ in
                let alertController = AlertViewController(error: InterfaceString.GenericError)
                self.appViewController?.present(alertController, animated: true, completion: nil)
                proceedClosure(.error)
        }
    }
}
