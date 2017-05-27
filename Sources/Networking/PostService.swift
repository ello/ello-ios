////
///  PostService.swift
//

import PromiseKit


struct PostService {

    func loadPost(
        _ postParam: String,
        needsComments: Bool) -> Promise<Post>
    {
        let commentCount = needsComments ? 10 : 0
        return ElloProvider.shared.request(.postDetail(postParam: postParam, commentCount: commentCount))
            .then { data, responseConfig -> Post in
                guard let post = data as? Post else {
                    throw NSError.uncastableJSONAble()
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
        ElloProvider.shared.elloRequest(
            ElloAPI.postViews(streamId: streamId, streamKind: streamKind, postIds: postIds, currentUserId: userId),
            success: { _ in })
    }

    func loadPostComments(_ postId: String) -> Promise<([ElloComment], ResponseConfig)> {
        return ElloProvider.shared.request(.postComments(postId: postId))
            .then { (data, responseConfig) -> ([ElloComment], ResponseConfig) in
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
                    throw NSError.uncastableJSONAble()
                }
            }
    }

    func loadPostLovers(_ postId: String) -> Promise<[User]> {
        return ElloProvider.shared.request(.postLovers(postId: postId))
            .then { (data, responseConfig) -> [User] in
                if let users = data as? [User] {
                    Preloader().preloadImages(users)
                    return users
                }
                else if data as? String == "" {
                    return []
                }
                else {
                    throw NSError.uncastableJSONAble()
                }
            }
    }

    func loadPostReposters(_ postId: String) -> Promise<[User]> {
        return ElloProvider.shared.request(.postReposters(postId: postId))
            .then { (data, responseConfig) -> [User] in
                if let users = data as? [User] {
                    Preloader().preloadImages(users)
                    return users
                }
                else if data as? String == "" {
                    return []
                }
                else {
                    throw NSError.uncastableJSONAble()
                }
        }
    }

    func loadRelatedPosts(_ postId: String)  -> Promise<[Post]> {
        return ElloProvider.shared.request(.postRelatedPosts(postId: postId))
            .then { (data, _) -> [Post] in
                if let posts = data as? [Post] {
                    Preloader().preloadImages(posts)
                    return posts
                }
                 else if data as? String == "" {
                    return []
                 }
                else {
                    throw NSError.uncastableJSONAble()
                }
            }
    }

    func loadComment(_ postId: String, commentId: String) -> Promise<ElloComment> {
        return ElloProvider.shared.request(.commentDetail(postId: postId, commentId: commentId))
            .then { (data, _) -> ElloComment in
                guard let comment = data as? ElloComment else {
                    throw NSError.uncastableJSONAble()
                }

                comment.loadedFromPostId = postId
                return comment
            }
    }

    func loadReplyAll(_ postId: String) -> Promise<[String]> {
        return ElloProvider.shared.request(.postReplyAll(postId: postId))
            .then { (usernames, _) -> [String] in
                guard let usernames = usernames as? [Username] else {
                    throw NSError.uncastableJSONAble()
                }

                let strings = usernames
                    .map { $0.username }
                let uniq = strings.unique()
                return uniq
            }
    }

    func deletePost(_ postId: String) -> Promise<()> {
        return ElloProvider.shared.request(.deletePost(postId: postId))
            .thenFinally { _ in
                URLCache.shared.removeAllCachedResponses()
            }
    }

    func deleteComment(_ postId: String, commentId: String) -> Promise<()> {
        return ElloProvider.shared.request(.deleteComment(postId: postId, commentId: commentId))
            .thenFinally { _ in }
    }

    func toggleWatchPost(_ post: Post, watching: Bool) -> Promise<Post> {
        let api: ElloAPI
        if watching {
            api = ElloAPI.createWatchPost(postId: post.id)
        }
        else {
            api = ElloAPI.deleteWatchPost(postId: post.id)
        }

        return ElloProvider.shared.request(api)
            .then { data, _ -> Post in
                if watching,
                    let watch = data as? Watch,
                    let post = watch.post
                {
                    return post
                }
                else if !watching {
                    post.watching = false
                    ElloLinkedStore.sharedInstance.setObject(post, forKey: post.id, type: .postsType)
                    return post
                }
                else {
                    throw NSError.uncastableJSONAble()
                }
            }
    }
}
