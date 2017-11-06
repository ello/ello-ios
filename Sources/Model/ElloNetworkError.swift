////
///  ElloNetworkError.swift
//

import SwiftyJSON

let ElloNetworkErrorVersion = 1

@objc(ElloNetworkError)
class ElloNetworkError: JSONAble {

    enum CodeType: String {
        case blacklisted = "blacklisted"
        case invalidRequest = "invalid_request"
        case invalidResource = "invalid_resource"
        case invalidVersion = "invalid_version"
        case lockedOut = "locked_out"
        case missingParam = "missing_param"
        case noEndpoint = "no_endpoint"
        case notFound = "not_found"
        case notValid = "not_valid"
        case rateLimited = "rate_limited"
        case serverError = "server_error"
        case timeout = "timeout"
        case unauthenticated = "unauthenticated"
        case unauthorized = "unauthorized"
        case unavailable = "unavailable"
        case unknown = "unknown"
    }

    let attrs: [String: [String]]?
    let code: CodeType
    let detail: String?
    let messages: [String]?
    let status: String?
    let title: String

    init(attrs: [String: [String]]?,
        code: CodeType,
        detail: String?,
        messages: [String]?,
        status: String?,
        title: String )
    {
        self.attrs = attrs
        self.code = code
        self.detail = detail
        self.messages = messages
        self.status = status
        self.title = title
        super.init(version: ElloNetworkErrorVersion)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        self.attrs = decoder.decodeOptionalKey("attrs")
        self.code = decoder.decodeKey("code")
        self.detail = decoder.decodeOptionalKey("detail")
        self.messages = decoder.decodeOptionalKey("messages")
        self.status = decoder.decodeOptionalKey("status")
        self.title = decoder.decodeKey("title")
        super.init(coder: coder)
    }

    override class func fromJSON(_ data: [String: Any]) -> JSONAble {
        let json = JSON(data)
        let title = json["title"].stringValue
        let codeType: CodeType
        if let actualCode = ElloNetworkError.CodeType(rawValue: json["code"].stringValue) {
            codeType = actualCode
        }
        else {
            codeType = .unknown
        }
        let detail = json["detail"].string
        let status = json["status"].string
        let messages = json["messages"].object as? [String]
        let attrs = json["attrs"].object as? [String: [String]]

        return ElloNetworkError(
            attrs: attrs,
            code: codeType,
            detail: detail,
            messages: messages,
            status: status,
            title: title
        )
    }
}
