////
///  ElloManager.swift
//

import Alamofire
import ElloCerts


protocol Response {
    var request: URLRequest? { get }
    var response: HTTPURLResponse? { get }
    var data: Data? { get }
    var error: Error? { get }
}


protocol RequestTask {
    func resume()
}


typealias RequestHandler = (Response) -> Void


protocol RequestManager {
    func request(_ request: URLRequest, sender: Any, _ handler: @escaping RequestHandler) -> RequestTask
}


struct ElloManager: RequestManager {
    static var serverTrustPolicies: [String: ServerTrustPolicy] {
        let policyDict: [String: ServerTrustPolicy]
        if Globals.isSimulator {
            // make Charles plays nice in the sim by not setting a policy
            policyDict = [:]
        }
        else if Globals.isTesting {
            // allow testing of policy certs
            policyDict = ElloCerts.policy
        }
        else {
#if DEBUG
            // avoid policy certs on any debug build
            policyDict = [:]
#else
            policyDict = ElloCerts.policy
#endif
        }
        return policyDict
    }

    static func alamofireManager() -> SessionManager {
        let config = URLSessionConfiguration.default
        config.sharedContainerIdentifier = ElloGroupName
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        return SessionManager(
            configuration: config,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: ElloManager.serverTrustPolicies)
        )
    }

    func request(_ urlRequest: URLRequest, sender: Any, _ handler: @escaping RequestHandler) -> RequestTask {
        let manager = ElloManager.alamofireManager()
        var retain: SessionManager? = manager
        let task = manager.request(urlRequest)
        return task.response { response in
            retain = nil
            handler(response)
        }
    }

}

extension Alamofire.Request: RequestTask {}
extension DefaultDataResponse: Response {}
