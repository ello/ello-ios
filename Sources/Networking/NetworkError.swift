////
///  NetworkError.swift
//

import Foundation

let ElloErrorDomain = "co.ello.Ello"

enum ElloErrorCode: Int {
    case imageMapping = 0
    case jsonMapping
    case stringMapping
    case statusCode
    case data
    case networkFailure
}

extension NSError {

    class func networkError(_ error: AnyObject?, code: ElloErrorCode) -> NSError {
        var userInfo: [AnyHashable: Any]?
        if let error: AnyObject = error {
            userInfo = [NSLocalizedFailureReasonErrorKey: error]
        }
        return NSError(domain: ElloErrorDomain, code: code.rawValue, userInfo: userInfo)
    }

}
