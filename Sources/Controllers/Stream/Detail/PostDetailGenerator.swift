////
///  PostDetailGenerator.swift
//


protocol PostDetailStreamDestination: StreamDestination {
    func appendComments(_: [StreamCellItem])
}


final class PostDetailGenerator: StreamGenerator {
    var currentUser: User?
    var streamKind: StreamKind
    weak private var postDetailStreamDestination: PostDetailStreamDestination?
    weak var destination: StreamDestination? {
        get { return postDetailStreamDestination }
        set {
            if !(newValue is PostDetailStreamDestination) { fatalError("CategoryGenerator.destination must conform to PostDetailStreamDestination") }
            postDetailStreamDestination = newValue as? PostDetailStreamDestination
        }
    }

    private var post: Post?
    private let postParam: String
    private var localToken: String = ""
    private var loadingToken = LoadingToken()
    private let queue = OperationQueue()

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
        self.destination = destination
    }

    func load(reload: Bool = false) {
        let doneOperation = AsyncOperation()
        queue.addOperation(doneOperation)

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
        loadRelatedPosts(doneOperation)
    }

    func loadMoreComments(nextQuery: URLComponents) {
        guard let postId = self.post?.id else { return }

        let loadingComments = [StreamCellItem(type: .streamLoading)]
        self.destination?.replacePlaceholder(type: .postLoadingComments, items: loadingComments)

        let scrollAPI = ElloAPI.infiniteScroll(query: nextQuery, api: .postComments(postId: postId))
        StreamService().loadStream(endpoint: scrollAPI, streamKind: .postDetail(postParam: postId))
            .then { response -> Void in
                switch response {
                case let .jsonables(jsonables, responseConfig):
                    self.destination?.setPagingConfig(responseConfig: responseConfig)

                    let commentItems = self.parse(jsonables: jsonables)
                    self.postDetailStreamDestination?.appendComments(commentItems)

                    let loadMoreComments = self.loadMoreCommentItems(lastComment: jsonables.last as? ElloComment, responseConfig: responseConfig)
                    self.destination?.replacePlaceholder(type: .postLoadingComments, items: loadMoreComments)
                case .empty:
                    self.destination?.replacePlaceholder(type: .postLoadingComments, items: [])
                }
            }
            .catch { _ in
                self.destination?.replacePlaceholder(type: .postLoadingComments, items: [])
            }
    }
}

extension PostDetailGenerator {

    static func socialPadding() -> [StreamCellItem] {
        return [StreamCellItem(type: .spacer(height: 8.0))]
    }

    static func userAvatarCellItems(
        users: [User],
        postParam: String,
        type: UserAvatarCellModel.EndpointType) -> [StreamCellItem]
    {
        let model = UserAvatarCellModel(
            type: type,
            users: users,
            postParam: postParam
            )

        return [
            StreamCellItem(type: .spacer(height: 4.0)),
            StreamCellItem(jsonable: model, type: .userAvatars)
        ]
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
            StreamCellItem(type: .placeholder, placeholderType: .postComments),
            StreamCellItem(type: .placeholder, placeholderType: .postLoadingComments),
            StreamCellItem(type: .placeholder, placeholderType: .postRelatedPosts),
        ])
    }

    func setInitialPost(_ doneOperation: AsyncOperation) {
        guard let post = post else { return }

        destination?.setPrimary(jsonable: post)
        if (post.content?.count)! > 0 || (post.repostContent?.count)! > 0 {
            let postItems = parse(jsonables: [post])
            destination?.replacePlaceholder(type: .postHeader, items: postItems)
            doneOperation.run()
        }
    }

    func loadPost(_ doneOperation: AsyncOperation, reload: Bool = false) {
        guard !doneOperation.isFinished || reload else { return }

        // load the post with no comments
        PostService().loadPost(postParam)
            .then { post -> Void in
                guard self.loadingToken.isValidInitialPageLoadingToken(self.localToken) else { return }
                self.post = post
                self.destination?.setPrimary(jsonable: post)
                let postItems = self.parse(jsonables: [post])
                self.destination?.replacePlaceholder(type: .postHeader, items: postItems)
                doneOperation.run()
            }
            .catch { _ in
                self.destination?.primaryJSONAbleNotFound()
                self.queue.cancelAllOperations()
            }
    }

    func displayCommentBar(_ doneOperation: AsyncOperation) {
        let displayCommentBarOperation = AsyncOperation()
        displayCommentBarOperation.addDependency(doneOperation)
        queue.addOperation(displayCommentBarOperation)

        displayCommentBarOperation.run {
            guard let post = self.post else { return }
            let commentingEnabled = post.author?.hasCommentingEnabled ?? true
            guard let currentUser = self.currentUser, commentingEnabled else { return }

            let barItems = [StreamCellItem(jsonable: ElloComment.newCommentForPost(post, currentUser: currentUser), type: .createComment)]
            inForeground {
                self.destination?.replacePlaceholder(type: .postCommentBar, items: barItems)
            }
        }
    }

    func displaySocialPadding() {
        let padding = PostDetailGenerator.socialPadding()
        destination?.replacePlaceholder(type: .postSocialPadding, items: padding)
    }

    func loadMoreCommentItems(lastComment: ElloComment?, responseConfig: ResponseConfig) -> [StreamCellItem] {
        if responseConfig.nextQuery != nil,
            let lastComment = lastComment
        {
            return [StreamCellItem(jsonable: lastComment, type: .loadMoreComments)]
        }
        else {
            return []
        }
    }

    func loadPostComments(_ doneOperation: AsyncOperation) {
        guard loadingToken.isValidInitialPageLoadingToken(localToken) else { return }

        let displayCommentsOperation = AsyncOperation()
        displayCommentsOperation.addDependency(doneOperation)
        queue.addOperation(displayCommentsOperation)

        PostService().loadPostComments(postParam)
            .then { comments, responseConfig -> Void in
                guard self.loadingToken.isValidInitialPageLoadingToken(self.localToken) else { return }

                let commentItems = self.parse(jsonables: comments)
                displayCommentsOperation.run {
                    self.destination?.setPagingConfig(responseConfig: responseConfig)
                    inForeground {
                        self.destination?.replacePlaceholder(type: .postComments, items: commentItems)
                        if let lastComment = comments.last {
                            let loadMoreComments = self.loadMoreCommentItems(lastComment: lastComment, responseConfig: responseConfig)
                            self.destination?.replacePlaceholder(type: .postLoadingComments, items: loadMoreComments)
                        }
                    }
                }
            }
            .ignoreErrors()
    }

    func loadPostLovers(_ doneOperation: AsyncOperation) {
        guard loadingToken.isValidInitialPageLoadingToken(localToken) else { return }

        let displayLoversOperation = AsyncOperation()
        displayLoversOperation.addDependency(doneOperation)
        queue.addOperation(displayLoversOperation)

        PostService().loadPostLovers(postParam)
            .then { users -> Void in
                guard self.loadingToken.isValidInitialPageLoadingToken(self.localToken) else { return }
                guard users.count > 0 else { return }

                let loversItems = PostDetailGenerator.userAvatarCellItems(
                    users: users,
                    postParam: self.postParam,
                    type: .lovers
                )
                displayLoversOperation.run {
                    inForeground {
                        self.displaySocialPadding()
                        self.destination?.replacePlaceholder(type: .postLovers, items: loversItems)
                    }
                }
            }
            .ignoreErrors()
    }

    func loadPostReposters(_ doneOperation: AsyncOperation) {
        guard loadingToken.isValidInitialPageLoadingToken(localToken) else { return }

        let displayRepostersOperation = AsyncOperation()
        displayRepostersOperation.addDependency(doneOperation)
        queue.addOperation(displayRepostersOperation)

        PostService().loadPostReposters(postParam)
            .then { users -> Void in
                guard self.loadingToken.isValidInitialPageLoadingToken(self.localToken) else { return }
                guard users.count > 0 else { return }

                let repostersItems = PostDetailGenerator.userAvatarCellItems(
                    users: users,
                    postParam: self.postParam,
                    type: .reposters
                )
                displayRepostersOperation.run {
                    inForeground {
                        self.displaySocialPadding()
                        self.destination?.replacePlaceholder(type: .postReposters, items: repostersItems)
                    }
                }
            }
            .ignoreErrors()
    }

    func loadRelatedPosts(_ doneOperation: AsyncOperation) {
        guard loadingToken.isValidInitialPageLoadingToken(localToken) else { return }

        let displayRelatedPostsOperation = AsyncOperation()
        displayRelatedPostsOperation.addDependency(doneOperation)
        queue.addOperation(displayRelatedPostsOperation)

        PostService().loadRelatedPosts(postParam)
            .then { relatedPosts -> Void in
                guard self.loadingToken.isValidInitialPageLoadingToken(self.localToken) else { return }
                guard relatedPosts.count > 0 else { return }

                let header = NSAttributedString(label: InterfaceString.Post.RelatedPosts, style: .largeGrayHeader)
                let headerCellItem = StreamCellItem(type: .tallHeader(header))
                let postItems = self.parse(jsonables: relatedPosts, forceGrid: true)
                let relatedPostItems = [headerCellItem] + postItems

                displayRelatedPostsOperation.run {
                    inForeground {
                        self.destination?.replacePlaceholder(type: .postRelatedPosts, items: relatedPostItems)
                    }
                }
            }
            .ignoreErrors()
    }
}
