////
///  GraphQLProvider.swift
//

import Moya
import Alamofire
import PromiseKit
import SwiftyJSON


class GraphQLProvider {
    typealias Response = (JSON)
    typealias RequestFuture = (target: ElloGraphQL, resolve: (Response) -> Void, reject: ErrorBlock)

    static let shared: GraphQLProvider = GraphQLProvider()

    static func endpointClosure(_ target: ElloGraphQL) -> Endpoint<ElloGraphQL> {
        let url = target.baseURL.appendingPathComponent(target.path).absoluteString
        let endpoint = Endpoint<ElloGraphQL>(url: url, sampleResponseClosure: { return target.stubbedNetworkResponse }, method: target.method, parameters: target.parameters, parameterEncoding: target.parameterEncoding)
        return endpoint.adding(newHTTPHeaderFields: target.headers())
    }

    static func DefaultProvider() -> MoyaProvider<ElloGraphQL> {
        return MoyaProvider<ElloGraphQL>(endpointClosure: GraphQLProvider.endpointClosure, manager: ElloManager.manager)
    }

    static func ShareExtensionProvider() -> MoyaProvider<ElloGraphQL> {
        return MoyaProvider<ElloGraphQL>(endpointClosure: GraphQLProvider.endpointClosure, manager: ElloManager.shareExtensionManager)
    }

    private static var defaultProvider: MoyaProvider<ElloGraphQL> = GraphQLProvider.DefaultProvider()
    static var oneTimeProvider: MoyaProvider<ElloGraphQL>?
    static var moya: MoyaProvider<ElloGraphQL> {
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

    func request(_ target: ElloGraphQL) -> Promise<Response> {
        let (promise, resolve, reject) = Promise<Response>.pending()
        sendRequest((target, resolve: resolve, reject: reject))
        return promise
    }

    private func sendRequest(_ request: RequestFuture) {
        AuthenticationManager.shared.attemptRequest(request.target,
            retry: { self.sendRequest(request) },
            proceed: { uuid in
                GraphQLProvider.moya.request(request.target) { result in
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


extension GraphQLProvider {

    private func handleRequest(request: RequestFuture, result: MoyaResult, uuid: UUID) {
        switch result {
        case let .success(moyaResponse):
            switch moyaResponse.statusCode {
            case 200...299, 300...399:
                handleNetworkSuccess(request: request, response: moyaResponse)
            case 410:
                postOldAPINotification()
            case 401:
                AuthenticationManager.shared.attemptAuthentication(uuid: uuid) { self.sendRequest(request) }
            default:
                handleServerError(request: request, response: moyaResponse)
            }
        case .failure:
            handleNetworkFailure(request: request)
        }
    }

    private func handleNetworkSuccess(request: RequestFuture, response moyaResponse: Moya.Response) {
        let data = moyaResponse.data

        let json = JSON(data: data)
        request.resolve(json)
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
