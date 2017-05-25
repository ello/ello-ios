////
///  StreamService.swift
//

import Moya
import FutureKit

struct StreamLoadedNotifications {
    static let streamLoaded = TypedNotification<StreamKind>(name: "StreamLoadedNotification")
}

class StreamService {
    enum StreamResponse {
        case jsonables([JSONAble], ResponseConfig)
        case empty
    }

    init() {}

    func loadStream(streamKind: StreamKind) -> Future<StreamResponse> {
        return loadStream(endpoint: streamKind.endpoint, streamKind: streamKind)
    }

    func loadStream(endpoint: ElloAPI, streamKind: StreamKind? = nil) -> Future<StreamResponse> {
        let promise = Promise<StreamResponse>()
        ElloProvider.shared.elloRequest(
            endpoint,
            success: { (data, responseConfig) in
                if let jsonables = data as? [JSONAble] {
                    if let streamKind = streamKind {
                        Preloader().preloadImages(jsonables)
                        NewContentService().updateCreatedAt(jsonables, streamKind: streamKind)
                    }
                    promise.completeWithSuccess(.jsonables(jsonables, responseConfig))
                }
                else {
                    promise.completeWithSuccess(.empty)
                }

                // this must be the last thing, after success() or noContent() is called.
                if let streamKind = streamKind {
                    postNotification(StreamLoadedNotifications.streamLoaded, value: streamKind)
                }
            },
            failure: { (error, statusCode) in
                promise.completeWithFail(error)
            })
        return promise.future
    }

    func loadUser(_ endpoint: ElloAPI) -> Future<User> {
        let promise = Promise<User>()
        ElloProvider.shared.elloRequest(
            endpoint,
            success: { (data, responseConfig) in
                if let user = data as? User {
                    Preloader().preloadImages([user])
                    promise.completeWithSuccess(user)
                }
                else {
                    let error = NSError.uncastableJSONAble()
                    promise.completeWithFail(error)
                }
            },
            failure: { error, _ in
                promise.completeWithFail(error)
            }
        )
        return promise.future
    }

    func loadUserPosts(_ userId: String) -> Future<([Post], ResponseConfig)> {
        let promise = Promise<([Post], ResponseConfig)>()
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
                    promise.completeWithSuccess((posts, responseConfig))
                }
                else {
                    let error = NSError.uncastableJSONAble()
                    promise.completeWithFail(error)
                }
            },
            failure: { error, _ in
                promise.completeWithFail(error)
            })
        return promise.future
    }

    func loadMoreCommentsForPost(_ postId: String) -> Future<StreamResponse> {
        let promise = Promise<StreamResponse>()
        ElloProvider.shared.elloRequest(
            .postComments(postId: postId),
            success: { (data, responseConfig) in
                if let comments: [ElloComment] = data as? [ElloComment] {
                    for comment in comments {
                        comment.loadedFromPostId = postId
                    }

                    Preloader().preloadImages(comments)
                    promise.completeWithSuccess(.jsonables(comments, responseConfig))
                }
                else if (data as? String) == "" {
                    promise.completeWithSuccess(.empty)
                }
                else {
                    let error = NSError.uncastableJSONAble()
                    promise.completeWithFail(error)
                }
            },
            failure: { error, _ in
                promise.completeWithFail(error)
            }
        )
        return promise.future
    }
}
