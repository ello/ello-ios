////
///  Defaults.swift
//

import Foundation

let ElloGroupName = "group.ello.Ello"
let GroupDefaults = defaults()

private func defaults() -> UserDefaults {
    if AppSetup.sharedState.isTesting {
        return UserDefaults.standard
    }

    return UserDefaults(suiteName: ElloGroupName) ?? UserDefaults.standard
}
