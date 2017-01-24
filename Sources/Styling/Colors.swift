////
///  Colors.swift
//

import UIKit

private struct ElloColors {
    static let grey231F20: UIColor = UIColor(hex: 0x231F20)
    static let grey3: UIColor = UIColor(hex: 0x333333)
    static let grey4D: UIColor = UIColor(hex: 0x4D4D4D)
    static let greenD1: UIColor = UIColor(hex: 0x00D100)
    static let grey5: UIColor = UIColor(hex: 0x555555)
    static let grey6: UIColor = UIColor(hex: 0x666666)
    static let greyA: UIColor = UIColor(hex: 0xAAAAAA)
    static let greyC: UIColor = UIColor(hex: 0xCCCCCC)
    static let greyE5: UIColor = UIColor(hex: 0xE5E5E5)
    static let greyF1: UIColor = UIColor(hex: 0xF1F1F1)
    static let greyF2: UIColor = UIColor(hex: 0xF2F2F2)
    static let yellowFFFFCC: UIColor = UIColor(hex: 0xFFFFCC)
    static let redFFCCCC: UIColor = UIColor(hex: 0xFFCCCC)
    static let modalBackground: UIColor = UIColor(white: 0x000000, alpha: 0.7)
}

extension UIColor {
    // These colors are taken from the web styleguide. Any other variations should be
    // double checked with B&F or normalized to one of these..

    // for these colors, just use UIColor.*Color()
    // black - 0x000000
    // white - 0xFFFFFF
    // red - 0xFF0000

    // This color is used as the background on all disabled Ello buttons
    class func grey231F20() -> UIColor { return ElloColors.grey231F20 }

    // common background color
    class func grey3() -> UIColor { return ElloColors.grey3 }

    // dark line color
    class func grey5() -> UIColor { return ElloColors.grey5 }

    // often used for text:
    class func greyA() -> UIColor { return ElloColors.greyA }

    // often used for disabled text:
    class func greyC() -> UIColor { return ElloColors.greyC }

    // background color for text fields
    class func greyE5() -> UIColor { return ElloColors.greyE5 }

    // button title color
    class func grey6() -> UIColor { return ElloColors.grey6 }

    // Used to color @ mention in omnibar/posts
    class func yellowFFFFCC() -> UIColor { return ElloColors.yellowFFFFCC }

    // Used to color @@ direct mention in omnibar/posts (not implemented yet)
    class func redFFCCCC() -> UIColor { return ElloColors.redFFCCCC }

    // not popular
    class func greyF1() -> UIColor { return ElloColors.greyF1 }
    class func greyF2() -> UIColor { return ElloColors.greyF2 }
    class func grey4D() -> UIColor { return ElloColors.grey4D }

    // get started button background
    class func greenD1() -> UIColor { return ElloColors.greenD1 }

    // explains itself
    class func modalBackground() -> UIColor { return ElloColors.modalBackground }
}
