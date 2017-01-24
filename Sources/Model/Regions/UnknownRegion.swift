////
///  UnknownRegion.swift
//

import Foundation

let UnknownRegionVersion = 1

@objc(UnknownRegion)
final class UnknownRegion: NSObject, Regionable, NSCoding {
    let version = UnknownRegionVersion
    var isRepost: Bool = false

    var kind: String { return RegionKind.unknown.rawValue }

    func coding() -> NSCoding {
        return self
    }

    // no-op initializer to allow stubbing
    init(name: String) {}


// MARK: NSCoding

    func encode(with encoder: NSCoder) {
    }

    required init?(coder decoder: NSCoder) {

    }

    func toJSON() -> [String: AnyObject] {
        return [:]
    }
}
