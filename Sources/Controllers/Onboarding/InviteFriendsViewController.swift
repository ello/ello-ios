////
///  InviteFriendsViewController.swift
//

class InviteFriendsViewController: StreamableViewController {
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

        streamViewController.initialLoadClosure = { [unowned self] in self.findFriendsFromContacts() }
        streamViewController.pullToRefreshEnabled = false
    }

    required init?(coder aDecoder: NSCoder) {
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

    fileprivate func updateInsets() {
        updateInsets(navBar: screen.navigationBar)
    }

}

extension InviteFriendsViewController {

    func setupNavigationItems() {
        if let navigationController = navigationController,
            navigationController.viewControllers.first != self
        {
            let backItem = UIBarButtonItem.backChevron(withController: self)
            elloNavigationItem.leftBarButtonItems = [backItem]
            elloNavigationItem.fixNavBarItemPadding()
        }
        else {
            let closeItem = UIBarButtonItem.closeButton(target: self, action: #selector(closeTapped))
            elloNavigationItem.leftBarButtonItems = [closeItem]
        }

        screen.navigationItem = elloNavigationItem
    }

    fileprivate func findFriendsFromContacts() {
        ElloHUD.showLoadingHudInView(view)
        InviteService().find(addressBook, currentUser: self.currentUser)
            .onSuccess { mixedContacts in
                self.streamViewController.clearForInitialLoad()
                self.setContacts(mixedContacts)
                self.streamViewController.doneLoading()
            }
            .onFail { _ in
                let mixedContacts: [(LocalPerson, User?)] = self.addressBook.localPeople.map { ($0, .none) }
                self.setContacts(mixedContacts)
                self.streamViewController.doneLoading()
            }
    }

    fileprivate func setContacts(_ contacts: [(LocalPerson, User?)]) {
        ElloHUD.hideLoadingHudInView(view)

        let header = NSAttributedString(
            primaryHeader: InterfaceString.Onboard.InviteFriendsPrimary,
            secondaryHeader: InterfaceString.Onboard.InviteFriendsSecondary
            )
        let headerCellItem = StreamCellItem(type: .textHeader(header))
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

extension InviteFriendsViewController: OnboardingStepController {

    func onboardingStepBegin() {
        onboardingViewController?.hasAbortButton = false
        onboardingViewController?.canGoNext = true
    }

    func onboardingWillProceed(abort: Bool, proceedClosure: @escaping (_ success: OnboardingViewController.OnboardingProceed) -> Void) {
        proceedClosure(.continue)
    }
}

extension InviteFriendsViewController: SearchStreamResponder {

    func searchFieldChanged(text: String) {
        searchString.text = text
        streamViewController.batchUpdateFilter(AddressBookHelpers.searchFilter(text))
    }
}
