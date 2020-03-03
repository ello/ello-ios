////
///  Colors.swift
//

extension UIColor {
    // These colors are taken from the web styleguide. Any other variations should be
    // double checked with B&F or normalized to one of these..

    // for these colors, just use UIColor.*Color()
    // black - 0x000000
    // white - 0xFFFFFF
    // red - 0xFF0000

    // This color is used as the background on all disabled Ello buttons
    static let grey231F20 = UIColor(hex: 0x231F20)

    // common background color
    static let grey3 = UIColor(hex: 0x333333)

    // dark line color
    static let grey5 = UIColor(hex: 0x555555)

    // often used for text:
    static let greyA = UIColor(hex: 0xAAAAAA)

    // often used for disabled text:
    static let greyC = UIColor(hex: 0xCCCCCC)

    // background color for text fields
    static let greyE5 = UIColor(hex: 0xE5E5E5)

    // background color for logged out container
    static let greyEF = UIColor(hex: 0xEFEFEF)

    // button title color
    static let grey6 = UIColor(hex: 0x666666)

    // not popular
    static let greyF1 = UIColor(hex: 0xF1F1F1)

    // line separator colors
    static let greyF2 = UIColor(hex: 0xF2F2F2)

    // get started button background
    static let greenD1 = UIColor(hex: 0x00D100)
    static let orangeC6 = UIColor(hex: 0xFFC600)

    // explains itself
    static let dimmedModalBackground = UIColor(white: 0x0, alpha: 0.7)
    static let dimmedBlackBackground = UIColor(white: 0x0, alpha: 0.5)

    static var background: UIColor = .dynamic(dark: .black, light: .white)
    static var text: UIColor = .dynamic(dark: .white, light: .black)
    static var selected: UIColor = .dynamic(dark: .white, light: .black)
    static var disabled: UIColor = .dynamic(dark: .grey3, light: .greyC)

    static func dynamic(dark: UIColor, light: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traits in
                traits.userInterfaceStyle == .dark ? dark : light
            }
        }
        return light
    }
}
