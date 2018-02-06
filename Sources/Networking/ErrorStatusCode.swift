////
///  ErrorStatusCode.swift
//

enum ErrorStatusCode: Int {
    case status401 = 401
    case status403 = 403
    case status404 = 404
    case status410 = 410
    case status420 = 420
    case status422 = 422
    case status500 = 500
    case status502 = 502
    case status503 = 503
    case statusUnknown = 1_000_000

    var defaultData: Data {
        return stubbedData(String(self.rawValue))
    }
}
