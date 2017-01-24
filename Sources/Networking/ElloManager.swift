////
///  ElloManager.swift
//

import Foundation
import Alamofire
import ElloCerts


struct ElloManager {
    static var serverTrustPolicies: [String: ServerTrustPolicy] {
        let policyDict: [String: ServerTrustPolicy]
        if AppSetup.sharedState.isSimulator {
            // make Charles plays nice in the sim by not setting a policy
            policyDict = [:]
        }
        else {
            policyDict = ElloCerts.policy
        }
        return policyDict
    }

    static var manager: SessionManager {
        let config = URLSessionConfiguration.default
        config.sharedContainerIdentifier = ElloGroupName
        return SessionManager(
            configuration: config,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: ElloManager.serverTrustPolicies)
        )
    }

    static var shareExtensionManager: SessionManager {
        let config = URLSessionConfiguration.background(withIdentifier: "co.ello.shareextension.background")
        config.sharedContainerIdentifier = ElloGroupName
        config.sessionSendsLaunchEvents = false
        return SessionManager(
            configuration: config,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: ElloManager.serverTrustPolicies)
        )
    }

}
