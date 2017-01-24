////
///  AppSetup.swift
//

import SwiftyUserDefaults

class AppSetup {
    struct Size {
        static let calculatorHeight = CGFloat(20)
    }

    var isTesting = false
    fileprivate var _isSimulator: Bool?
    var isSimulator: Bool {
        get {
            return _isSimulator ?? AppSetup.isRunningOnSimulator }
        set {
            if newValue == true {
                _isSimulator = nil
            }
            else {
                _isSimulator = false
            }
        }
    }

    /// Return true is application is running on simulator
    fileprivate static var isRunningOnSimulator: Bool {
        // http://stackoverflow.com/questions/24869481/detect-if-app-is-being-built-for-device-or-simulator-in-swift
        #if (arch(i386) || arch(x86_64)) && (os(iOS) || os(watchOS) || os(tvOS))
            return true
        #else
            return false
        #endif
    }


    class var sharedState: AppSetup {
        struct Static {
            static let instance = AppSetup()
        }
        return Static.instance
    }

    init() {
        if NSClassFromString("XCTest") != nil {
            isTesting = true
        }
    }

}
