////
///  OnboardingInviteViewController.swift
//

class OnboardingInviteViewController: StreamableViewController {
    let addressBook: AddressBookProtocol
    var mockScreen: StreamableScreenProtocol?
    var screen: StreamableScreenProtocol { return mockScreen ?? (self.view as! StreamableScreen) }
    var searchString = SearchString(text: "")
    var onboardingViewController: OnboardingViewController?
    // completely unused internally, and shouldn't be, since this controller is
    // used outside of onboarding. here only for protocol conformance.
    var onboardingData: OnboardingData!

    required init(addressBook: AddressBookProtocol) {
        self.addressBook = addressBook
        super.init(nibName: nil, bundle: nil)
        title = InterfaceString.Drawer.Invite

        streamViewController.initialLoadClosure = { [weak self] in self?.findFriendsFromContacts() }
        streamViewController.isPullToRefreshEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let screen = StreamableScreen()
        self.view = screen
        viewContainer = screen
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        streamViewController.loadInitialPage()

        if onboardingViewController != nil {
            screen.navigationBar.isHidden = true
        }

        setupNavigationItems()
    }

    override func viewForStream() -> UIView {
        return screen.viewForStream()
    }

    override func showNavBars() {
        guard onboardingViewController == nil else { return }

        super.showNavBars()

        positionNavBar(screen.navigationBar, visible: true, withConstraint: screen.navigationBarTopConstraint)
        updateInsets()
    }

    override func hideNavBars() {
        guard onboardingViewController == nil else { return }

        super.hideNavBars()

        positionNavBar(screen.navigationBar, visible: false, withConstraint: screen.navigationBarTopConstraint)
        updateInsets()
    }

    private func updateInsets() {
        updateInsets(navBar: screen.navigationBar)
    }

}

extension OnboardingInviteViewController {

    func setupNavigationItems() {
        if let navigationController = navigationController,
            navigationController.viewControllers.first != self
        {
            screen.navigationBar.leftItems = [.back]
        }
        else {
            screen.navigationBar.leftItems = [.close]
        }
    }

    private func findFriendsFromContacts() {
        ElloHUD.showLoadingHudInView(view)
        InviteService().find(addressBook, currentUser: self.currentUser)
            .then { mixedContacts -> Void in
                self.streamViewController.clearForInitialLoad()
                self.setContacts(mixedContacts)
                self.streamViewController.doneLoading()
            }
            .catch { _ in
                let mixedContacts: [(LocalPerson, User?)] = self.addressBook.localPeople.map { ($0, .none) }
                self.setContacts(mixedContacts)
                self.streamViewController.doneLoading()
            }
    }

    private func setContacts(_ contacts: [(LocalPerson, User?)]) {
        ElloHUD.hideLoadingHudInView(view)

        let header = NSAttributedString(
            primaryHeader: InterfaceString.Onboard.InviteFriendsPrimary,
            secondaryHeader: InterfaceString.Onboard.InviteFriendsSecondary
            )
        let headerCellItem = StreamCellItem(type: .tallHeader(header))
        let searchItem = StreamCellItem(jsonable: searchString, type: .search(placeholder: InterfaceString.Onboard.Search))

        let addressBookItems: [StreamCellItem] = AddressBookHelpers.process(contacts, currentUser: currentUser).map { item in
            if item.type == .inviteFriends {
                item.type = .onboardingInviteFriends
            }
            return item
        }
        let items = [headerCellItem, searchItem] + addressBookItems
        streamViewController.appendStreamCellItems(items)
    }
}

extension OnboardingInviteViewController: OnboardingStepController {

    func onboardingStepBegin() {
        onboardingViewController?.hasAbortButton = false
        onboardingViewController?.canGoNext = true
    }

    func onboardingWillProceed(abort: Bool, proceedClosure: @escaping (_ success: OnboardingViewController.OnboardingProceed) -> Void) {
        proceedClosure(.continue)
    }
}

extension OnboardingInviteViewController: SearchStreamResponder {

    func searchFieldChanged(text: String) {
        searchString.text = text
        streamViewController.batchUpdateFilter(AddressBookHelpers.searchFilter(text))
    }
}
