////
///  Defaults.swift
//

let ElloGroupName = "group.ello.Ello"
let GroupDefaults = defaults()

private func defaults() -> UserDefaults {
    if Globals.isTesting {
        return UserDefaults.standard
    }

    return UserDefaults(suiteName: ElloGroupName) ?? UserDefaults.standard
}
