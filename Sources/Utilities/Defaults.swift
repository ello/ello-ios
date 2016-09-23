////
///  Defaults.swift
//

import Foundation

public let ElloGroupName = "group.ello.Ello"
public let GroupDefaults = defaults()

private func defaults() -> NSUserDefaults {
    if AppSetup.sharedState.isTesting {
        return NSUserDefaults.standardUserDefaults()
    }

    return NSUserDefaults(suiteName: ElloGroupName) ?? NSUserDefaults.standardUserDefaults()
}
