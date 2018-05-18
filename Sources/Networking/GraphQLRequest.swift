////
///  GraphQLRequest.swift
//

import SwiftyJSON
import PromiseKit
import Alamofire


struct GQLVariable {
    let type: String
    let name: String
    let value: Any?

    static func string(_ name: String, _ value: String) -> GQLVariable          { return GQLVariable(type: "String!", name: name, value: value) }
    static func optionalString(_ name: String, _ value: String?) -> GQLVariable { return GQLVariable(type: "String", name: name, value: value) }
    static func id(_ name: String, _ value: String) -> GQLVariable              { return GQLVariable(type: "ID!", name: name, value: value) }
    static func optionalID(_ name: String, _ value: String?) -> GQLVariable     { return GQLVariable(type: "ID", name: name, value: value) }
    static func int(_ name: String, _ value: Int) -> GQLVariable                { return GQLVariable(type: "Int!", name: name, value: value) }
    static func optionalInt(_ name: String, _ value: Int?) -> GQLVariable       { return GQLVariable(type: "Int", name: name, value: value) }
    static func float(_ name: String, _ value: Float) -> GQLVariable            { return GQLVariable(type: "Float!", name: name, value: value) }
    static func optionalFloat(_ name: String, _ value: Float?) -> GQLVariable   { return GQLVariable(type: "Float", name: name, value: value) }
    static func bool(_ name: String, _ value: Bool) -> GQLVariable              { return GQLVariable(type: "Bool!", name: name, value: value) }
    static func optionalBool(_ name: String, _ value: Bool?) -> GQLVariable     { return GQLVariable(type: "Bool", name: name, value: value) }
    static func `enum`(_ type: String, _ name: String, _ value: Any) -> GQLVariable { return GQLVariable(type: "\(type)!", name: name, value: value) }
    static func optionalEnum(_ type: String, _ name: String, _ value: Any?) -> GQLVariable { return GQLVariable(type: type, name: name, value: value) }
}

class GraphQLRequest<T>: AuthenticationEndpoint {
    private var prevPromise: Promise<T>?
    private var prevSeal: Resolver<T>?

    var requiresAnyToken: Bool = true
    var supportsAnonymousToken: Bool = true

    var endpointName: String
    var parser: ((JSON) throws -> T)
    var variables: [GQLVariable]
    var fragments: [Fragments]
    var body: Fragments

    var manager: RequestManager

    private var url: URL { return URL(string: "\(ElloURI.baseURL)/api/v3/graphql")! }
    private var uuid: UUID!

    init(endpointName: String, parser: @escaping ((JSON) throws -> T), variables: [GQLVariable] = [], body: Fragments) {
        self.endpointName = endpointName
        self.parser = parser
        self.variables = variables
        self.fragments = body.dependencies
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
            let fragmentsQuery = fragments.map { $0.string }.joined(separator: "\n")
            query += fragmentsQuery + "\n"
        }

        if variables.count > 0 {
            query += "query(\(queryVariables()))\n"
        }

        query += "{\n\(endpointName)"
        if variables.count > 0 {
            query += "(\(endpointVariables()))"
        }
        query += "\n  {\n\(body.string)\n  }\n}"

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
