////
///  EditorialsGenerator.swift
//

final class EditorialsGenerator: StreamGenerator {

    var currentUser: User?
    let streamKind: StreamKind = .editorials
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
        loadEditorialPromotionals()
        loadEditorials()
    }

    static func loadPostStreamEditorials(_ postStreamEditorials: [Editorial], afterAll: AfterBlock)
    {
        for editorial in postStreamEditorials {
            guard
                editorial.kind == .postStream,
                let path = editorial.postStreamURL
            else { continue }

            let next = afterAll()
            ElloProvider.shared.request(.custom(url: path, mimics: .categoryPosts(slug: "")))
                .done { data, responseConfig in
                    guard let posts = data as? [Post] else { return }
                    editorial.posts = posts
                }
                .ensure {
                    next()
                }
                .ignoreErrors()
        }
    }

}

private extension EditorialsGenerator {

    func setPlaceHolders() {
        destination?.setPlaceholders(items: [
            StreamCellItem(type: .placeholder, placeholderType: .pageHeader),
            StreamCellItem(type: .placeholder, placeholderType: .editorials)
        ])
    }

    func loadEditorialPromotionals() {
        API().pageHeaders(kind: .editorials)
            .execute()
            .done { pageHeaders in
                guard let pageHeader = pageHeaders.randomItem() else { return }

                self.destination?.replacePlaceholder(
                    type: .pageHeader,
                    items: [
                        StreamCellItem(jsonable: pageHeader, type: .promotionalHeader),
                        StreamCellItem(
                            type: .spacer(height: EditorialCellContent.Size.bgMargins.bottom)
                        ),
                    ]
                )
            }
            .ignoreErrors()
    }

    func loadEditorials() {
        var editorialItems: [StreamCellItem] = []
        let (afterAll, done) = afterN {
            self.destination?.replacePlaceholder(type: .editorials, items: editorialItems) {
                self.destination?.isPagingEnabled = editorialItems.count > 0
            }
        }

        let receivedEditorials = afterAll()
        StreamService().loadStream(streamKind: streamKind)
            .done { response in
                guard
                    case let .jsonables(jsonables, responseConfig) = response,
                    let editorials = jsonables as? [Editorial]
                else { return }

                self.destination?.setPagingConfig(responseConfig: responseConfig)
                editorialItems += self.parse(jsonables: editorials)

                let postStreamEditorials = editorials.filter { $0.kind == .postStream }
                EditorialsGenerator.loadPostStreamEditorials(
                    postStreamEditorials,
                    afterAll: afterAll
                )
            }
            .catch { _ in
                self.destination?.primaryModelNotFound()
            }
            .finally {
                receivedEditorials()
            }
        done()
    }
}
