////
///  InviteCache.swift
//

import Foundation

private let key = "ElloInviteCache"

struct InviteCache {
    var cache: [String]

    init() {
        if let existing = GroupDefaults[key].array as? [String] {
            cache = existing
        }
        else {
            cache = []
        }
    }

    mutating func saveInvite(_ contactID: String) {
        guard !has(contactID) else { return }

        cache.append(contactID)
        GroupDefaults[key] = cache
    }

    func has(_ contactID: String) -> Bool {
        return cache.contains(contactID)
    }

    mutating func clear() {
        cache = []
        GroupDefaults[key] = nil
    }
}
