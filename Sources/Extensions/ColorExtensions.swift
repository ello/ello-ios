////
///  ColorExtensions.swift
//

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, av: Float) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: CGFloat(av))
    }

    convenience init(hex: Int, alpha: Float = 1) {
        self.init(red: (hex >> 16) & 0xff, green: (hex >> 8) & 0xff, blue: hex & 0xff, av: alpha)
    }
}
