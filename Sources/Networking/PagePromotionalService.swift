////
///  PagePromotionalService.swift
//

import PINRemoteImage
import PromiseKit


class PagePromotionalService {

    func loadPagePromotionals() -> Promise<[PagePromotional]?> {
        return ElloProvider.shared.request(.pagePromotionals)
            .then { data, responseConfig -> [PagePromotional]? in
                if responseConfig.statusCode == 204 {
                    return nil
                }
                else if let pagePromotionals = data as? [PagePromotional] {
                    Preloader().preloadImages(pagePromotionals)
                    return pagePromotionals
                }
                else {
                    throw NSError.uncastableJSONAble()
                }
            }
    }
}
