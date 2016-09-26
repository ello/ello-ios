////
///  CategoriesSelectionViewController.swift
//

public class CategoriesSelectionViewController: StreamableViewController, HasAppController {
    var mockScreen: Screen?
    var screen: Screen { return mockScreen ?? (self.view as! Screen) }
    var parentAppController: AppViewController?
    var selectedCategories: [Category] = []
    public var onboardingViewController: OnboardingViewController?
    public var onboardingData: OnboardingData!

    required public init() {
        super.init(nibName: nil, bundle: nil)
        streamViewController.streamKind = .AllCategories
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        let screen = Screen()
        self.view = screen
        viewContainer = screen
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        streamViewController.contentInset = UIEdgeInsetsZero
        streamViewController.selectedCategoryDelegate = self
        scrollLogic.prevOffset = streamViewController.collectionView.contentOffset
        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.loadInitialPage()
    }

    override public func showNavBars(scrollToBottom: Bool) {}
    override public func hideNavBars() {}

    override public func streamViewStreamCellItems(jsonables: [JSONAble], defaultGenerator generator: StreamCellItemGenerator) -> [StreamCellItem]? {
        let header = NSAttributedString(
            primaryHeader: InterfaceString.Onboard.PickCategoriesPrimary,
            secondaryHeader: InterfaceString.Onboard.PickCategoriesSecondary
            )
        let headerCellItem = StreamCellItem(type: .TextHeader(header))
        var items: [StreamCellItem] = [headerCellItem]

        if let categories = jsonables as? [Category] {
            let onboardingCategories = categories.filter { $0.allowInOnboarding }
            items += onboardingCategories.map { StreamCellItem(jsonable: $0, type: .SelectableCategoryCard) }
        }
        return items
    }
}

extension CategoriesSelectionViewController: OnboardingStepController {
    public func onboardingStepBegin() {
        let prompt = NSString(format: InterfaceString.Onboard.PickTemplate, 3) as String
        onboardingViewController?.hasAbortButton = false
        onboardingViewController?.canGoNext = false
        onboardingViewController?.prompt = prompt
    }

    public func onboardingWillProceed(abort: Bool, proceedClosure: (success: OnboardingViewController.OnboardingProceed) -> Void) {
        if selectedCategories.count > 0 {
            let categories = self.selectedCategories
            for category in categories {
                Tracker.sharedTracker.categorySelected(category)
            }

            UserService().setUserCategories(categories)
                .onSuccess { _ in
                    // onboarding can be considered "done", even if they abort the app
                    Onboarding.shared().updateVersionToLatest()

                    self.onboardingData.categories = categories
                    proceedClosure(success: .Continue)
                }
                .onFail { _ in
                    let alertController = AlertViewController(error: InterfaceString.GenericError)
                    self.parentAppController?.presentViewController(alertController, animated: true, completion: nil)
                    proceedClosure(success: .Error)
                }
        }
    }
}

extension CategoriesSelectionViewController: SelectedCategoryDelegate {
    public func categoriesSelectionChanged(selection: [Category]) {
        let selectionCount = selection.count
        let prompt: String?
        let canGoNext: Bool
        switch selectionCount {
        case 0, 1, 2:
            prompt = NSString(format: InterfaceString.Onboard.PickTemplate, 3 - selectionCount) as String
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
