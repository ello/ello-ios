////
///  GraphQLRequest.swift
//

import SwiftyJSON
import PromiseKit
import Alamofire


class GraphQLRequest<T>: AuthenticationEndpoint {
    enum Variable {
        case string(String, String)
        case optionalString(String, String?)
        case int(String, Int)
        case optionalInt(String, Int?)
        case float(String, Float)
        case optionalFloat(String, Float?)
        case bool(String, Bool)
        case optionalBool(String, Bool?)
        case `enum`(String, String, String)
        case optionalEnum(String, String?, String)

        var name: String {
            switch self {
            case let .string(name, _): return name
            case let .optionalString(name, _): return name
            case let .int(name, _): return name
            case let .optionalInt(name, _): return name
            case let .float(name, _): return name
            case let .optionalFloat(name, _): return name
            case let .bool(name, _): return name
            case let .optionalBool(name, _): return name
            case let .`enum`(name, _, _): return name
            case let .optionalEnum(name, _, _): return name
            }
        }

        var type: String {
            switch self {
            case .string: return "String!"
            case .optionalString: return "String"
            case .int: return "Int!"
            case .optionalInt: return "Int"
            case .float: return "Float!"
            case .optionalFloat: return "Float"
            case .bool: return "Bool!"
            case .optionalBool: return "Bool"
            case let .`enum`(_, _, type): return "\(type)!"
            case let .optionalEnum(_, _, type): return type
            }
        }

        var value: Any? {
            switch self {
            case let .string(_, value): return value
            case let .optionalString(_, value): return value
            case let .int(_, value): return value
            case let .optionalInt(_, value): return value
            case let .float(_, value): return value
            case let .optionalFloat(_, value): return value
            case let .bool(_, value): return value
            case let .optionalBool(_, value): return value
            case let .`enum`(_, value, _): return value
            case let .optionalEnum(_, value, _): return value
            }
        }
    }

    var prevPromise: Promise<T>?
    var prevSeal: Resolver<T>?

    var requiresAnyToken: Bool = true
    var supportsAnonymousToken: Bool = true

    var endpointName: String
    var parser: ((JSON) throws -> T)
    var variables: [Variable]
    var fragments: [Fragments]
    var body: String

    var manager: RequestManager

    private var url: URL { return URL(string: "\(ElloURI.baseURL)/api/v3/graphql")! }
    private var uuid: UUID!

    init(endpointName: String, parser: @escaping ((JSON) throws -> T), variables: [Variable] = [], fragments: [Fragments] = [], body: String) {
        self.endpointName = endpointName
        self.parser = parser
        self.variables = variables
        self.fragments = fragments
        self.body = body
        self.manager = API.sharedManager
    }

    func execute() -> Promise<T> {
        let promise: Promise<T>
        let seal: Resolver<T>
        if let prevPromise = prevPromise, let prevSeal = prevSeal {
            promise = prevPromise
            seal = prevSeal
        }
        else {
            (promise, seal) = Promise<T>.pending()
            self.prevPromise = promise
            self.prevSeal = seal
        }

        AuthenticationManager.shared.attemptRequest(self,
            retry: { _ = self.execute() },
            proceed: { uuid in
                self.uuid = uuid
                sendRequest()
                    .then { data, statusCode -> Promise<JSON> in
                        return self.handleResponse(data: data, statusCode: statusCode)
                    }
                    .done { json in
                        let result = try self.parseJSON(data: json)
                        seal.fulfill(result)
                    }
                    .catch { error in
                        seal.reject(error)
                    }
            },
            cancel: {
                let elloError = NSError(domain: ElloErrorDomain, code: 401, userInfo: [NSLocalizedFailureReasonErrorKey: "Logged Out"])
                seal.reject(elloError)
            })

        return promise
    }

    private func sendRequest() -> Promise<(Data, Int)> {
        let (promise, seal) = Promise<(Data, Int)>.pending()

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.allHTTPHeaderFields = headers()

        do {
            urlRequest.httpBody = try httpBody()

            let task = manager.request(urlRequest, sender: self) { response in
                if let data = response.data, let statusCode = response.response?.statusCode {
                    seal.fulfill((data, statusCode))
                }
                else if let error = response.error {
                    seal.reject(error)
                }
                else {
                    delay(1) {
                        _ = self.execute()
                    }
                }
            }

            task.resume()
        }
        catch {
            seal.reject(error)
        }

        return promise
    }

    private func handleResponse(data: Data, statusCode: Int) -> Promise<JSON> {
        let (promise, seal) = Promise<JSON>.pending()

        switch statusCode {
        case 200...299, 300...399:
            handleSuccess(data: data, resolve: seal.fulfill, reject: seal.reject)
        case 410:
            handleServerOutOfDate(reject: seal.reject)
        case 401:
            handleUserUnauthenticated(data: data, statusCode: statusCode, reject: seal.reject)
        default:
            handleServerError(data: data, statusCode: statusCode, reject: seal.reject)
        }

        return promise
    }

    private func handleServerOutOfDate(reject: (Error) -> Void) {
        postNotification(AuthenticationNotifications.outOfDateAPI, value: ())
        let elloError = NSError(domain: ElloErrorDomain, code: 410, userInfo: [NSLocalizedFailureReasonErrorKey: "Server Out of Date"])
        reject(elloError)
    }

    private func handleUserUnauthenticated(data: Data, statusCode: Int, reject: @escaping (Error) -> Void) {
        AuthenticationManager.shared.attemptAuthentication(
            uuid: uuid,
            request: (self, { _ = self.execute() }, { self.handleServerError(data: data, statusCode: statusCode, reject: reject) })
        )
    }

    private func handleServerError(data: Data, statusCode: Int, reject: (Error) -> Void) {
        let elloError = ElloProvider.generateElloError(data, statusCode: statusCode)
        reject(elloError)
    }

    private func handleSuccess(data: Data, resolve: (JSON) -> Void, reject: (Error) -> Void) {
        guard let json = try? JSON(data: data) else {
            ElloProvider.failedToMapObjects(reject)
            return
        }
        resolve(json)
    }

    private func parseJSON(data: JSON) throws -> T {
        let result = data["data"][endpointName]
        return try parser(result)
    }
}

extension GraphQLRequest {

    private func headers() -> [String: String] {
        var headers: [String: String] = [
            "Accept": "application/json",
            "Accept-Language": "",
            "Content-Type": "application/json",
        ]

        if let info = Bundle.main.infoDictionary,
            let buildNumber = info[kCFBundleVersionKey as String] as? String
        {
            headers["X-iOS-Build-Number"] = buildNumber
        }

        if requiresAnyToken, let authToken = AuthToken().tokenWithBearer {
            headers += [
                "Authorization": authToken,
            ]
        }

        return headers
    }

    private func queryVariables() -> String {
        return variables.map({ variable in
                return "$\(variable.name): \(variable.type)"
            }).joined(separator: ", ")
    }

    private func endpointVariables() -> String {
        return variables.map({ variable in
                return "\(variable.name): $\(variable.name)"
            }).joined(separator: ", ")
    }

    private func httpBody() throws -> Data {
        var query = ""

        if fragments.count > 0 {
            let fragmentsQuery = Fragments.flatten(fragments)
            query += fragmentsQuery + "\n"
        }

        if variables.count > 0 {
            query += "query(\(queryVariables()))\n"
        }

        query += "{\n\(endpointName)"
        if variables.count > 0 {
            query += "(\(endpointVariables()))"
        }
        query += "\n  {\n\(body)\n  }\n}"

        var httpBody: [String: Any] = [
            "query": query,
        ]

        if variables.count > 0 {
            var variables: [String: Any?] = [:]
            for variable in self.variables {
                variables[variable.name] = variable.value
            }
            httpBody["variables"] = variables
        }

        return try JSONSerialization.data(withJSONObject: httpBody, options: [])
    }

}
