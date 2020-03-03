////
///  ArtistInvitesGenerator.swift
//

final class ArtistInvitesGenerator: StreamGenerator {

    var currentUser: User?
    let streamKind: StreamKind = .artistInvites
    weak var destination: StreamDestination?

    private var localToken: String = ""
    private var loadingToken = LoadingToken()

    init(currentUser: User?, destination: StreamDestination) {
        self.currentUser = currentUser
        self.destination = destination
    }

    func load(reload: Bool = false) {
        localToken = loadingToken.resetInitialPageLoadingToken()
        if !reload {
            setPlaceHolders()
        }
        loadArtistInvitePromotionals()
        loadArtistInvites()
    }
}

private extension ArtistInvitesGenerator {

    func setPlaceHolders() {
        destination?.setPlaceholders(items: [
            StreamCellItem(type: .placeholder, placeholderType: .pageHeader),
            StreamCellItem(type: .placeholder, placeholderType: .artistInvites),
        ])
    }

    func loadArtistInvitePromotionals() {
        API().pageHeaders(kind: .artistInvites)
            .execute()
            .done { pageHeaders in
                guard let pageHeader = pageHeaders.randomItem() else { return }

                self.destination?.replacePlaceholder(
                    type: .pageHeader,
                    items: [
                        StreamCellItem(jsonable: pageHeader, type: .promotionalHeader),
                        StreamCellItem(
                            type: .spacer(height: ArtistInviteBubbleCell.Size.bubbleMargins.bottom)
                        ),
                    ]
                )
            }
            .ignoreErrors()
    }

    func loadArtistInvites() {
        StreamService().loadStream(streamKind: streamKind)
            .done { response in
                guard
                    self.loadingToken.isValidInitialPageLoadingToken(self.localToken),
                    case let .jsonables(jsonables, responseConfig) = response,
                    let artistInvites = jsonables as? [ArtistInvite]
                else { return }

                self.destination?.setPagingConfig(responseConfig: responseConfig)

                let artistInviteItems = self.parse(jsonables: artistInvites)
                self.destination?.replacePlaceholder(type: .artistInvites, items: artistInviteItems)
                {
                    self.destination?.isPagingEnabled = artistInviteItems.count > 0
                }
            }
            .catch { _ in
                self.destination?.primaryModelNotFound()
            }
    }
}
