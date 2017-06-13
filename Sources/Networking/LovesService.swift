////
///  LovesService.swift
//

import PromiseKit


struct LovesService {

    func lovePost(postId: String) -> Promise<Love> {
        let endpoint = ElloAPI.createLove(postId: postId)
        return ElloProvider.shared.request(endpoint)
            .then { response -> Love in
                guard let love = response.0 as? Love else {
                    throw NSError.uncastableJSONAble()
                }
                return love
            }
    }

    func unlovePost(postId: String) -> Promise<Void> {
        let endpoint = ElloAPI.deleteLove(postId: postId)
        return ElloProvider.shared.request(endpoint).asVoid()
    }
}
