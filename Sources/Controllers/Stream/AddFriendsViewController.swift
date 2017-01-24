////
///  AddFriendsViewController.swift
//

class AddFriendsViewController: StreamableViewController {

    let addressBook: AddressBookProtocol

    var _mockScreen: SearchScreenProtocol?
    var screen: SearchScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return _mockScreen ?? self.view as! SearchScreen }
    }
    var searchScreen: SearchScreen!

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
        searchScreen = SearchScreen(frame: UIScreen.main.bounds,
            isSearchView: false,
            navBarTitle: InterfaceString.Friends.FindAndInvite,
            fieldPlaceholderText: InterfaceString.Friends.SearchPrompt)
        self.view = searchScreen
        searchScreen.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        screen.hasBackButton = (navigationController != nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isMovingToParentViewController || presentingViewController != nil {
            showNavBars()
            updateInsets()
            ElloHUD.showLoadingHudInView(streamViewController.view)
            streamViewController.loadInitialPage()
        }
    }

    override func viewForStream() -> UIView {
        return screen.viewForStream()
    }

    override func showNavBars() {
        super.showNavBars()
        if let ss = self.view as? SearchScreen {
            positionNavBar(ss.navigationBar, visible: true)
            ss.showNavBars()
        }
        updateInsets()
    }

    override func hideNavBars() {
        super.hideNavBars()
        if let ss = self.view as? SearchScreen {
            positionNavBar(ss.navigationBar, visible: false)
            ss.hideNavBars()
        }
        updateInsets()
    }

    fileprivate func updateInsets() {
        if let ss = self.view as? SearchScreen {
            updateInsets(navBar: ss.navigationBar, streamController: streamViewController, tabBarVisible: false)
        }
    }

    func setContacts(_ contacts: [(LocalPerson, User?)]) {
        let items = AddressBookHelpers.process(contacts, currentUser: currentUser)
        streamViewController.appendStreamCellItems(items)
    }

    // MARK: - Private

    fileprivate func findFriendsFromContacts() {
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
}

extension AddFriendsViewController: SearchScreenDelegate {

    func searchCanceled() {
        if let navigationController = navigationController {
            _ = navigationController.popViewController(animated: true)
        }
        else {
            dismiss(animated: true, completion: nil)
        }
    }

    func searchFieldCleared() {
        streamViewController.streamFilter = nil
    }

    func searchFieldChanged(_ text: String, isPostSearch: Bool) {
        streamViewController.streamFilter = AddressBookHelpers.searchFilter(text)
    }

    func searchShouldReset() {
        // noop
    }

    func toggleChanged(_ text: String, isPostSearch: Bool) {
        // do nothing as this should not be visible
    }

    func findFriendsTapped() {
        // noop
    }

}
