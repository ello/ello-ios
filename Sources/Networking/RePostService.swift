////
///  RePostService.swift
//

import PromiseKit


class RePostService {
    func repost(post: Post) -> Promise<Post> {
        return ElloProvider.shared.request(.rePost(postId: post.id))
            .map { (jsonable, _) -> Post in
                guard let repost = jsonable as? Post else {
                    throw NSError.uncastableModel()
                }
                return repost
            }
    }
}
