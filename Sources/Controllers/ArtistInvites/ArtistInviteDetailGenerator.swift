////
///  ArtistInviteDetailGenerator.swift
//

final class ArtistInviteDetailGenerator: StreamGenerator {

    var currentUser: User?
    let streamKind: StreamKind
    var artistInviteId: String
    var artistInvite: ArtistInvite?
    var artistInviteDetails: [StreamCellItem] = []
    weak var destination: StreamDestination?

    private var localToken: String = ""
    private var loadingToken = LoadingToken()

    init(artistInviteId: String, currentUser: User?, destination: StreamDestination) {
        self.artistInviteId = artistInviteId
        self.streamKind = .artistInviteSubmissions
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
            StreamCellItem(type: .placeholder, placeholderType: .artistInviteSelections),
            StreamCellItem(type: .placeholder, placeholderType: .artistInviteSubmissions),
        ])
    }

    func loadArtistInvite() {
        ArtistInviteService().load(id: artistInviteId)
            .done { artistInvite in
                guard
                    self.loadingToken.isValidInitialPageLoadingToken(self.localToken)
                else { return }

                self.setArtistInvite(artistInvite)
            }
            .catch { _ in
                self.destination?.primaryModelNotFound()
            }
    }

    func setArtistInvite(_ artistInvite: ArtistInvite) {
        self.artistInvite = artistInvite
        destination?.setPrimary(jsonable: artistInvite)

        let artistInviteItems = parse(jsonables: [artistInvite])
        let headers = artistInviteItems.filter { $0.placeholderType == .artistInvites }
        self.artistInviteDetails = artistInviteItems.filter {
            $0.placeholderType == .artistInviteDetails
        }
        destination?.replacePlaceholder(type: .artistInvites, items: headers)

        let postsSpinner = StreamCellItem(type: .streamLoading, placeholderType: .streamItems)
        destination?.replacePlaceholder(type: .artistInviteDetails, items: [postsSpinner])

        loadSelections(artistInvite)
        loadSubmissions(artistInvite)
    }

    func loadSelections(_ artistInvite: ArtistInvite) {
        guard
            artistInvite.status == .closed,
            let endpoint = artistInvite.selectedSubmissionsStream?.endpoint
        else { return }

        StreamService().loadStream(endpoint: endpoint)
            .done { response in
                guard
                    self.loadingToken.isValidInitialPageLoadingToken(self.localToken),
                    case let .jsonables(jsonables, responseConfig) = response,
                    let submissions = jsonables as? [ArtistInviteSubmission]
                else { return }

                self.destination?.setPagingConfig(responseConfig: responseConfig)

                let posts = submissions.compactMap { $0.post }
                let submissionsHeader = StreamCellItem(
                    type: .header(InterfaceString.ArtistInvites.Selections)
                )
                let items = self.parse(jsonables: posts)
                self.destination?.replacePlaceholder(
                    type: .artistInviteSelections,
                    items: [submissionsHeader] + items
                )
            }
            .ignoreErrors()
    }

    func loadSubmissions(_ artistInvite: ArtistInvite) {
        guard let endpoint = artistInvite.approvedSubmissionsStream?.endpoint else {
            showSubmissionsError()
            return
        }

        StreamService().loadStream(endpoint: endpoint)
            .done { response in
                guard
                    self.loadingToken.isValidInitialPageLoadingToken(self.localToken)
                else { return }

                if case .empty = response {
                    self.showEmptySubmissions()
                    return
                }

                guard
                    case let .jsonables(jsonables, responseConfig) = response,
                    let submissions = jsonables as? [ArtistInviteSubmission]
                else { throw NSError.uncastableModel() }

                self.destination?.setPagingConfig(responseConfig: responseConfig)

                let posts = submissions.compactMap { $0.post }
                if posts.count == 0 {
                    self.showEmptySubmissions()
                }
                else {
                    let button = StreamCellItem(type: .artistInviteSubmissionsButton)
                    self.destination?.replacePlaceholder(
                        type: .artistInviteSubmissionsButton,
                        items: [button]
                    )

                    let submissionsHeader = StreamCellItem(
                        type: .header(InterfaceString.ArtistInvites.Submissions)
                    )
                    let items = self.parse(jsonables: posts)
                    self.destination?.replacePlaceholder(
                        type: .artistInviteSubmissions,
                        items: [submissionsHeader] + items
                    )

                    self.destination?.isPagingEnabled = responseConfig.nextQuery != nil
                }
            }
            .catch { _ in
                self.showSubmissionsError()
            }
            .finally {
                self.loadAdminTools(artistInvite)
                self.destination?.replacePlaceholder(
                    type: .artistInviteDetails,
                    items: self.artistInviteDetails
                )
            }
    }

    func showEmptySubmissions() {
        destination?.replacePlaceholder(type: .artistInviteSubmissionsButton, items: [])
        destination?.replacePlaceholder(type: .artistInviteSubmissions, items: [])
    }

    func showSubmissionsError() {
        let item = StreamCellItem(
            type: .error(message: InterfaceString.ArtistInvites.SubmissionsError)
        )
        destination?.replacePlaceholder(type: .streamItems, items: [item])
    }

    func loadAdminTools(_ artistInvite: ArtistInvite) {
        guard
            artistInvite.hasAdminLinks
        else { return }

        let submissionsHeader = StreamCellItem(type: .header("Admin Controls"))
        let spacer = StreamCellItem(type: .spacer(height: 30))

        let unapprovedButton: StreamCellItem? = artistInvite.unapprovedSubmissionsStream.map {
            StreamCellItem(
                type: .revealController(
                    label: InterfaceString.ArtistInvites.AdminUnapprovedStream,
                    $0
                )
            )
        }
        let approvedButton: StreamCellItem? = artistInvite.approvedSubmissionsStream.map {
            StreamCellItem(
                type: .revealController(
                    label: InterfaceString.ArtistInvites.AdminApprovedStream,
                    $0
                )
            )
        }
        let selectedButton: StreamCellItem? = artistInvite.selectedSubmissionsStream.map {
            StreamCellItem(
                type: .revealController(
                    label: InterfaceString.ArtistInvites.AdminSelectedStream,
                    $0
                )
            )
        }
        let declinedButton: StreamCellItem? = artistInvite.declinedSubmissionsStream.map {
            StreamCellItem(
                type: .revealController(
                    label: InterfaceString.ArtistInvites.AdminDeclinedStream,
                    $0
                )
            )
        }

        let items: [StreamCellItem] = [
            submissionsHeader,
            unapprovedButton,
            approvedButton,
            selectedButton,
            declinedButton,
            spacer,
        ].compactMap { $0 }
        self.destination?.replacePlaceholder(type: .artistInviteAdmin, items: items)
    }
}
