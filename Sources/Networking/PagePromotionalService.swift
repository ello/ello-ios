////
///  PagePromotionalService.swift
//

import PINRemoteImage
import PromiseKit


class PagePromotionalService {

    func loadPagePromotionals() -> Promise<[PagePromotional]?> {
        return Promise { fulfill, reject in
            ElloProvider.shared.elloRequest(.pagePromotionals,
                success: { (data, responseConfig) in
                    if responseConfig.statusCode == 204 {
                        fulfill(.none)
                    }
                    else if let pagePromotionals = data as? [PagePromotional] {
                        Preloader().preloadImages(pagePromotionals)
                        fulfill(pagePromotionals)
                    }
                    else {
                        reject(NSError.uncastableJSONAble())
                    }
                }, failure: { (error, statusCode) in
                    reject(error)
                })
        }
    }
}
