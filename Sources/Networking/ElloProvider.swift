////
///  ElloProvider.swift
//

import Moya
import Result
import Alamofire
import PromiseKit
import WebLinking


class ElloProvider {
    typealias Response = (Any, ResponseConfig)
    typealias RequestFuture = (target: ElloAPI, resolve: (Response) -> Void, reject: ErrorBlock)

    static let shared = ElloProvider()

    static func endpointClosure(_ target: ElloAPI) -> Endpoint<ElloAPI> {
        let url = target.baseURL.appendingPathComponent(target.path).absoluteString
        return Endpoint<ElloAPI>(url: url, sampleResponseClosure: { return target.stubbedNetworkResponse }, method: target.method, task: target.task, httpHeaderFields: target.headers)
    }

    static func DefaultProvider() -> MoyaProvider<ElloAPI> {
        return MoyaProvider<ElloAPI>(endpointClosure: ElloProvider.endpointClosure, manager: ElloManager.alamofireManager)
    }

    static var defaultProvider: MoyaProvider<ElloAPI> = ElloProvider.DefaultProvider()
    static var oneTimeProvider: MoyaProvider<ElloAPI>?
    static var moya: MoyaProvider<ElloAPI> {
        get {
            if let provider = oneTimeProvider {
                oneTimeProvider = nil
                return provider
            }
            return defaultProvider
        }

        set {
            defaultProvider = newValue
        }
    }

    func request(_ target: ElloAPI) -> Promise<Response> {
        let (promise, seal) = Promise<Response>.pending()
        sendRequest((target, resolve: seal.fulfill, reject: seal.reject))
        return promise
    }

    private func sendRequest(_ request: RequestFuture) {
        AuthenticationManager.shared.attemptRequest(request.target,
            retry: { self.sendRequest(request) },
            proceed: { uuid in
                ElloProvider.moya.request(request.target) { result in
                    self.handleRequest(request: request, result: result, uuid: uuid)
                }
            },
            cancel: {
                self.requestFailed(request: request)
            })
    }

    private func requestFailed(request: RequestFuture) {
        let elloError = NSError(domain: ElloErrorDomain, code: 401, userInfo: [NSLocalizedFailureReasonErrorKey: "Logged Out"])
        inForeground {
            request.reject(elloError)
        }
    }

}

extension ElloProvider {

    private func handleRequest(request: RequestFuture, result: MoyaResult, uuid: UUID) {
        switch result {
        case let .success(moyaResponse):
            switch moyaResponse.statusCode {
            case 200...299, 300...399:
                handleNetworkSuccess(request: request, response: moyaResponse)
            case 410:
                postOldAPINotification()
            case 401:
                AuthenticationManager.shared.attemptAuthentication(
                    uuid: uuid,
                    request: (request.target, { self.sendRequest(request) }, { self.handleServerError(request: request, response: moyaResponse) }))
            default:
                handleServerError(request: request, response: moyaResponse)
            }
        case .failure:
            handleNetworkFailure(request: request)
        }
    }

    private func handleNetworkSuccess(request: RequestFuture, response moyaResponse: Moya.Response) {
        let response = moyaResponse.response
        let data = moyaResponse.data
        let statusCode = moyaResponse.statusCode

        let mappedJSON = try? JSONSerialization.jsonObject(with: data)
        let responseConfig = parseResponseConfig(response)
        if let dict = mappedJSON as? [String: Any] {
            parseLinked(request: request, dict: dict, responseConfig: responseConfig)
        }
        else if isEmptySuccess(data, statusCode: statusCode) {
            request.resolve(("", responseConfig))
        }
        else {
            ElloProvider.failedToMapObjects(request.reject)
        }
    }

    private func parseLinked(request: RequestFuture, dict: [String: Any], responseConfig: ResponseConfig) {
        let completion: Block = {
            let elloAPI = request.target
            let node = dict[elloAPI.mappingType.rawValue]
            var newResponseConfig: ResponseConfig?
            if let pagingPath = elloAPI.pagingPath,
                let links = (node as? [String: Any])?["links"] as? [String: Any],
                let pagingPathNode = links[pagingPath] as? [String: Any],
                let pagination = pagingPathNode["pagination"] as? [String: String]
            {
                newResponseConfig = self.parsePagination(pagination)
            }

            guard elloAPI.mappingType != .noContentType else {
                request.resolve((Void(), newResponseConfig ?? responseConfig))
                return
            }

            let mappedObjects: Any?
            if let node = node as? [[String: Any]] {
                mappedObjects = Mapper.mapToObjectArray(node, type: elloAPI.mappingType)
            }
            else if let node = node as? [String: Any] {
                mappedObjects = Mapper.mapToObject(node, type: elloAPI.mappingType)
            }
            else {
                mappedObjects = nil
            }

            if let mappedObjects = mappedObjects {
                request.resolve((mappedObjects, newResponseConfig ?? responseConfig))
            }
            else {
                ElloProvider.failedToMapObjects(request.reject)
            }
        }

        if let linked = dict["linked"] as? [String: [[String: Any]]] {
            ElloLinkedStore.shared.parseLinked(linked, completion: completion)
        }
        else {
            completion()
        }
    }

    private func parsePagination(_ node: [String: String]) -> ResponseConfig {
        let config = ResponseConfig()
        config.totalPages = node["total_pages"]
        config.totalCount = node["total_count"]
        config.totalPagesRemaining = node["total_pages_remaining"]
        if let next = node["next"] {
            if let components = URLComponents(string: next) {
                config.nextQuery = components
            }
        }
        return config
    }

    private func parseResponseConfig(_ response: HTTPURLResponse?) -> ResponseConfig {
        let config = ResponseConfig()

        if let response = response {
            config.statusCode = response.statusCode
            config.lastModified = response.allHeaderFields["Last-Modified"] as? String
            config.totalPages = response.allHeaderFields["X-Total-Pages"] as? String
            config.totalCount = response.allHeaderFields["X-Total-Count"] as? String
            config.totalPagesRemaining = response.allHeaderFields["X-Total-Pages-Remaining"] as? String
            config.nextQuery = response.findLink(relation: "next").flatMap { URLComponents(string: $0.uri) }
        }

        return config
    }

    private func isEmptySuccess(_ data: Data, statusCode: Int?) -> Bool {
        guard let statusCode = statusCode else { return false }

        // accepted || no content
        if statusCode == 202 || statusCode == 204 {
            return true
        }
        // no content
        return String(data: data, encoding: .utf8) == "" &&
                statusCode >= 200 &&
                statusCode < 400
    }

    private func handleServerError(request: RequestFuture, response moyaResponse: Moya.Response) {
        let data = moyaResponse.data
        let statusCode = moyaResponse.statusCode
        let elloError = ElloProvider.generateElloError(data, statusCode: statusCode)
        Tracker.shared.encounteredNetworkError(request.target.path, error: elloError, statusCode: statusCode)
        request.reject(elloError)
    }

    private func handleNetworkFailure(request: RequestFuture) {
        delay(1) {
            self.sendRequest(request)
        }
    }

    private func postOldAPINotification() {
        postNotification(AuthenticationNotifications.outOfDateAPI, value: ())
    }
}
