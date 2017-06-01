////
///  SearchViewController.swift
//

class SearchViewController: StreamableViewController {
    override func trackerName() -> String? {
        let searchFor: String
        if isPostSearch {
            searchFor = "Posts"
        }
        else {
            searchFor = "Users"
        }
        return "Search for \(searchFor)"
    }
    override func trackerStreamInfo() -> (String, String?)? {
        return ("search", nil)
    }

    var searchText: String?
    var isPostSearch = true

    private var _mockScreen: SearchScreenProtocol?
    var screen: SearchScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return _mockScreen ?? self.view as! SearchScreen }
    }

    override func loadView() {
        let screen = SearchScreen()
        screen.delegate = self
        screen.showsFindFriends = currentUser != nil
        self.view = screen
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let streamKind = StreamKind.simpleStream(endpoint: .searchForPosts(terms: ""), title: "")
        streamViewController.streamKind = streamKind
        screen.isGridView = streamKind.isGridView
        streamViewController.pullToRefreshEnabled = false

        updateInsets()
    }

    func searchForPosts(_ terms: String) {
        screen.searchFor(terms)
    }

    override func viewForStream() -> UIView {
        return screen.viewForStream()
    }

    override func showNavBars() {
        super.showNavBars()
        positionNavBar(screen.navigationBar, visible: true, withConstraint: screen.navigationBarTopConstraint)
        screen.showNavBars()
        updateInsets()
    }

    override func hideNavBars() {
        super.hideNavBars()
        positionNavBar(screen.navigationBar, visible: false, withConstraint: screen.navigationBarTopConstraint)
        screen.hideNavBars()
        updateInsets()
    }

    fileprivate func updateInsets() {
        updateInsets(navBar: screen.topInsetView)
    }

}

extension SearchViewController: SearchScreenDelegate {

    func searchCanceled() {
       _ = navigationController?.popViewController(animated: true)
    }

    func searchFieldCleared() {
        showNavBars()
        searchText = ""
        streamViewController.removeAllCellItems()
        streamViewController.loadingToken.cancelInitialPage()
        streamViewController.noResultsMessages = NoResultsMessages(title: "", body: "")
    }

    func searchFieldChanged(_ text: String, isPostSearch: Bool) {
        loadEndpoint(text, isPostSearch: isPostSearch)
    }

    func searchShouldReset() {
        streamViewController.hideNoResults()
    }

    func toggleChanged(_ text: String, isPostSearch: Bool) {
        searchShouldReset()
        loadEndpoint(text, isPostSearch: isPostSearch, checkSearchText: false)
    }

    func gridListToggled(sender: UIButton) {
        streamViewController.gridListToggled(sender)
    }

    func findFriendsTapped() {
        let responder: InviteResponder? = findResponder()
        responder?.onInviteFriends()
    }

    fileprivate func loadEndpoint(_ text: String, isPostSearch: Bool, checkSearchText: Bool = true) {
        guard
            text.characters.count > 2,  // just.. no (and the server doesn't guard against empty/short searches)
            !checkSearchText || searchText != text  // a search is already in progress for this text
        else { return }

        self.isPostSearch = isPostSearch
        streamViewController.hideNoResults()
        searchText = text
        let endpoint = isPostSearch ? ElloAPI.searchForPosts(terms: text) : ElloAPI.searchForUsers(terms: text)
        streamViewController.noResultsMessages = NoResultsMessages(title: InterfaceString.Search.NoMatches, body: InterfaceString.Search.TryAgain)
        let streamKind = StreamKind.simpleStream(endpoint: endpoint, title: "")
        streamViewController.streamKind = streamKind
        streamViewController.removeAllCellItems()
        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.loadInitialPage()

        trackSearch()
    }

    func trackSearch() {
        guard let text = searchText else { return }

        trackScreenAppeared()

        if isPostSearch {
            if text.hasPrefix("#") {
                Tracker.shared.searchFor("hashtags", text)
            }
            else {
                Tracker.shared.searchFor("posts", text)
            }
        }
        else {
            Tracker.shared.searchFor("users", text)
        }
    }
}
