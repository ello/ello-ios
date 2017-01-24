////
///  ScreenExtensions.swift
//

extension UIWindow {
    class var mainWindow: UIWindow {
        return UIApplication.shared.keyWindow ?? UIWindow()
    }

    class func windowBounds() -> CGRect {
        return mainWindow.bounds
    }

    class func windowSize() -> CGSize {
        return windowBounds().size
    }

    class func windowWidth() -> CGFloat {
        return windowSize().width
    }

    class func windowHeight() -> CGFloat {
        return windowSize().height
    }

}


class Window {
    static func isWide(_ width: CGFloat) -> Bool {
        return width > 1000
    }
    static var width: CGFloat { return UIWindow.mainWindow.frame.size.width }
}
