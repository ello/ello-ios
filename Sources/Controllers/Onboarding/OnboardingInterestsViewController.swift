////
///  OnboardingInterestsViewController.swift
//

class OnboardingInterestsViewController: StreamableViewController {
    var mockScreen: Screen?
    var screen: Screen { return mockScreen ?? (self.view as! Screen) }
    var selectedCategories: [Category] = []
    var onboardingViewController: OnboardingViewController?
    var onboardingData: OnboardingData!

    required init() {
        super.init(nibName: nil, bundle: nil)
        streamViewController.streamKind = .onboardingCategories
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let screen = Screen()
        view = screen
        viewContainer = screen
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        streamViewController.isPullToRefreshEnabled = false
        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.loadInitialPage()
    }

    override func showNavBars(animated: Bool) {}
    override func hideNavBars(animated: Bool) {}

    override func streamViewStreamCellItems(jsonables: [Model], defaultGenerator generator: StreamCellItemGenerator) -> [StreamCellItem]? {
        let header = NSAttributedString(
            primaryHeader: InterfaceString.Onboard.PickCategoriesPrimary,
            secondaryHeader: InterfaceString.Onboard.PickCategoriesSecondary
            )
        let headerCellItem = StreamCellItem(type: .tallHeader(header))
        var items: [StreamCellItem] = [headerCellItem]

        if let categories = jsonables as? [Category] {
            let onboardingCategories = categories.filter { $0.allowInOnboarding }
            items += onboardingCategories.map { StreamCellItem(jsonable: $0, type: .onboardingCategoryCard) }
        }
        return items
    }
}

extension OnboardingInterestsViewController: OnboardingStepController {

    func onboardingStepBegin() {
        let prompt = InterfaceString.Onboard.Pick(3)
        onboardingViewController?.hasAbortButton = false
        onboardingViewController?.canGoNext = false
        onboardingViewController?.prompt = prompt
    }

    func onboardingWillProceed(abort: Bool, proceedClosure: @escaping (_ success: OnboardingViewController.OnboardingProceed) -> Void) {
        guard selectedCategories.count > 0 else { return }

        onboardingData.categories = selectedCategories
        for category in selectedCategories {
            Tracker.shared.onboardingCategorySelected(category)
        }

        ProfileService().update(categories: selectedCategories, onboarding: true)
            .done { _ in
                proceedClosure(.continue)
            }
            .catch { [weak self] _ in
                guard let `self` = self else { return }

                let alertController = AlertViewController(confirmation: InterfaceString.GenericError)
                self.appViewController?.present(alertController, animated: true, completion: nil)
                proceedClosure(.error)
            }
    }
}

extension OnboardingInterestsViewController: SelectedCategoryResponder {

    func categoriesSelectionChanged(selection: [Category]) {
        let selectionCount = selection.count
        let prompt: String?
        let canGoNext: Bool
        switch selectionCount {
        case 0, 1, 2:
            prompt = InterfaceString.Onboard.Pick(3 - selectionCount)
            canGoNext = false
        default:
            prompt = nil
            canGoNext = true
        }

        selectedCategories = selection
        onboardingViewController?.prompt = prompt
        onboardingViewController?.canGoNext = canGoNext
    }
}
