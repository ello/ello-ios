////
///  Date.swift
//

import Foundation

extension Date {

    func toServerDateString() -> String {
        return ServerDateFormatter.string(from: self)
    }

    func toHTTPDateString() -> String {
        return HTTPDateFormatter.string(from: self)
    }

    var isInPast: Bool {
        let now = Date()
        return self.compare(now) == ComparisonResult.orderedAscending
    }

}
