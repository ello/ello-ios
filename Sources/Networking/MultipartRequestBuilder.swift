////
///  MultipartRequestBuilder.swift
//

import Foundation

class MultipartRequestBuilder {
    let boundaryConstant: String
    fileprivate var body: Data
    fileprivate var requestIsBuilt: Bool = false
    fileprivate var request: URLRequest

    init(url: URL, capacity: Int = 0) {
        let cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        boundaryConstant = "Boundary-7MA4YWxkTLLu0UIW" // This should be randomly-generated.

        request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "POST"

        request.setValue("multipart/form-data; boundary=\(boundaryConstant)", forHTTPHeaderField: "Content-Type")

        body = Data(capacity: capacity)
    }

    func addParam(_ name: String, value: String) {
        if requestIsBuilt {
            fatalError("Cannot add parameters after request has been built")
        }

        body.append("--\(boundaryConstant)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        body.append(value.data(using: String.Encoding.utf8)!)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
    }

    func addFile(_ name: String, filename: String, data: Data, contentType: String) {
        if requestIsBuilt {
            fatalError("Cannot add parameters after request has been built")
        }

        body.append("--\(boundaryConstant)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(contentType)\r\n".data(using: String.Encoding.utf8)!)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        body.append(data)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
    }

    func buildRequest() -> URLRequest {
        requestIsBuilt = true
        body.append("--\(boundaryConstant)--\r\n".data(using: String.Encoding.utf8)!)
        request.httpBody = body as Data

        return request
    }

}
