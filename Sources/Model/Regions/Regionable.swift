////
///  Regionable.swift
//

import Foundation

@objc
protocol Regionable {
    var kind: String { get }
    var isRepost: Bool { get set }
    func toJSON() -> [String: AnyObject]
    func coding() -> NSCoding
}
