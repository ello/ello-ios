////
///  LovesService.swift
//

import PromiseKit


struct LovesService {

    func lovePost(postId: String) -> Promise<Love> {
        let endpoint = ElloAPI.createLove(postId: postId)
        return ElloProvider.shared.request(endpoint)
            .map { (jsonable, _) -> Love in
                guard let love = jsonable as? Love else {
                    throw NSError.uncastableModel()
                }
                return love
            }
    }

    func unlovePost(postId: String) -> Promise<Void> {
        let endpoint = ElloAPI.deleteLove(postId: postId)
        return ElloProvider.shared.request(endpoint).asVoid()
    }
}
