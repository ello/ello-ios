////
///  NSObjectClassName.swift
//

extension NSObject {
    func readableClassName() -> String {
        return type(of: self).readableClassName()
    }

    class func readableClassName() -> String {
        let classString = NSStringFromClass(self)
        let range = classString.range(
            of: ".",
            options: .caseInsensitive,
            range: classString.startIndex..<classString.endIndex,
            locale: nil
        )
        return range.map { String(classString[$0.upperBound...]) } ?? classString
    }
}
