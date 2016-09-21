////
///  InviteFriendsViewController.swift
//

public class InviteFriendsViewController: StreamableViewController {
    let addressBook: AddressBookProtocol
    var mockScreen: Screen?
    var screen: Screen { return mockScreen ?? (self.view as! Screen) }
    var parentAppController: AppViewController?
    var searchString = SearchString(text: "")
    public var onboardingViewController: OnboardingViewController?
    public var onboardingData: OnboardingData!

    required public init(addressBook: AddressBookProtocol) {
        self.addressBook = addressBook
        super.init(nibName: nil, bundle: nil)

        streamViewController.initialLoadClosure = { [unowned self] in self.findFriendsFromContacts() }
        streamViewController.pullToRefreshEnabled = false
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
        streamViewController.searchStreamDelegate = self
        scrollLogic.prevOffset = streamViewController.collectionView.contentOffset
        streamViewController.loadInitialPage()
    }

    override public func showNavBars(scrollToBottom: Bool) {}
    override public func hideNavBars() {}
}

extension InviteFriendsViewController {
    private func findFriendsFromContacts() {
        ElloHUD.showLoadingHudInView(view)
        InviteService().find(addressBook,
            currentUser: self.currentUser,
            success: { mixedContacts in
                self.streamViewController.clearForInitialLoad()
                self.setContacts(mixedContacts)
                self.streamViewController.doneLoading()
            },
            failure: { _ in
                let mixedContacts: [(LocalPerson, User?)] = self.addressBook.localPeople.map { ($0, .None) }
                self.setContacts(mixedContacts)
                self.streamViewController.doneLoading()
            })
    }

    private func setContacts(contacts: [(LocalPerson, User?)]) {
        ElloHUD.hideLoadingHudInView(view)

        let header = NSAttributedString(
            primaryHeader: InterfaceString.Onboard.InviteFriendsPrimary,
            secondaryHeader: InterfaceString.Onboard.InviteFriendsSecondary
            )
        let headerCellItem = StreamCellItem(type: .TextHeader(header))
        let searchItem = StreamCellItem(jsonable: searchString, type: .Search(placeholder: InterfaceString.Onboard.Search))

        let items = [headerCellItem, searchItem] + AddressBookHelpers.process(contacts, currentUser: currentUser)
        streamViewController.appendStreamCellItems(items)
    }
}

extension InviteFriendsViewController: OnboardingStepController {
    public func onboardingStepBegin() {
        onboardingViewController?.hasAbortButton = false
        onboardingViewController?.canGoNext = true
    }

    public func onboardingWillProceed(abort: Bool, proceedClosure: (success: OnboardingViewController.OnboardingProceed) -> Void) {
        proceedClosure(success: .Continue)
    }
}

extension InviteFriendsViewController: SearchStreamDelegate {
    public func searchFieldChanged(text: String) {
        searchString.text = text
        streamViewController.batchUpdateFilter(AddressBookHelpers.searchFilter(text))
    }
}
