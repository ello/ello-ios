////
///  DateFormatting.swift
//

import Foundation

let ServerDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    return formatter
}()

let HTTPDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.dateFormat = "eee, dd MMM yyyy HH:mm:ss zzz"
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    return formatter
}()
