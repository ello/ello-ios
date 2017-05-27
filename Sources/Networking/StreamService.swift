////
///  StreamService.swift
//

import Moya
import PromiseKit


struct StreamLoadedNotifications {
    static let streamLoaded = TypedNotification<StreamKind>(name: "StreamLoadedNotification")
}

class StreamService {
    enum StreamResponse {
        case jsonables([JSONAble], ResponseConfig)
        case empty
    }

    init() {}

    func loadStream(streamKind: StreamKind) -> Promise<StreamResponse> {
        return loadStream(endpoint: streamKind.endpoint, streamKind: streamKind)
    }

    func loadStream(endpoint: ElloAPI, streamKind: StreamKind? = nil) -> Promise<StreamResponse> {
        return Promise { fulfill, reject in
            ElloProvider.shared.elloRequest(
                endpoint,
                success: { (data, responseConfig) in
                    if let jsonables = data as? [JSONAble] {
                        if let streamKind = streamKind {
                            Preloader().preloadImages(jsonables)
                            NewContentService().updateCreatedAt(jsonables, streamKind: streamKind)
                        }
                        fulfill(.jsonables(jsonables, responseConfig))
                    }
                    else {
                        fulfill(.empty)
                    }

                    // this must be the last thing, after success() or noContent() is called.
                    if let streamKind = streamKind {
                        postNotification(StreamLoadedNotifications.streamLoaded, value: streamKind)
                    }
                },
                failure: { (error, statusCode) in
                    reject(error)
                })
        }
    }

    func loadUser(_ endpoint: ElloAPI) -> Promise<User> {
        return Promise { fulfill, reject in
            ElloProvider.shared.elloRequest(
                endpoint,
                success: { (data, responseConfig) in
                    if let user = data as? User {
                        Preloader().preloadImages([user])
                        fulfill(user)
                    }
                    else {
                        let error = NSError.uncastableJSONAble()
                        reject(error)
                    }
                },
                failure: { error, _ in
                    reject(error)
                }
            )
        }
    }

    func loadUserPosts(_ userId: String) -> Promise<([Post], ResponseConfig)> {
        return Promise { fulfill, reject in
            ElloProvider.shared.elloRequest(
                ElloAPI.userStreamPosts(userId: userId),
                success: { (data, responseConfig) in
                    let posts: [Post]?
                    if data as? String == "" {
                        posts = []
                    }
                    else if let foundPosts = data as? [Post] {
                        posts = foundPosts
                    }
                    else {
                        posts = nil
                    }

                    if let posts = posts {
                        Preloader().preloadImages(posts)
                        fulfill((posts, responseConfig))
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

    func loadMoreCommentsForPost(_ postId: String) -> Promise<StreamResponse> {
        return Promise { fulfill, reject in
            ElloProvider.shared.elloRequest(
                .postComments(postId: postId),
                success: { (data, responseConfig) in
                    if let comments: [ElloComment] = data as? [ElloComment] {
                        for comment in comments {
                            comment.loadedFromPostId = postId
                        }

                        Preloader().preloadImages(comments)
                        fulfill(.jsonables(comments, responseConfig))
                    }
                    else if (data as? String) == "" {
                        fulfill(.empty)
                    }
                    else {
                        let error = NSError.uncastableJSONAble()
                        reject(error)
                    }
                },
                failure: { error, _ in
                    reject(error)
                }
            )
        }
    }
}
