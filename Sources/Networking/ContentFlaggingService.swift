////
///  ContentFlaggingService.swift
//

import Moya
import SwiftyJSON

typealias ContentFlaggingSuccessCompletion = () -> Void

struct ContentFlaggingService {

    init(){}

    func flagContent(_ endpoint: ElloAPI, success: @escaping ContentFlaggingSuccessCompletion, failure: @escaping ElloFailureCompletion) {
        ElloProvider.shared.elloRequest(endpoint,
            success: { data in
                success()
        }, failure: failure)
    }
}
