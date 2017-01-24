////
///  NSObjectClassName.swift
//

import Foundation

extension NSObject {
    func readableClassName() -> String {
        return type(of: self).readableClassName()
    }

    class func readableClassName() -> String {
        let classString = NSStringFromClass(self)
        let range = classString.range(of: ".", options: .caseInsensitive, range: classString.characters.startIndex..<classString.characters.endIndex, locale: nil)
        return range.map { classString.substring(from: $0.upperBound) } ?? classString
    }
}
