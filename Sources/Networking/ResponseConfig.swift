////
///  ResponseConfig.swift
//

import Foundation

class ResponseConfig: CustomStringConvertible {
    var description: String {
        let descripArray = [
            "ResponseConfig:",
            "nextQueryItems: \(nextQueryItems)",
            "prevQueryItems: \(prevQueryItems)",
            "firstQueryItems: \(firstQueryItems)",
            "lastQueryItems: \(lastQueryItems)",
            "totalPages: \(totalPages)",
            "totalCount: \(totalCount)",
            "totalPagesRemaining: \(totalPagesRemaining)"
        ]
        return descripArray.joined(separator: "\n\t")
    }
    var nextQueryItems: [AnyObject]? // before (older)
    var prevQueryItems: [AnyObject]? // after (newer)
    var firstQueryItems: [AnyObject]? // first page
    var lastQueryItems: [AnyObject]? // last page
    var totalCount: String?
    var totalPages: String?
    var totalPagesRemaining: String?
    var statusCode: Int?
    var lastModified: String?
    var isFinalValue: Bool

    init(isFinalValue: Bool = true) {
        self.isFinalValue = isFinalValue
    }

    func isOutOfData() -> Bool {

        return totalPagesRemaining == "0"
            || totalPagesRemaining == nil
            || nextQueryItems?.count == 0
            || nextQueryItems == nil
    }
}
