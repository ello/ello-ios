////
///  ArtistInviteAdminGenerator.swift
//

final class ArtistInviteAdminGenerator: StreamGenerator {

    var currentUser: User?
    var streamKind: StreamKind = .artistInvites
    let artistInvite: ArtistInvite
    var stream: ArtistInvite.Stream
    weak var destination: StreamDestination?

    private var localToken: String = ""
    private var loadingToken = LoadingToken()

    init(artistInvite: ArtistInvite, stream: ArtistInvite.Stream, currentUser: User?, destination: StreamDestination) {
        self.artistInvite = artistInvite
        self.stream = stream
        self.currentUser = currentUser
        self.destination = destination
    }

    func load(reload: Bool = false) {
        localToken = loadingToken.resetInitialPageLoadingToken()
        if !reload {
            setPlaceHolders()
        }

        loadArtistInvites()
    }
}

private extension ArtistInviteAdminGenerator {

    func setPlaceHolders() {
        destination?.setPlaceholders(items: [
            StreamCellItem(type: .placeholder, placeholderType: .streamItems),
        ])
    }

    func loadArtistInvites() {
        StreamService().loadStream(endpoint: stream.endpoint)
            .done { response in
                guard self.loadingToken.isValidInitialPageLoadingToken(self.localToken) else { return }

                if case .empty = response {
                    self.showEmptySubmissions()
                    return
                }

                guard
                    case let .jsonables(jsonables, responseConfig) = response,
                    let submissions = jsonables as? [ArtistInviteSubmission]
                else {
                    self.destination?.primaryModelNotFound()
                    return
                }

                self.destination?.setPagingConfig(responseConfig: responseConfig)

                let artistInviteItems = self.parse(jsonables: submissions)
                self.destination?.replacePlaceholder(type: .streamItems, items: artistInviteItems) {
                    self.destination?.isPagingEnabled = artistInviteItems.count > 0
                }
            }
            .catch { _ in
                self.destination?.primaryModelNotFound()
            }
    }

    func showEmptySubmissions() {
        let headerItem = StreamCellItem(type: .header(InterfaceString.ArtistInvites.AdminEmpty))
        destination?.replacePlaceholder(type: .streamItems, items: [headerItem])
    }
}
