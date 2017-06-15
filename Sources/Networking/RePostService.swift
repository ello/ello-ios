////
///  RePostService.swift
//

import PromiseKit


class RePostService {
    func repost(post: Post) -> Promise<Post> {
        return ElloProvider.shared.request(.rePost(postId: post.id))
            .then { response -> Post in
                guard let repost = response.0 as? Post else {
                    throw NSError.uncastableJSONAble()
                }
                return repost
            }
    }
}
