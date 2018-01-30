////
///  ElloGraphQL.swift
//

import Alamofire
import Moya
import Result


enum ElloGraphQL {
    case userPostStream(username: String)

    var endpoint: String {
        switch self {
        case let .userPostStream(username): return "userPostStream(username: \(username.jsonQuoted))"
        }
    }

    var body: String {
        switch self {
        case let .userPostStream(username):
            return """
            next
            posts {
                id
                token
                assets {id}
                author {
                  id
                  username
                  name
                }
            }
            """
        }
    }
}

extension ElloGraphQL: AuthenticationEndpoint {
    var requiresAnyToken: Bool { return true }
    var supportsAnonymousToken: Bool {
        switch self {
        case .userPostStream:
            return true
        }
    }
}

class GraphQLEncoder: ParameterEncoding {
    let target: ElloGraphQL

    init(_ target: ElloGraphQL) {
        self.target = target
    }

    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()
        let body = """
            {
                \(target.endpoint) {
            \(target.body)
                }
            }
            """
        print("body:\n\(body)")
        urlRequest.httpBody = body.data(using: .utf8)
        return urlRequest
    }
}

extension ElloGraphQL: Moya.TargetType {
    var baseURL: URL { return URL(string: ElloURI.baseURL)! }
    var method: Moya.Method { return .post }
    var path: String { return "/api/v3/graphql" }
    var parameters: [String: Any]? { return nil }
    var stubbedNetworkResponse: EndpointSampleResponse { return .networkResponse(200, sampleData) }
    var sampleData: Data { return Data() }
    var multipartBody: [Moya.MultipartFormData]? { return nil }
    var parameterEncoding: Moya.ParameterEncoding { return GraphQLEncoder(self) }

    var validate: Bool { return false }
    var task: Task { return .request }

    func headers() -> [String: String] {
        var assigned: [String: String] = [
            "Accept": "application/json",
            "Accept-Language": "",
            "Content-Type": "application/graphql",
        ]

        if let info = Bundle.main.infoDictionary,
            let buildNumber = info[kCFBundleVersionKey as String] as? String
        {
            assigned["X-iOS-Build-Number"] = buildNumber
        }

        if requiresAnyToken, let authToken = AuthToken().tokenWithBearer {
            assigned += [
                "Authorization": authToken,
            ]
        }

        return assigned
    }

}
