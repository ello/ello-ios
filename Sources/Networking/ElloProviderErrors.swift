////
///  ElloProviderErrors.swift
//

import Foundation

extension ElloProvider {

    static func unCastableJSONAble(_ failure: ElloFailureCompletion) {
        let elloError = NSError.uncastableJSONAble()
        failure(elloError, 200)
    }

    static func generateElloError(_ data: Data?, statusCode: Int?) -> NSError {
        var elloNetworkError: ElloNetworkError?

        if let data = data {
            let (mappedJSON, _): (AnyObject?, NSError?) = Mapper.mapJSON(data)

            if mappedJSON != nil {
                if let node = mappedJSON?[MappingType.errorsType.rawValue] as? [String:AnyObject] {
                    elloNetworkError = Mapper.mapToObject(node as AnyObject?, type: MappingType.errorType) as? ElloNetworkError
                }
            }
        }
        else if statusCode == 401 {
            elloNetworkError = ElloNetworkError(attrs: nil, code: .unauthenticated, detail: nil, messages: nil, status: "401", title: "unauthenticated")
        }

        let errorCodeType = (statusCode == nil) ? ElloErrorCode.data : ElloErrorCode.statusCode
        let elloError = NSError.networkError(elloNetworkError, code: errorCodeType)

        return elloError
    }

    static func failedToSendRequest(_ failure: ElloFailureCompletion) {
        let elloError = NSError.networkError("Failed to send request" as AnyObject?, code: ElloErrorCode.networkFailure)
        failure(elloError, nil)
    }

    static func failedToMapObjects(_ failure: ElloFailureCompletion) {
        let jsonMappingError = ElloNetworkError(attrs: nil, code: ElloNetworkError.CodeType.unknown, detail: "NEED DEFAULT HERE", messages: nil, status: nil, title: "Unknown Error")
        let elloError = NSError.networkError(jsonMappingError, code: ElloErrorCode.jsonMapping)
        failure(elloError, nil)
    }
}
