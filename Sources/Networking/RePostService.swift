////
///  RePostService.swift
//

class RePostService {
    typealias RePostSuccessCompletion = (Post) -> Void

    func repost(post: Post, success: @escaping RePostSuccessCompletion, failure: @escaping ElloFailureCompletion) {
        let endpoint = ElloAPI.rePost(postId: post.id)
        ElloProvider.shared.elloRequest(endpoint,
            success: { data, responseConfig in
                if let repost = data as? Post {
                    success(repost)
                }
                else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: failure
        )
    }
}
