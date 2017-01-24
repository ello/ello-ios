////
///  NSErrorExtensions.swift
//

import UIKit

extension NSError {
    var elloError: ElloNetworkError? {
        return userInfo[NSLocalizedFailureReasonErrorKey] as? ElloNetworkError
    }
    var elloErrorMessage: String? {
        if let elloError = elloError {
            return elloError.title
        }
        if let reason = self.userInfo[NSLocalizedFailureReasonErrorKey] as? String {
            return reason
        }
        return nil
    }

    static func uncastableJSONAble() -> NSError {
        return NSError.networkError(nil, code: ElloErrorCode.jsonMapping)
    }

}
