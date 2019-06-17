////
///  QuantcastAgent.swift
//

import Quantcast_Measure


struct QuantcastAgent: AnalyticsAgent {
    func identify(_ userId: String?, traits: [String: Any]?) {
        QuantcastMeasurement.sharedInstance().recordUserIdentifier(userId, withLabels: nil)
    }

    func track(_ event: String) {
    }

    func track(_ event: String, properties: [String: Any]?) {
    }

    func screen(_ screenTitle: String) {
    }

    func screen(_ screenTitle: String, properties: [String: Any]?) {
    }

    func reset() {
        QuantcastMeasurement.sharedInstance().recordUserIdentifier(nil, withLabels: nil)
    }
}
