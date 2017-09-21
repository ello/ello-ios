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
    static func columnCountFor(width: CGFloat) -> Int {
        let gridColumns: Int
        if Window.isWide(width) {
            gridColumns = 3
        }
        else {
            gridColumns = 2
        }

        return gridColumns
    }

    static func isWide(_ width: CGFloat) -> Bool {
        return width >= 768
    }

    fileprivate static var _width: CGFloat?
    static var width: CGFloat {
        get {
            return Window._width ?? UIWindow.mainWindow.frame.size.width
        }
        set {
            if Globals.isTesting {
                Window._width = newValue
            }
        }
    }
}

class DeviceScreen {
    static var isRetina: Bool {
        return scale > 1
    }

    fileprivate static var _scale: CGFloat?
    static var scale: CGFloat {
        get {
            return DeviceScreen._scale ?? UIScreen.main.scale
        }
        set {
            if Globals.isTesting {
                DeviceScreen._scale = newValue
            }
        }
    }
}
