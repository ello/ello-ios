////
///  PostService.swift
//

import PromiseKit


struct PostService {

    func loadPost(
        _ postParam: String) -> Promise<Post>
    {
        return ElloProvider.shared.request(.postDetail(postParam: postParam))
            .map { (data, responseConfig) -> Post in
                guard let post = data as? Post else {
                    throw NSError.uncastableModel()
                }

                Preloader().preloadImages([post])
                return post
            }
    }

    func sendPostViews(
        posts: [Post] = [],
        comments: [ElloComment] = [],
        streamId: String?,
        streamKind: String,
        userId: String?)
    {
        guard posts.count + comments.count > 0 else { return }

        let postIds = Set(posts.map { $0.id } + comments.map { $0.id })
        ElloProvider.shared.request(.postViews(streamId: streamId, streamKind: streamKind, postIds: postIds, currentUserId: userId))
            .ignoreErrors()
    }

    func loadPostComments(_ postId: String) -> Promise<([ElloComment], ResponseConfig)> {
        return ElloProvider.shared.request(.postComments(postId: postId))
            .map { (data, responseConfig) -> ([ElloComment], ResponseConfig) in
                if let comments = data as? [ElloComment] {
                    Preloader().preloadImages(comments)
                    for comment in comments {
                        comment.loadedFromPostId = postId
                    }
                    return (comments, responseConfig)
                }
                else if data as? String == "" {
                    return ([], responseConfig)
                }
                else {
                    throw NSError.uncastableModel()
                }
            }
    }

    func loadPostLovers(_ postId: String) -> Promise<[User]> {
        return ElloProvider.shared.request(.postLovers(postId: postId))
            .map { (data, responseConfig) -> [User] in
                if let users = data as? [User] {
                    Preloader().preloadImages(users)
                    return users
                }
                else if data as? String == "" {
                    return []
                }
                else {
                    throw NSError.uncastableModel()
                }
            }
    }

    func loadPostReposters(_ postId: String) -> Promise<[User]> {
        return ElloProvider.shared.request(.postReposters(postId: postId))
            .map { (data, responseConfig) -> [User] in
                if let users = data as? [User] {
                    Preloader().preloadImages(users)
                    return users
                }
                else if data as? String == "" {
                    return []
                }
                else {
                    throw NSError.uncastableModel()
                }
        }
    }

    func loadRelatedPosts(_ postId: String)  -> Promise<[Post]> {
        return ElloProvider.shared.request(.postRelatedPosts(postId: postId))
            .map { (data, _) -> [Post] in
                if let posts = data as? [Post] {
                    Preloader().preloadImages(posts)
                    return posts
                }
                 else if data as? String == "" {
                    return []
                 }
                else {
                    throw NSError.uncastableModel()
                }
            }
    }

    func loadComment(_ postId: String, commentId: String) -> Promise<ElloComment> {
        return ElloProvider.shared.request(.commentDetail(postId: postId, commentId: commentId))
            .map { (data, _) -> ElloComment in
                guard let comment = data as? ElloComment else {
                    throw NSError.uncastableModel()
                }

                comment.loadedFromPostId = postId
                return comment
            }
    }

    func loadReplyAll(_ postId: String) -> Promise<[String]> {
        return ElloProvider.shared.request(.postReplyAll(postId: postId))
            .map { (usernames, _) -> [String] in
                guard let usernames = usernames as? [Username] else {
                    throw NSError.uncastableModel()
                }

                let strings = usernames
                    .map { $0.username }
                let uniq = strings.unique()
                return uniq
            }
    }

    func deletePost(_ postId: String) -> Promise<()> {
        return ElloProvider.shared.request(.deletePost(postId: postId))
            .done { _ in
                URLCache.shared.removeAllCachedResponses()
            }
    }

    func deleteComment(_ postId: String, commentId: String) -> Promise<()> {
        return ElloProvider.shared.request(.deleteComment(postId: postId, commentId: commentId))
            .asVoid()
    }

    func toggleWatchPost(_ post: Post, isWatching: Bool) -> Promise<Post> {
        let api: ElloAPI
        if isWatching {
            api = ElloAPI.createWatchPost(postId: post.id)
        }
        else {
            api = ElloAPI.deleteWatchPost(postId: post.id)
        }

        return ElloProvider.shared.request(api)
            .map { data, _ -> Post in
                if isWatching,
                    let watch = data as? Watch,
                    let post = watch.post
                {
                    return post
                }
                else if !isWatching {
                    post.isWatching = false
                    ElloLinkedStore.shared.setObject(post, forKey: post.id, type: .postsType)
                    return post
                }
                else {
                    throw NSError.uncastableModel()
                }
            }
    }
}
