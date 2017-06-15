////
///  ElloProvider.swift
//

import Moya
import Result
import Alamofire
import PromiseKit


typealias ElloRequestClosure = (target: ElloAPI, success: ElloSuccessCompletion, failure: ElloFailureCompletion)
typealias ElloSuccessCompletion = (Any, ResponseConfig) -> Void
typealias ElloFailureCompletion = (NSError, Int?) -> Void
typealias ElloErrorCompletion = (NSError) -> Void
typealias ElloEmptyCompletion = () -> Void
typealias ElloAPIResponse = (Any, ResponseConfig)

class ElloProvider {
    static var shared: ElloProvider = ElloProvider()
    var authState: AuthState = .initial {
        willSet {
            if newValue != authState && !authState.canTransitionTo(newValue) && !AppSetup.sharedState.isTesting {
                print("invalid transition from \(authState) to \(newValue)")
            }
        }
    }

    static func endpointClosure(_ target: ElloAPI) -> Endpoint<ElloAPI> {
        let endpoint = Endpoint<ElloAPI>(url: url(target), sampleResponseClosure: { return target.stubbedNetworkResponse }, method: target.method, parameters: target.parameters, parameterEncoding: target.parameterEncoding)
        return endpoint.adding(newHTTPHeaderFields: target.headers())
    }

    static func DefaultProvider() -> MoyaProvider<ElloAPI> {
        return MoyaProvider<ElloAPI>(endpointClosure: ElloProvider.endpointClosure, manager: ElloManager.manager)
    }

    static func ShareExtensionProvider() -> MoyaProvider<ElloAPI> {
        return MoyaProvider<ElloAPI>(endpointClosure: ElloProvider.endpointClosure, manager: ElloManager.shareExtensionManager)
    }

    fileprivate struct SharedProvider {
        static var instance = ElloProvider.DefaultProvider()
    }

    static var oneTimeProvider: MoyaProvider<ElloAPI>?
    static var sharedProvider: MoyaProvider<ElloAPI> {
        get {
            if let provider = oneTimeProvider {
                oneTimeProvider = nil
                return provider
            }
            return SharedProvider.instance
        }

        set (newSharedProvider) {
            SharedProvider.instance = newSharedProvider
        }
    }

    // MARK: - Public

    func request(_ target: ElloAPI) -> Promise<ElloAPIResponse> {
        let (promise, fulfill, reject) = Promise<ElloAPIResponse>.pending()
        elloRequest((target,
            success: { jsonables, responseConfig in
                fulfill((jsonables, responseConfig))
            },
            failure: { error, _ in
                reject(error)
            }))
        return promise
    }

    fileprivate func elloRequest(_ target: ElloAPI, success: @escaping ElloSuccessCompletion) {
        elloRequest((target: target, success: success, failure: { _ in }))
    }

    fileprivate func elloRequest(_ target: ElloAPI, success: @escaping ElloSuccessCompletion, failure: @escaping ElloFailureCompletion) {
        elloRequest((target: target, success: success, failure: failure))
    }

    fileprivate func elloRequest(_ request: ElloRequestClosure) {
        let target = request.target
        let success = request.success
        let failure = request.failure
        let uuid = AuthState.uuid

        if authState.isUndetermined {
            self.attemptAuthentication(request: request, uuid: uuid as UUID)
        }
        else if authState.isTransitioning {
            waitList.append(request)
        }
        else {
            if !authState.supports(target) {
                print("cannot send: \(target)")
            }
            let canMakeRequest = authState.supports(target)
            if canMakeRequest {
                ElloProvider.sharedProvider.request(target) { (result) in
                    self.handleRequest(target: target, result: result, success: success, failure: failure, uuid: uuid)
                }
            }
            else {
                requestFailed(failure)
            }
        }
    }

    fileprivate func requestFailed(_ failure: @escaping ElloFailureCompletion) {
        let elloError = NSError(domain: ElloErrorDomain, code: 401, userInfo: [NSLocalizedFailureReasonErrorKey: "Logged Out"])
        inForeground {
            failure(elloError, 401)
        }
    }

    var waitList: [ElloRequestClosure] = []

    func logout() {
        if authState.canTransitionTo(.noToken) {
            self.advanceAuthState(.noToken)
        }
    }

    func authenticated(isPasswordBased: Bool) {
        if isPasswordBased {
            self.advanceAuthState(.authenticated)
        }
        else {
            self.advanceAuthState(.anonymous)
        }
    }

    // set queue to nil in specs, and reauth requests are sent synchronously.
    var queue: DispatchQueue? = DispatchQueue(label: "com.ello.ReauthQueue", attributes: [])
    fileprivate func attemptAuthentication(request: ElloRequestClosure? = nil, uuid: UUID) {
        let closure = {
            let shouldResendRequest = uuid != AuthState.uuid as UUID
            if let request = request, shouldResendRequest {
                self.elloRequest(request)
                return
            }

            if let request = request {
                self.waitList.append(request)
            }

            switch self.authState {
            case .initial:
                let authToken = AuthToken()
                if authToken.isPasswordBased {
                    self.authState = .authenticated
                }
                else if authToken.isAnonymous {
                    self.authState = .anonymous
                }
                else {
                    self.authState = .shouldTryAnonymousCreds
                }
                self.advanceAuthState(self.authState)
            case .anonymous:
                // an anonymous-authenticated request resulted in a 401 - we
                // should log the user out
                self.advanceAuthState(.noToken)
            case .authenticated, .shouldTryRefreshToken:
                self.authState = .refreshTokenSent

                let authService = ReAuthService()
                authService.reAuthenticateToken(success: {
                    self.advanceAuthState(.authenticated)
                },
                failure: { _ in
                    self.advanceAuthState(.shouldTryUserCreds)
                }, noNetwork:{
                    self.advanceAuthState(.shouldTryRefreshToken)
                })
            case .shouldTryUserCreds:
                self.authState = .userCredsSent

                let authService = ReAuthService()
                authService.reAuthenticateUserCreds(success: {
                    self.advanceAuthState(.authenticated)
                },
                failure: { _ in
                    self.advanceAuthState(.noToken)
                }, noNetwork:{
                    self.advanceAuthState(.shouldTryUserCreds)
                })
            case .shouldTryAnonymousCreds, .noToken:
                self.authState = .anonymousCredsSent

                let authService = AnonymousAuthService()
                authService.authenticateAnonymously(success: {
                    self.advanceAuthState(.anonymous)
                }, failure: { _ in
                    self.advanceAuthState(.noToken)
                }, noNetwork: {
                    self.advanceAuthState(.shouldTryAnonymousCreds)
                })
            case .refreshTokenSent, .userCredsSent, .anonymousCredsSent:
                break
            }
        }
        if let queue = queue {
            queue.async(execute: closure)
        }
        else {
            closure()
        }
    }

    fileprivate func advanceAuthState(_ nextState: AuthState) {
        let closure = {
            self.authState = nextState

            if nextState == .noToken {
                AuthState.uuid = UUID()
                AuthToken.reset()

                for request in self.waitList {
                    if nextState.supports(request.target) {
                        self.elloRequest(request)
                    }
                    else {
                        self.requestFailed(request.failure)
                    }
                }
                self.waitList = []
                nextTick {
                    self.postInvalidTokenNotification()
                }
            }
            else if nextState == .anonymous {
                // if you were using the app, but got logged out, you will
                // quickly receive an anonymous token.  If any Requests don't
                // support this flow , we should kick you out and present the
                // log in screen.  During login/join, though, all the Requests
                // *will* support an anonymous token.
                //
                // if, down the road, we have anonymous browsing, we should
                // require and implement robust invalidToken handlers for all
                // Controllers & Services

                AuthState.uuid = UUID()

                for request in self.waitList {
                    if !nextState.supports(request.target) {
                        self.requestFailed(request.failure)
                    }
                    else {
                        self.elloRequest(request)
                    }
                }
                self.waitList = []
            }
            else if nextState.isAuthenticated {
                AuthState.uuid = UUID()

                let flushWaitList: ElloEmptyCompletion = {
                    for request in self.waitList {
                        self.elloRequest(request)
                    }
                    self.waitList = []
                }
                if self.queue == nil {
                    flushWaitList()
                }
                else {
                    DispatchQueue.main.async(execute: flushWaitList)
                }
            }
            else {
                sleep(1)
                self.attemptAuthentication(uuid: AuthState.uuid as UUID)
            }
        }
        if let queue = queue {
            queue.async(execute: closure)
        }
        else {
            closure()
        }
    }

}


// MARK: elloRequest implementation
extension ElloProvider {

    // MARK: - Private

    fileprivate func handleRequest(target: ElloAPI, result: MoyaResult, success: @escaping ElloSuccessCompletion, failure: @escaping ElloFailureCompletion, uuid: UUID) {
        switch result {
        case let .success(moyaResponse):
            let response = moyaResponse.response as? HTTPURLResponse
            let data = moyaResponse.data
            let statusCode = moyaResponse.statusCode

            switch statusCode {
            case 200...299, 300...399:
                handleNetworkSuccess(data: data, elloAPI: target, statusCode:statusCode, response: response, success: success, failure: failure)
            case 401:
                attemptAuthentication(request: (target: target, success: success, failure: failure), uuid: uuid)
            case 410:
                postNetworkFailureNotification(data, statusCode: statusCode)
            default:
                handleServerError(target.path, failure: failure, data: data, statusCode: statusCode)
            }

        case let .failure(error):
            handleNetworkFailure(target, success: success, failure: failure, error: error)
        }
    }

    fileprivate func postInvalidTokenNotification() {
        postNetworkFailureNotification(nil, statusCode: 401)
        postNotification(AuthenticationNotifications.invalidToken, value: true)
    }

    fileprivate func parseLinked(_ elloAPI: ElloAPI, dict: [String: Any], responseConfig: ResponseConfig, success: @escaping ElloSuccessCompletion, failure: @escaping ElloFailureCompletion) {
        let completion: ElloEmptyCompletion = {
            let node = dict[elloAPI.mappingType.rawValue]
            var newResponseConfig: ResponseConfig?
            if let pagingPath = elloAPI.pagingPath,
                let links = (node as? [String: Any])?["links"] as? [String: Any],
                let pagingPathNode = links[pagingPath] as? [String:Any],
                let pagination = pagingPathNode["pagination"] as? [String: String]
            {
                newResponseConfig = self.parsePagination(pagination)
            }

            guard elloAPI.mappingType != .noContentType else {
                success(UnknownJSONAble(), newResponseConfig ?? responseConfig)
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
                success(mappedObjects, newResponseConfig ?? responseConfig)
            }
            else {
                ElloProvider.failedToMapObjects(failure)
            }
        }

        if let linked = dict["linked"] as? [String:[[String:Any]]] {
            ElloLinkedStore.sharedInstance.parseLinked(linked, completion: completion)
        }
        else {
            completion()
        }
    }

    fileprivate func handleNetworkSuccess(data: Data, elloAPI: ElloAPI, statusCode: Int?, response: HTTPURLResponse?, success: @escaping ElloSuccessCompletion, failure: @escaping ElloFailureCompletion) {
        let (mappedJSON, error): (Any?, NSError?) = Mapper.mapJSON(data)
        let responseConfig = parseResponse(response)
        if mappedJSON != nil && error == nil {
            if let dict = mappedJSON as? [String: Any] {
                parseLinked(elloAPI, dict: dict, responseConfig: responseConfig, success: success, failure: failure)
            }
            else {
                ElloProvider.failedToMapObjects(failure)
            }
        }
        else if isEmptySuccess(data, statusCode: statusCode) {
            success("", responseConfig)
        }
        else {
            ElloProvider.failedToMapObjects(failure)
        }
    }

    fileprivate func isEmptySuccess(_ data: Data, statusCode: Int?) -> Bool {
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

    fileprivate func postNetworkFailureNotification(_ data: Data?, statusCode: Int?) {
        let elloError = ElloProvider.generateElloError(data, statusCode: statusCode)
        let notificationCase: ErrorStatusCode
        if let statusCode = statusCode {
            if let noteCase = ErrorStatusCode(rawValue: statusCode) {
                notificationCase = noteCase
            }
            else {
                notificationCase = ErrorStatusCode.statusUnknown
            }
        }
        else {
            notificationCase = ErrorStatusCode.statusUnknown
        }

        postNotification(notificationCase.notification, value: elloError)
    }

    fileprivate func handleServerError(_ path: String, failure: ElloFailureCompletion, data: Data?, statusCode: Int?) {
        let elloError = ElloProvider.generateElloError(data, statusCode: statusCode)
        Tracker.shared.encounteredNetworkError(path, error: elloError, statusCode: statusCode)
        failure(elloError, statusCode)
    }

    fileprivate func handleNetworkFailure(_ target: ElloAPI, success: @escaping ElloSuccessCompletion, failure: @escaping ElloFailureCompletion, error: Swift.Error?) {
        delay(1) {
            self.elloRequest(target, success: success, failure: failure)
        }
    }

    fileprivate func parsePagination(_ node: [String: String]) -> ResponseConfig {
        let config = ResponseConfig()
        config.totalPages = node["total_pages"]
        config.totalCount = node["total_count"]
        config.totalPagesRemaining = node["total_pages_remaining"]
        if let next = node["next"] {
            if let comps = URLComponents(string: next) {
                config.nextQueryItems = comps.queryItems as [Any]?
            }
        }
        if let prev = node["prev"] {
            if let comps = URLComponents(string: prev) {
                config.prevQueryItems = comps.queryItems as [Any]?
            }
        }
        if let first = node["first"] {
            if let comps = URLComponents(string: first) {
                config.firstQueryItems = comps.queryItems as [Any]?
            }
        }
        if let last = node["last"] {
            if let comps = URLComponents(string: last) {
                config.lastQueryItems = comps.queryItems as [Any]?
            }
        }
        return config
    }

    fileprivate func parseResponse(_ response: HTTPURLResponse?) -> ResponseConfig {
        let config = ResponseConfig()
        config.statusCode = response?.statusCode
        config.lastModified = response?.allHeaderFields["Last-Modified"] as? String
        config.totalPages = response?.allHeaderFields["X-Total-Pages"] as? String
        config.totalCount = response?.allHeaderFields["X-Total-Count"] as? String
        config.totalPagesRemaining = response?.allHeaderFields["X-Total-Pages-Remaining"] as? String

        return parseLinks(response, config: config)
    }
}
