////
///  NumberExtensions.swift
//

import Foundation

let billion = 1_000_000_000.0
let million = 1_000_000.0
let thousand = 1_000.0

extension Int {

    func numberToHuman(rounding: Int = 2, showZero: Bool = false) -> String {
        if self == 0 && !showZero { return "" }

        let roundingFactor: Double = pow(10, Double(rounding))
        let double = Double(self)
        let num: Float
        let suffix: String
        if double >= billion {
            num = Float(round(double / billion * roundingFactor) / roundingFactor)
            suffix = "B"
        }
        else if double >= million {
            num = Float(round(double / million * roundingFactor) / roundingFactor)
            suffix = "M"
        }
        else if double >= thousand {
            num = Float(round(double / thousand * roundingFactor) / roundingFactor)
            suffix = "K"
        }
        else {
            num = Float(round(double * roundingFactor) / roundingFactor)
            suffix = ""
        }
        var strNum = "\(num)"
        let strArr = strNum.characters.split { $0 == "." }.map { String($0) }
        if strArr.last == "0" {
            strNum = strArr.first!
        }
        return "\(strNum)\(suffix)"
    }

    func localizedStringFromNumber() -> String {
        if self == 0 {
            return ""
        }
        return NumberFormatter.localizedString(from: NSNumber(value: self as Int), number: NumberFormatter.Style.decimal)
    }

}
