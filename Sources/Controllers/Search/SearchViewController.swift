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

    var searchText: String?
    var isPostSearch = true

    var _mockScreen: SearchScreenProtocol?
    var screen: SearchScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return _mockScreen ?? self.view as! SearchScreenProtocol }
    }

    override func loadView() {
        let screen = SearchScreen(frame: UIScreen.main.bounds, isSearchView: true)
        self.view = screen
        screen.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        streamViewController.pullToRefreshEnabled = false
        screen.gridListItem = UIBarButtonItem.gridListItem(delegate: streamViewController, isGridView: streamViewController.streamKind.isGridView)
        screen.hasGridViewToggle = streamViewController.streamKind.hasGridViewToggle
        updateInsets()
    }

    func searchForPosts(_ terms: String) {
        screen.searchField.text = terms
        screen.searchForText()
    }

    override func viewForStream() -> UIView {
        return screen.viewForStream()
    }

    override func showNavBars() {
        super.showNavBars()
        positionNavBar(screen.navigationBar, visible: true)
        screen.showNavBars()
        updateInsets()
    }

    override func hideNavBars() {
        super.hideNavBars()
        positionNavBar(screen.navigationBar, visible: false)
        screen.hideNavBars()
        updateInsets()
    }

    fileprivate func updateInsets() {
        updateInsets(navBar: screen.searchControlsContainer, streamController: streamViewController)
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
        streamViewController.noResultsMessages = (title: "", body: "")
        screen.hasGridViewToggle = false
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

    func findFriendsTapped() {
        let responder = target(forAction: #selector(InviteResponder.onInviteFriends), withSender: self) as? InviteResponder
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
        streamViewController.noResultsMessages = (title: InterfaceString.Search.NoMatches, body: InterfaceString.Search.TryAgain)
        let streamKind = StreamKind.simpleStream(endpoint: endpoint, title: "")
        screen.hasGridViewToggle = streamKind.hasGridViewToggle
        streamViewController.streamKind = streamKind
        streamViewController.removeAllCellItems()
        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.loadInitialPage()

        trackSearch()
    }

    func trackSearch() {
        guard let text = searchText else { return }

        Tracker.shared.screenAppeared(self)

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
