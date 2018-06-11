////
///  ElloProviderErrors.swift
//

extension ElloProvider {

    static func generateElloError(_ data: Data, statusCode: Int?) -> NSError {
        var elloNetworkError: ElloNetworkError?
        if let dictJSONDecoded = try? JSONSerialization.jsonObject(with: data),
            let dictJSON = dictJSONDecoded as? [String: Any],
            let node = dictJSON[MappingType.errorsType.rawValue] as? [String: Any]
        {
            elloNetworkError = Mapper.mapToObject(node, type: .errorType) as? ElloNetworkError
        }

        let errorCodeType: ElloErrorCode = statusCode.map { .statusCode($0) } ?? .data
        return NSError.networkError(elloNetworkError, code: errorCodeType)
    }

    static func failedToMapObjects(_ reject: ErrorBlock) {
        let jsonMappingError = ElloNetworkError(attrs: nil, code: ElloNetworkError.CodeType.unknown, detail: "Failed to map objects", messages: nil, status: nil, title: "Failed to map objects")
        let elloError = NSError.networkError(jsonMappingError, code: .jsonMapping)
        reject(elloError)
    }
}
