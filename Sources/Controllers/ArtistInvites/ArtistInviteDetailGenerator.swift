////
///  ArtistInviteDetailGenerator.swift
//

final class ArtistInviteDetailGenerator: StreamGenerator {

    var currentUser: User?
    let streamKind: StreamKind
    var artistInvite: ArtistInvite?
    var artistInviteDetails: [StreamCellItem] = []
    weak var destination: StreamDestination?

    private var localToken: String = ""
    private var loadingToken = LoadingToken()

    init(artistInviteId: String, currentUser: User?, destination: StreamDestination?) {
        self.streamKind = .artistInviteDetail(id: artistInviteId)
        self.currentUser = currentUser
        self.destination = destination
    }

    func load(reload: Bool = false) {
        localToken = loadingToken.resetInitialPageLoadingToken()
        if !reload {
            setPlaceHolders()
        }

        if !reload, let artistInvite = artistInvite {
            setArtistInvite(artistInvite)
        }
        else {
            loadArtistInvite()
        }
    }
}

private extension ArtistInviteDetailGenerator {

    func setPlaceHolders() {
        destination?.setPlaceholders(items: [
            StreamCellItem(type: .placeholder, placeholderType: .artistInvites),
            StreamCellItem(type: .placeholder, placeholderType: .artistInviteSubmissionsButton),
            StreamCellItem(type: .placeholder, placeholderType: .artistInviteDetails),
            StreamCellItem(type: .placeholder, placeholderType: .artistInviteAdmin),
            StreamCellItem(type: .placeholder, placeholderType: .artistInviteSubmissionsHeader),
            StreamCellItem(type: .placeholder, placeholderType: .streamPosts),
        ])
    }

    func loadArtistInvite() {
        StreamService().loadStream(streamKind: streamKind)
            .then { response -> Void in
                guard
                    self.loadingToken.isValidInitialPageLoadingToken(self.localToken),
                    case let .jsonables(jsonables, responseConfig) = response,
                    let artistInvites = jsonables as? [ArtistInvite],
                    let artistInvite = artistInvites.first
                else { throw NSError.uncastableJSONAble() }

                self.destination?.setPagingConfig(responseConfig: responseConfig)
                self.setArtistInvite(artistInvite)
            }
            .catch { _ in
                self.destination?.primaryJSONAbleNotFound()
            }
    }

    func setArtistInvite(_ artistInvite: ArtistInvite) {
        self.artistInvite = artistInvite
        destination?.setPrimary(jsonable: artistInvite)

        let artistInviteItems = parse(jsonables: [artistInvite])
        let headers = artistInviteItems.filter { $0.placeholderType == .artistInvites }
        self.artistInviteDetails = artistInviteItems.filter { $0.placeholderType == .artistInviteDetails }
        destination?.replacePlaceholder(type: .artistInvites, items: headers)

        let postsSpinner = StreamCellItem(type: .streamLoading, placeholderType: .streamPosts)
        destination?.replacePlaceholder(type: .artistInviteDetails, items: [postsSpinner])

        loadSubmissions(artistInvite)
    }

    func loadSubmissions(_ artistInvite: ArtistInvite) {
        guard let endpoint = artistInvite.approvedSubmissionsStream?.endpoint else {
            showSubmissionsError()
            return
        }

        StreamService().loadStream(endpoint: endpoint)
            .then { response -> Void in
                guard
                    self.loadingToken.isValidInitialPageLoadingToken(self.localToken)
                else { return }

                if case .empty = response {
                    self.showEmptySubmissions()
                    return
                }

                guard
                    case let .jsonables(jsonables, _) = response,
                    let submissions = jsonables as? [ArtistInviteSubmission]
                else { throw NSError.uncastableJSONAble() }

                let posts = submissions.flatMap { $0.post }
                if posts.count == 0 {
                    self.showEmptySubmissions()
                }
                else {
                    let header = NSAttributedString(label: InterfaceString.ArtistInvites.Submissions, style: .header)
                    let submissionsHeader = StreamCellItem(type: .header(header))
                    self.destination?.replacePlaceholder(type: .artistInviteSubmissionsHeader, items: [submissionsHeader])

                    let button = StreamCellItem(type: .artistInviteSubmissionsButton)
                    self.destination?.replacePlaceholder(type: .artistInviteSubmissionsButton, items: [button])

                    let items = self.parse(jsonables: posts)
                    self.destination?.replacePlaceholder(type: .streamPosts, items: items)
                }
            }
            .catch { _ in
                self.showSubmissionsError()
            }
            .always {
                self.loadAdminTools(artistInvite)
                self.destination?.replacePlaceholder(type: .artistInviteDetails, items: self.artistInviteDetails)
            }
    }

    func showEmptySubmissions() {
        destination?.replacePlaceholder(type: .artistInviteSubmissionsButton, items: [])
        destination?.replacePlaceholder(type: .artistInviteSubmissionsHeader, items: [])
        destination?.replacePlaceholder(type: .streamPosts, items: [])
    }

    func showSubmissionsError() {
        let error = NSAttributedString(label: InterfaceString.ArtistInvites.SubmissionsError, style: .error)
        let item = StreamCellItem(type: .header(error))
        destination?.replacePlaceholder(type: .streamPosts, items: [item])
    }

    func loadAdminTools(_ artistInvite: ArtistInvite) {
        guard
            artistInvite.hasAdminLinks
        else { return }

        let header = NSAttributedString(label: "Admin Controls", style: .header)
        let submissionsHeader = StreamCellItem(type: .header(header))
        let spacer = StreamCellItem(type: .spacer(height: 30))

        let unapprovedButton: StreamCellItem? = artistInvite.unapprovedSubmissionsStream.map { StreamCellItem(type: .revealController(label: InterfaceString.ArtistInvites.AdminUnapprovedStream, $0)) }
        let approvedButton: StreamCellItem? = artistInvite.approvedSubmissionsStream.map { StreamCellItem(type: .revealController(label: InterfaceString.ArtistInvites.AdminApprovedStream, $0)) }
        let selectedButton: StreamCellItem? = artistInvite.selectedSubmissionsStream.map { StreamCellItem(type: .revealController(label: InterfaceString.ArtistInvites.AdminSelectedStream, $0)) }
        let declinedButton: StreamCellItem? = artistInvite.declinedSubmissionsStream.map { StreamCellItem(type: .revealController(label: InterfaceString.ArtistInvites.AdminDeclinedStream, $0)) }

        let items: [StreamCellItem] = [
            submissionsHeader,
            unapprovedButton,
            approvedButton,
            selectedButton,
            declinedButton,
            spacer,
        ].flatMap { $0 }
        self.destination?.replacePlaceholder(type: .artistInviteAdmin, items: items)
    }
}
