////
///  AppSetup.swift
//

import SwiftyUserDefaults

class AppSetup {
    static var shared: AppSetup = AppSetup()

    lazy var isTesting: Bool = _isTesting()
    lazy var isSimulator: Bool = _isRunningOnSimulator()
    lazy var isIphoneX: Bool = _isIphoneX()

    lazy var statusBarHeight: CGFloat = _statusBarHeight()
    lazy var bestBottomMargin: CGFloat = _bestBottomMargin()

    var imageQuality: CGFloat = 0.8
    var nowGenerator: () -> Date = { return Date() }
    var now: Date { return nowGenerator() }

    var cachedCategories: [Category]?
}

private func _isRunningOnSimulator() -> Bool {
    // http://stackoverflow.com/questions/24869481/detect-if-app-is-being-built-for-device-or-simulator-in-swift
    #if (arch(i386) || arch(x86_64)) && (os(iOS) || os(watchOS) || os(tvOS))
        return true
    #else
        return false
    #endif
}

private func _isTesting() -> Bool {
    return NSClassFromString("XCTest") != nil
}

private func _isIphoneX() -> Bool {
    return UIScreen.main.bounds.size.height == 812
}

private func _statusBarHeight() -> CGFloat {
    if AppSetup.shared.isIphoneX {
        return 44
    }
    return 20
}

private func _bestBottomMargin() -> CGFloat {
    if AppSetup.shared.isIphoneX {
        return 23
    }
    return 10
}
