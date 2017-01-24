////
///  SpecsTrackingAgent.swift
//

@testable import Ello

class SpecsTrackingAgent: AnalyticsAgent {

    var resetCalled = false
    var lastEvent = ""
    var lastUserId = ""
    var lastTraits: [AnyHashable: Any] = [:]
    var lastScreenTitle = ""
    var lastProperties: [AnyHashable: Any] = [:]

    func identify(_ userId: String!, traits: [AnyHashable: Any]!) {
        lastUserId = userId
        lastTraits = traits
    }

    func track(_ event: String!) {
        lastEvent = event
    }

    func track(_ event: String!, properties: [AnyHashable: Any]!) {
        lastEvent = event
        lastProperties = properties
    }

    func screen(_ screenTitle: String!) {
        lastScreenTitle = screenTitle
    }

    func screen(_ screenTitle: String!, properties: [AnyHashable: Any]!) {
        lastScreenTitle = screenTitle ?? ""
        lastProperties = properties ?? [:]
    }

    func reset() {
        resetCalled = true
    }
}
