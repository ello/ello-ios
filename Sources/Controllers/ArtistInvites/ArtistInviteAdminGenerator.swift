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

    init(artistInvite: ArtistInvite, stream: ArtistInvite.Stream, currentUser: User?, destination: StreamDestination?) {
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
            StreamCellItem(type: .placeholder, placeholderType: .streamPosts),
        ])
    }

    func loadArtistInvites() {
        StreamService().loadStream(endpoint: stream.endpoint)
            .then { response -> Void in
                guard self.loadingToken.isValidInitialPageLoadingToken(self.localToken) else { return }

                if case .empty = response {
                    self.showEmptySubmissions()
                    return
                }

                guard
                    case let .jsonables(jsonables, responseConfig) = response,
                    let submissions = jsonables as? [ArtistInviteSubmission]
                else {
                    self.destination?.primaryJSONAbleNotFound()
                    return
                }

                self.destination?.setPagingConfig(responseConfig: responseConfig)

                let artistInviteItems = self.parse(jsonables: submissions)
                self.destination?.replacePlaceholder(type: .streamPosts, items: artistInviteItems) {
                    self.destination?.isPagingEnabled = artistInviteItems.count > 0
                }
            }
            .catch { _ in
                self.destination?.primaryJSONAbleNotFound()
            }
    }

    func showEmptySubmissions() {
        let header = NSAttributedString(label: InterfaceString.ArtistInvites.AdminEmpty, style: .header)
        let headerItem = StreamCellItem(type: .header(header))
        destination?.replacePlaceholder(type: .streamPosts, items: [headerItem])
    }
}
