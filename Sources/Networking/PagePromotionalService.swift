////
///  PagePromotionalService.swift
//

import PINRemoteImage
import FutureKit


class PagePromotionalService {

    func loadPagePromotionals() -> Future<[PagePromotional]?> {
        let promise = Promise<[PagePromotional]?>()
        ElloProvider.shared.elloRequest(.pagePromotionals,
            success: { (data, responseConfig) in
                if responseConfig.statusCode == 204 {
                    promise.completeWithSuccess(.none)
                }
                else if let pagePromotionals = data as? [PagePromotional] {
                    Preloader().preloadImages(pagePromotionals)
                    promise.completeWithSuccess(pagePromotionals)
                }
                else {
                    promise.completeWithFail(NSError.uncastableJSONAble())
                }
            }, failure: { (error, statusCode) in
                promise.completeWithFail(error)
            })
        return promise.future
    }
}
