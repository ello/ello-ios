////
///  AppSetup.swift
//

import SwiftyUserDefaults

public class AppSetup {
    public struct Size {
        public static let calculatorHeight = CGFloat(20)
    }

    public var isTesting = false
    private var _isSimulator: Bool?
    public var isSimulator: Bool {
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
    private static var isRunningOnSimulator: Bool {
        // http://stackoverflow.com/questions/24869481/detect-if-app-is-being-built-for-device-or-simulator-in-swift
        #if (arch(i386) || arch(x86_64)) && (os(iOS) || os(watchOS) || os(tvOS))
            return true
        #else
            return false
        #endif
    }


    public class var sharedState: AppSetup {
        struct Static {
            static let instance = AppSetup()
        }
        return Static.instance
    }

    public init() {
        if NSClassFromString("XCTest") != nil {
            isTesting = true
        }
    }

}
