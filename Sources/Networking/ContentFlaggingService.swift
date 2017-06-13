////
///  ContentFlaggingService.swift
//

import Moya
import SwiftyJSON
import PromiseKit


struct ContentFlaggingService {

    func flagContent(_ endpoint: ElloAPI) -> Promise<Void> {
        return ElloProvider.shared.request(endpoint).asVoid()
    }

}
