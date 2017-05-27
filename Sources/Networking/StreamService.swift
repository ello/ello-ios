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
        return ElloProvider.shared.request(endpoint)
            .then { (data, responseConfig) -> StreamResponse in
                if let streamKind = streamKind {
                    nextTick {
                        postNotification(StreamLoadedNotifications.streamLoaded, value: streamKind)
                    }
                }

                if data as? String == "" {
                    return .empty
                }
                else if let jsonables = data as? [JSONAble] {
                    if let streamKind = streamKind {
                        Preloader().preloadImages(jsonables)
                        NewContentService().updateCreatedAt(jsonables, streamKind: streamKind)
                    }
                    return .jsonables(jsonables, responseConfig)
                }
                else {
                    throw NSError.uncastableJSONAble()
                }
            }
    }

    func loadUser(_ endpoint: ElloAPI) -> Promise<User> {
        return ElloProvider.shared.request(endpoint)
            .then { data, responseConfig -> User in
                guard let user = data as? User else {
                    throw NSError.uncastableJSONAble()
                }
                Preloader().preloadImages([user])
                return user
            }
    }

    func loadUserPosts(_ userId: String) -> Promise<([Post], ResponseConfig)> {
        return ElloProvider.shared.request(.userStreamPosts(userId: userId))
            .then { data, responseConfig -> ([Post], ResponseConfig) in
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
                    return (posts, responseConfig)
                }
                else {
                    throw NSError.uncastableJSONAble()
                }
            }
    }

    func loadMoreCommentsForPost(_ postId: String) -> Promise<StreamResponse> {
        return ElloProvider.shared.request(.postComments(postId: postId))
            .then { data, responseConfig -> StreamResponse in
                if let comments: [ElloComment] = data as? [ElloComment] {
                    for comment in comments {
                        comment.loadedFromPostId = postId
                    }

                    Preloader().preloadImages(comments)
                    return .jsonables(comments, responseConfig)
                }
                else if (data as? String) == "" {
                    return .empty
                }
                else {
                    throw NSError.uncastableJSONAble()
                }
            }
    }
}
