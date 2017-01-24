////
///  NSStringExtensions.swift
//

import Foundation

extension NSString {
    func toDate(_ formatter: DateFormatter = ServerDateFormatter) -> Date? {
        return formatter.date(from: self as String)
    }
}
