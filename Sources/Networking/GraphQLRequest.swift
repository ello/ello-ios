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
            }
        }
    }

    let (promise, resolve, reject) = Promise<T>.pending()

    var requiresAnyToken: Bool = true
    var supportsAnonymousToken: Bool = true

    var endpointName: String
    var parser: ((JSON) throws -> T)
    var variables: [Variable]
    var fragments: String?
    var body: String

    var manager: SessionManager = ElloManager.manager

    private var url: URL { return URL(string: "\(ElloURI.baseURL)/api/v3/graphql")! }
    private var uuid: UUID!

    init(endpointName: String, parser: @escaping ((JSON) throws -> T), variables: [Variable] = [], fragments: String? = nil, body: String) {
        self.endpointName = endpointName
        self.parser = parser
        self.variables = variables
        self.fragments = fragments
        self.body = body
    }

    func execute() -> Promise<T> {
        AuthenticationManager.shared.attemptRequest(self,
            retry: { _ = self.execute() },
            proceed: { uuid in
                self.uuid = uuid
                sendRequest()
                    .then { data, statusCode -> Promise<JSON> in
                        return self.handleResponse(data: data, statusCode: statusCode)
                    }
                    .then { json -> Void in
                        let result = try self.parseJSON(data: json)
                        self.resolve(result)
                    }
                    .catch { error in
                        self.reject(error)
                    }
            },
            cancel: {
                let elloError = NSError(domain: ElloErrorDomain, code: 401, userInfo: [NSLocalizedFailureReasonErrorKey: "Logged Out"])
                self.reject(elloError)
            })

        return self.promise
    }

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
        var query: String = ""

        if let fragments = fragments {
            query += fragments
        }

        if variables.count > 0 {
            query += "query(\(queryVariables()))"
        }

        query += "{\(endpointName)(\(endpointVariables())){\(body)}}"
        print("query:\n\(query)")

        var httpBody: [String: Any] = [
            "query": query,
        ]

        if variables.count > 0 {
            var variables: [String: Any?] = [:]
            for variable in self.variables {
                // guard let value = variable.value else { continue }
                variables[variable.name] = variable.value
            }
            httpBody["variables"] = variables
        }

        return try JSONSerialization.data(withJSONObject: httpBody, options: [])
    }

    private func sendRequest() -> Promise<(Data, Int)> {
        let (promise, resolve, reject) = Promise<(Data, Int)>.pending()

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.allHTTPHeaderFields = headers()

        do {
            urlRequest.httpBody = try httpBody()
        }
        catch {
            reject(error)
            return promise
        }

        let dataRequest = manager.request(urlRequest)
        let dataResponse = dataRequest.response { response in
            if let data = response.data, let statusCode = response.response?.statusCode {
                resolve((data, statusCode))
            }
            else if let error = response.error {
                reject(error)
            }
            else {
                delay(1) {
                    _ = self.execute()
                }
            }
        }

        dataResponse.resume()
        return promise
    }

    private func handleResponse(data: Data, statusCode: Int) -> Promise<JSON> {
        let (promise, resolve, reject) = Promise<JSON>.pending()

        switch statusCode {
        case 200...299, 300...399:
            handleSuccess(data: data, resolve: resolve, reject: reject)
        case 410:
            handleServerOutOfDate(reject: reject)
        case 401:
            handleUserUnauthenticated(data: data, statusCode: statusCode, reject: reject)
        default:
            handleServerError(data: data, statusCode: statusCode, reject: reject)
        }

        return promise
    }

    private func handleServerOutOfDate(reject: (Error) -> Void) {
        postNotification(AuthenticationNotifications.outOfDateAPI, value: ())
        let elloError = NSError(domain: ElloErrorDomain, code: 410, userInfo: [NSLocalizedFailureReasonErrorKey: "Server Out of Date"])
        self.reject(elloError)
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
        print("json:\n\(json)")
        resolve(json)
    }

    private func parseJSON(data: JSON) throws -> T {
        let result = data["data"][endpointName]
        return try parser(result)
    }
}
