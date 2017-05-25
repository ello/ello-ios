////
///  EditorialsGenerator.swift
//

final class EditorialsGenerator: StreamGenerator {

    var currentUser: User?
    let streamKind: StreamKind = .editorials
    weak var destination: StreamDestination?

    fileprivate var posts: [Post]?
    fileprivate var localToken: String = ""
    fileprivate var loadingToken = LoadingToken()
    fileprivate let queue = OperationQueue()

    init(currentUser: User?, destination: StreamDestination?) {
        self.currentUser = currentUser
        self.destination = destination
    }

    func load(reload: Bool = false) {
        let doneOperation = AsyncOperation()
        queue.addOperation(doneOperation)

        localToken = loadingToken.resetInitialPageLoadingToken()
        if reload {
            posts = nil
        }
        else {
            setPlaceHolders()
        }
        loadEditorials()
    }

}

private extension EditorialsGenerator {

    func setPlaceHolders() {
        destination?.setPlaceholders(items: [
            StreamCellItem(type: .placeholder, placeholderType: .editorials)
        ])
    }

    func loadEditorials() {
        StreamService().loadStream(streamKind: streamKind)
            .onSuccess { [weak self] response in }
    }
}
