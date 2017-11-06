////
///  ArtistInvitesGenerator.swift
//

final class ArtistInvitesGenerator: StreamGenerator {

    var currentUser: User?
    let streamKind: StreamKind = .artistInvites
    weak var destination: StreamDestination?

    private var localToken: String = ""
    private var loadingToken = LoadingToken()

    init(currentUser: User?, destination: StreamDestination?) {
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
            StreamCellItem(type: .placeholder, placeholderType: .promotionalHeader),
            StreamCellItem(type: .placeholder, placeholderType: .artistInvites),
        ])
    }

    func loadArtistInvitePromotionals() {
        PagePromotionalService().loadArtistInvitePromotionals()
            .then { promotionals -> Void in
                guard let promotionals = promotionals else { return }

                if let pagePromotional = promotionals.randomItem() {
                    self.destination?.replacePlaceholder(type: .promotionalHeader, items: [
                        StreamCellItem(jsonable: pagePromotional, type: .pagePromotionalHeader),
                        StreamCellItem(type: .spacer(height: ArtistInviteBubbleCell.Size.bubbleMargins.bottom)),
                    ])
                }
            }
            .ignoreErrors()
    }

    func loadArtistInvites() {
        StreamService().loadStream(streamKind: streamKind)
            .then { response -> Void in
                guard
                    self.loadingToken.isValidInitialPageLoadingToken(self.localToken),
                    case let .jsonables(jsonables, responseConfig) = response,
                    let artistInvites = jsonables as? [ArtistInvite]
                else { return }

                self.destination?.setPagingConfig(responseConfig: responseConfig)

                let artistInviteItems = self.parse(jsonables: artistInvites)
                self.destination?.replacePlaceholder(type: .artistInvites, items: artistInviteItems) {
                    self.destination?.isPagingEnabled = artistInviteItems.count > 0
                }
            }
            .catch { _ in
                self.destination?.primaryJSONAbleNotFound()
            }
    }
}
