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
        return Promise { fulfill, reject in
            ElloProvider.shared.elloRequest(
                ElloAPI.postDetail(postParam: postParam, commentCount: commentCount),
                success: { (data, responseConfig) in
                    if let post = data as? Post {
                        Preloader().preloadImages([post])
                        fulfill(post)
                    }
                    else {
                        let error = NSError.uncastableJSONAble()
                        reject(error)
                    }
                },
                failure: { (error, _) in
                    reject(error)
                })
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
        return Promise { fulfill, reject in
            ElloProvider.shared.elloRequest(
                ElloAPI.postComments(postId: postId),
                success: { (data, responseConfig) in
                    if let comments = data as? [ElloComment] {
                        Preloader().preloadImages(comments)
                        for comment in comments {
                            comment.loadedFromPostId = postId
                        }
                        fulfill((comments, responseConfig))
                    }
                    else if data as? String == "" {
                        fulfill(([], responseConfig))
                    }
                    else {
                        let error = NSError.uncastableJSONAble()
                        reject(error)
                    }
                },
                failure: { (error, statusCode) in
                    reject(error)
                })
        }
    }

    func loadPostLovers(_ postId: String) -> Promise<[User]> {
        return Promise { fulfill, reject in
            ElloProvider.shared.elloRequest(
                ElloAPI.postLovers(postId: postId),
                success: { (data, responseConfig) in
                    if let users = data as? [User] {
                        Preloader().preloadImages(users)
                        fulfill(users)
                    }
                    else if data as? String == "" {
                        fulfill([])
                    }
                    else {
                        let error = NSError.uncastableJSONAble()
                        reject(error)
                    }
                },
                failure: { (error, statusCode) in
                    reject(error)
                })
        }
    }

    func loadPostReposters(_ postId: String) -> Promise<[User]> {
        return Promise { fulfill, reject in
            ElloProvider.shared.elloRequest(
                ElloAPI.postReposters(postId: postId),
                success: { (data, responseConfig) in
                    if let users = data as? [User] {
                        Preloader().preloadImages(users)
                        fulfill(users)
                    }
                    else if data as? String == "" {
                        fulfill([])
                    }
                    else {
                        let error = NSError.uncastableJSONAble()
                        reject(error)
                    }
                },
                failure: { (error, statusCode) in
                    reject(error)
                })
        }
    }

    func loadRelatedPosts(_ postId: String)  -> Promise<[Post]> {
        return Promise { fulfill, reject in
            ElloProvider.shared.elloRequest(
                ElloAPI.postRelatedPosts(postId: postId),
                success: { (data, _) in
                    if let posts = data as? [Post] {
                        Preloader().preloadImages(posts)
                        fulfill(posts)
                    }
                     else if data as? String == "" {
                         fulfill([])
                     }
                    else {
                        let error = NSError.uncastableJSONAble()
                        reject(error)
                    }
                },
                failure: { (error, statusCode) in
                    reject(error)
                })
        }
    }

    func loadComment(_ postId: String, commentId: String) -> Promise<ElloComment> {
        return Promise { fulfill, reject in
            ElloProvider.shared.elloRequest(
                ElloAPI.commentDetail(postId: postId, commentId: commentId),
                success: { (data, responseConfig) in
                    if let comment = data as? ElloComment {
                        comment.loadedFromPostId = postId
                        fulfill(comment)
                    }
                    else {
                        let error = NSError.uncastableJSONAble()
                        reject(error)
                    }
                },
                failure: { (error, statusCode) in
                    reject(error)
                })
        }
    }

    func loadReplyAll(_ postId: String) -> Promise<[String]> {
        return Promise { fulfill, reject in
            ElloProvider.shared.elloRequest(
                ElloAPI.postReplyAll(postId: postId),
                success: { (usernames, _) in
                    if let usernames = usernames as? [Username] {
                        let strings = usernames
                            .map { $0.username }
                        let uniq = strings.unique()
                        fulfill(uniq)
                    }
                    else {
                        let error = NSError.uncastableJSONAble()
                        reject(error)
                    }
                }, failure: { (error, _) in
                    reject(error)
                })
        }
    }

    func deletePost(_ postId: String) -> Promise<()> {
            return Promise { fulfill, reject in
            ElloProvider.shared.elloRequest(ElloAPI.deletePost(postId: postId),
                success: { (_, _) in
                    URLCache.shared.removeAllCachedResponses()
                    fulfill(())
                }, failure: { (error, _) in
                    reject(error)
                }
            )
        }
    }

    func deleteComment(_ postId: String, commentId: String) -> Promise<()> {
            return Promise { fulfill, reject in
            ElloProvider.shared.elloRequest(ElloAPI.deleteComment(postId: postId, commentId: commentId),
                success: { (_, _) in
                    fulfill(())
                }, failure: { (error, _) in
                    reject(error)
                }
            )
        }
    }

    func toggleWatchPost(_ post: Post, watching: Bool) -> Promise<Post> {
        let api: ElloAPI
        if watching {
            api = ElloAPI.createWatchPost(postId: post.id)
        }
        else {
            api = ElloAPI.deleteWatchPost(postId: post.id)
        }

        return Promise { fulfill, reject in
            ElloProvider.shared.elloRequest(api,
                success: { data, _ in
                    if watching,
                        let watch = data as? Watch,
                        let post = watch.post
                    {
                        fulfill(post)
                    }
                    else if !watching {
                        post.watching = false
                        ElloLinkedStore.sharedInstance.setObject(post, forKey: post.id, type: .postsType)
                        fulfill(post)
                    }
                    else {
                        let error = NSError.uncastableJSONAble()
                        reject(error)
                    }
                },
                failure: { error, _ in
                    reject(error)
                })
        }
    }
}
