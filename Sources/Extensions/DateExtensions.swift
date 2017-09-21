////
///  Date.swift
//

extension Date {

    func monthDay() -> String {
        return MonthDayFormatter.string(from: self)
    }

    func monthDayYear() -> String {
        return MonthDayYearFormatter.string(from: self)
    }

    func toServerDateString() -> String {
        return ServerDateFormatter.string(from: self)
    }

    func toHTTPDateString() -> String {
        return HTTPDateFormatter.string(from: self)
    }

    var isInPast: Bool {
        let now = Globals.now
        return self.compare(now) == ComparisonResult.orderedAscending
    }

}
