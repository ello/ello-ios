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
    var isRecentlyVisible = false

    private var _mockScreen: SearchScreenProtocol?
    var screen: SearchScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return fetchScreen(_mockScreen) }
    }

    override func loadView() {
        let screen = SearchScreen()
        screen.delegate = self
        screen.showsFindFriends = currentUser != nil
        view = screen
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if isRecentlyVisible {
            isRecentlyVisible = false
            screen.activateSearchField()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let streamKind = StreamKind.simpleStream(endpoint: .searchForPosts(terms: ""), title: "")
        streamViewController.streamKind = streamKind
        screen.isGridView = streamKind.isGridView
        streamViewController.isPullToRefreshEnabled = false

        updateInsets()

        isRecentlyVisible = true
    }

    func searchForPosts(_ terms: String) {
        screen.searchFor(terms)
    }

    override func viewForStream() -> UIView {
        return screen.viewForStream()
    }

    override func showNavBars(animated: Bool) {
        super.showNavBars(animated: animated)
        positionNavBar(screen.navigationBar, visible: true, withConstraint: screen.navigationBarTopConstraint, animated: animated)
        screen.showNavBars(animated: animated)
        updateInsets()
    }

    override func hideNavBars(animated: Bool) {
        super.hideNavBars(animated: animated)
        positionNavBar(screen.navigationBar, visible: false, withConstraint: screen.navigationBarTopConstraint, animated: animated)
        screen.hideNavBars(animated: animated)
        updateInsets()
    }

    private func updateInsets() {
        updateInsets(navBar: screen.topInsetView)
    }

}

extension SearchViewController: SearchScreenDelegate {

    func searchCanceled() {
       _ = navigationController?.popViewController(animated: true)
    }

    func searchFieldCleared() {
        showNavBars(animated: false)
        searchText = ""
        streamViewController.removeAllCellItems()
        streamViewController.loadingToken.cancelInitialPage()
    }

    func searchFieldChanged(_ text: String, isPostSearch: Bool) {
        loadEndpoint(text, isPostSearch: isPostSearch)
    }

    func searchShouldReset() {
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

    private func loadEndpoint(_ text: String, isPostSearch: Bool, checkSearchText: Bool = true) {
        guard
            text.count > 2,  // just.. no (and the server doesn't guard against empty/short searches)
            !checkSearchText || searchText != text  // a search is already in progress for this text
        else { return }

        self.isPostSearch = isPostSearch
        searchText = text
        let endpoint = isPostSearch ? ElloAPI.searchForPosts(terms: text) : ElloAPI.searchForUsers(terms: text)
        let streamKind = StreamKind.simpleStream(endpoint: endpoint, title: "")
        streamViewController.streamKind = streamKind
        streamViewController.removeAllCellItems()
        streamViewController.showLoadingSpinner()
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
