////
///  LovesService.swift
//

import Foundation

typealias LovesCreateSuccessCompletion = (_ love: Love, _ responseConfig: ResponseConfig) -> Void

struct LovesService {

    init(){}

    func lovePost(
        postId: String,
        success: @escaping LovesCreateSuccessCompletion,
        failure: @escaping ElloFailureCompletion)
    {
        let endpoint = ElloAPI.createLove(postId: postId)
        ElloProvider.shared.elloRequest(endpoint,
            success: { (data, responseConfig) in
                if let love = data as? Love {
                    success(love, responseConfig)
                }
                else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: failure
        )
    }

    func unlovePost(
        postId: String,
        success: @escaping ElloEmptyCompletion,
        failure: @escaping ElloFailureCompletion)
    {
        let endpoint = ElloAPI.deleteLove(postId: postId)
        ElloProvider.shared.elloRequest(endpoint,
            success: { _, _ in
                success()
            },
            failure: failure
        )
    }
}
