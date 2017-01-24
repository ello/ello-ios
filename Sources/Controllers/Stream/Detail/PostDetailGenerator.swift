////
///  PostDetailGenerator.swift
//

final class PostDetailGenerator: StreamGenerator {

    var currentUser: User?
    var streamKind: StreamKind
    weak var destination: StreamDestination?

    fileprivate var post: Post?
    fileprivate let postParam: String
    fileprivate var localToken: String = ""
    fileprivate var loadingToken = LoadingToken()
    fileprivate var hasPaddedSocial = false
    fileprivate let queue = OperationQueue()

    init(currentUser: User?,
         postParam: String,
         post: Post?,
         streamKind: StreamKind,
         destination: StreamDestination
        ) {
        self.currentUser = currentUser
        self.post = post
        self.postParam = postParam
        self.streamKind = streamKind
        self.localToken = loadingToken.resetInitialPageLoadingToken()
        self.destination = destination
    }

    func load(reload: Bool = false) {
        let doneOperation = AsyncOperation()
        queue.addOperation(doneOperation)

        hasPaddedSocial = false
        localToken = loadingToken.resetInitialPageLoadingToken()

        if reload {
            post = nil
        }
        else {
            setPlaceHolders()
        }
        setInitialPost(doneOperation)
        loadPost(doneOperation, reload: reload)
        displayCommentBar(doneOperation)
        loadPostComments(doneOperation)
        loadPostLovers(doneOperation)
        loadPostReposters(doneOperation)
    }

}

private extension PostDetailGenerator {

    func setPlaceHolders() {
        destination?.setPlaceholders(items: [
            StreamCellItem(type: .placeholder, placeholderType: .postHeader),
            StreamCellItem(type: .placeholder, placeholderType: .postLovers),
            StreamCellItem(type: .placeholder, placeholderType: .postReposters),
            StreamCellItem(type: .placeholder, placeholderType: .postSocialPadding),
            StreamCellItem(type: .placeholder, placeholderType: .postCommentBar),
            StreamCellItem(type: .placeholder, placeholderType: .postComments)
        ])
    }

    func setInitialPost(_ doneOperation: AsyncOperation) {
        guard let post = post else { return }

        destination?.setPrimary(jsonable: post)
        if (post.content?.count)! > 0 || (post.repostContent?.count)! > 0 {
            let postItems = parse(jsonables: [post])
            destination?.replacePlaceholder(type: .postHeader, items: postItems) {}
            doneOperation.run()
        }
    }

    func loadPost(_ doneOperation: AsyncOperation, reload: Bool = false) {
        guard !doneOperation.isFinished || reload else { return }

        // load the post with no comments
        PostService().loadPost(postParam, needsComments: false)
            .onSuccess { [weak self] post in
                guard let `self` = self else { return }
                guard self.loadingToken.isValidInitialPageLoadingToken(self.localToken) else { return }
                self.post = post
                self.destination?.setPrimary(jsonable: post)
                let postItems = self.parse(jsonables: [post])
                self.destination?.replacePlaceholder(type: .postHeader, items: postItems) {}
                doneOperation.run()
            }
            .onFail { [weak self] _ in
                guard let `self` = self else { return }
                self.destination?.primaryJSONAbleNotFound()
                self.queue.cancelAllOperations()
            }
    }

    func displayCommentBar(_ doneOperation: AsyncOperation) {

        let displayCommentBarOperation = AsyncOperation()
        displayCommentBarOperation.addDependency(doneOperation)
        queue.addOperation(displayCommentBarOperation)

        displayCommentBarOperation.run { [weak self] in
            guard let `self` = self else { return }
            guard let post = self.post else { return }
            let commentingEnabled = post.author?.hasCommentingEnabled ?? true
            guard let currentUser = self.currentUser, commentingEnabled else { return }

            let barItems = [StreamCellItem(jsonable: ElloComment.newCommentForPost(post, currentUser: currentUser), type: .createComment)]
            inForeground {
                self.destination?.replacePlaceholder(type: .postCommentBar, items: barItems) {}
            }
        }
    }

    func displaySocialPadding() {
        let padding = [StreamCellItem(type: .spacer(height: 8.0))]
        destination?.replacePlaceholder(type: .postSocialPadding, items: padding) {}
    }

    func loadPostComments(_ doneOperation: AsyncOperation) {
        guard loadingToken.isValidInitialPageLoadingToken(localToken) else { return }

        let displayCommentsOperation = AsyncOperation()
        displayCommentsOperation.addDependency(doneOperation)
        queue.addOperation(displayCommentsOperation)

        PostService().loadPostComments(
            postParam,
            success: { [weak self] (comments, responseConfig) in
                guard let `self` = self else { return }
                guard self.loadingToken.isValidInitialPageLoadingToken(self.localToken) else { return }

                let commentItems = self.parse(jsonables: comments)
                displayCommentsOperation.run {
                    self.destination?.setPagingConfig(responseConfig: responseConfig)
                    inForeground {
                        self.destination?.replacePlaceholder(type: .postComments, items: commentItems) {
                            self.destination?.pagingEnabled = true
                        }
                    }
                }
            },
            failure: { _ in
                print("failed load post comments")
        })
    }

    func loadPostLovers(_ doneOperation: AsyncOperation) {
        guard loadingToken.isValidInitialPageLoadingToken(localToken) else { return }

        let displayLoversOperation = AsyncOperation()
        displayLoversOperation.addDependency(doneOperation)
        queue.addOperation(displayLoversOperation)

        PostService().loadPostLovers(
            postParam,
            success: { [weak self] (users, _) in
                guard let `self` = self else { return }
                guard self.loadingToken.isValidInitialPageLoadingToken(self.localToken) else { return }
                guard users.count > 0 else { return }

                let loversItems = self.userAvatarCellItems(
                    users,
                    icon: .heart,
                    endpoint: .postLovers(postId: self.postParam),
                    seeMoreTitle: InterfaceString.Post.LovedByList
                )
                displayLoversOperation.run {
                    inForeground {
                        self.destination?.replacePlaceholder(type: .postLovers, items: loversItems) {}
                    }
                }
            },
            failure: { _ in
                print("failed load post lovers")
        })
    }

    func loadPostReposters(_ doneOperation: AsyncOperation) {
        guard loadingToken.isValidInitialPageLoadingToken(localToken) else { return }

        let displayRepostersOperation = AsyncOperation()
        displayRepostersOperation.addDependency(doneOperation)
        queue.addOperation(displayRepostersOperation)

        PostService().loadPostReposters(
            postParam,
            success: { [weak self] (users, _) in
                guard let `self` = self else { return }
                guard self.loadingToken.isValidInitialPageLoadingToken(self.localToken) else { return }
                guard users.count > 0 else { return }

                let repostersItems = self.userAvatarCellItems(
                    users,
                    icon: .repost,
                    endpoint: .postReposters(postId: self.postParam),
                    seeMoreTitle: InterfaceString.Post.RepostedByList
                )
                displayRepostersOperation.run {
                    inForeground {
                        self.destination?.replacePlaceholder(type: .postReposters, items: repostersItems) {}
                    }
                }
            },
            failure: { _ in
                print("failed load post reposters")
        })
    }

    func userAvatarCellItems(
        _ users: [User],
        icon: InterfaceImage,
        endpoint: ElloAPI,
        seeMoreTitle: String) -> [StreamCellItem]
    {
        let model = UserAvatarCellModel(icon: icon, seeMoreTitle: seeMoreTitle)
        model.endpoint = endpoint
        model.users = users
        if !hasPaddedSocial {
            hasPaddedSocial = true
            displaySocialPadding()
        }

        return [
            StreamCellItem(type: .spacer(height: 4.0)),
            StreamCellItem(jsonable: model, type: .userAvatars)
        ]
    }
}
