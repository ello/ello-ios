////
///  RePostService.swift
//

import PromiseKit


class RePostService {
    func repost(post: Post) -> Promise<Post> {
        return ElloProvider.shared.request(.rePost(postId: post.id))
            .map { response -> Post in
                guard let repost = response.0 as? Post else {
                    throw NSError.uncastableModel()
                }
                return repost
            }
    }
}
