////
///  InviteFriendsViewController.swift
//

class InviteFriendsViewController: StreamableViewController {
    let addressBook: AddressBookProtocol
    var mockScreen: Screen?
    var screen: Screen { return mockScreen ?? (self.view as! Screen) }
    var parentAppController: AppViewController?
    var searchString = SearchString(text: "")
    var onboardingViewController: OnboardingViewController?
    var onboardingData: OnboardingData!

    required init(addressBook: AddressBookProtocol) {
        self.addressBook = addressBook
        super.init(nibName: nil, bundle: nil)

        streamViewController.initialLoadClosure = { [unowned self] in self.findFriendsFromContacts() }
        streamViewController.pullToRefreshEnabled = false
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let screen = Screen()
        self.view = screen
        viewContainer = screen
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        streamViewController.searchStreamDelegate = self
        streamViewController.loadInitialPage()
    }

    override func showNavBars() {}
    override func hideNavBars() {}
}

extension InviteFriendsViewController {
    fileprivate func findFriendsFromContacts() {
        ElloHUD.showLoadingHudInView(view)
        InviteService().find(addressBook,
            currentUser: self.currentUser,
            success: { mixedContacts in
                self.streamViewController.clearForInitialLoad()
                self.setContacts(mixedContacts)
                self.streamViewController.doneLoading()
            },
            failure: { _ in
                let mixedContacts: [(LocalPerson, User?)] = self.addressBook.localPeople.map { ($0, .none) }
                self.setContacts(mixedContacts)
                self.streamViewController.doneLoading()
            })
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

extension InviteFriendsViewController: SearchStreamDelegate {
    func searchFieldChanged(text: String) {
        searchString.text = text
        streamViewController.batchUpdateFilter(AddressBookHelpers.searchFilter(text))
    }
}
