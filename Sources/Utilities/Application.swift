////
///  Application.swift
//

private let sharedApplication = Application()

class Application {

    struct Notifications {
        static let DidChangeStatusBarFrame = TypedNotification<Application>(name: "com.Ello.Application.DidChangeStatusBarFrame")
        static let DidChangeStatusBarOrientation = TypedNotification<UIInterfaceOrientation>(name: "com.Ello.Application.DidChangeStatusBarOrientation")
        static let DidEnterBackground = TypedNotification<Application>(name: "com.Ello.Application.DidEnterBackground")
        static let DidFinishLaunching = TypedNotification<Application>(name: "com.Ello.Application.DidFinishLaunching")
        static let DidReceiveMemoryWarning = TypedNotification<Application>(name: "com.Ello.Application.DidReceiveMemoryWarning")
        static let ProtectedDataDidBecomeAvailable = TypedNotification<Application>(name: "com.Ello.Application.ProtectedDataDidBecomeAvailable")
        static let ProtectedDataWillBecomeUnavailable = TypedNotification<Application>(name: "com.Ello.Application.ProtectedDataWillBecomeUnavailable")
        static let SignificantTimeChange = TypedNotification<Application>(name: "com.Ello.Application.SignificantTimeChange")
        static let UserDidTakeScreenshot = TypedNotification<Application>(name: "com.Ello.Application.UserDidTakeScreenshot")
        static let WillChangeStatusBarOrientation = TypedNotification<Application>(name: "com.Ello.Application.WillChangeStatusBarOrientation")
        static let WillChangeStatusBarFrame = TypedNotification<Application>(name: "com.Ello.Application.WillChangeStatusBarFrame")
        static let WillEnterForeground = TypedNotification<Application>(name: "com.Ello.Application.WillEnterForeground")
        static let WillResignActive = TypedNotification<Application>(name: "com.Ello.Application.WillResignActive")
        static let WillTerminate = TypedNotification<Application>(name: "com.Ello.Application.WillTerminate")
        static let SizeCategoryDidChange = TypedNotification<Application>(name: "com.Ello.Application.SizeCategoryDidChange")
        static let TraitCollectionDidChange = TypedNotification<UITraitCollection>(name: "com.Ello.Application.TraitCollectionDidChange")
        static let ViewSizeWillChange = TypedNotification<CGSize>(name: "com.Ello.Application.ViewSizeWillChange")
    }

    class func shared() -> Application {
        return sharedApplication
    }

    class func setup() {
        let _ = shared()
    }

    init() {
        let center: NotificationCenter = NotificationCenter.default
        center.addObserver(self, selector: #selector(Application.didChangeStatusBarFrame(_:)), name: NSNotification.Name.UIApplicationDidChangeStatusBarFrame, object: nil)
        center.addObserver(self, selector: #selector(Application.didChangeStatusBarOrientation(_:)), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
        center.addObserver(self, selector: #selector(Application.didEnterBackground(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        center.addObserver(self, selector: #selector(Application.didFinishLaunching(_:)), name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
        center.addObserver(self, selector: #selector(Application.didReceiveMemoryWarning(_:)), name: NSNotification.Name.UIApplicationDidChangeStatusBarFrame, object: nil)
        center.addObserver(self, selector: #selector(Application.protectedDataDidBecomeAvailable(_:)), name: NSNotification.Name.UIApplicationProtectedDataDidBecomeAvailable, object: nil)
        center.addObserver(self, selector: #selector(Application.protectedDataWillBecomeUnavailable(_:)), name: NSNotification.Name.UIApplicationProtectedDataWillBecomeUnavailable, object: nil)
        center.addObserver(self, selector: #selector(Application.significantTimeChange(_:)), name: NSNotification.Name.UIApplicationSignificantTimeChange, object: nil)
        center.addObserver(self, selector: #selector(Application.userDidTakeScreenshot(_:)), name: NSNotification.Name.UIApplicationUserDidTakeScreenshot, object: nil)
        center.addObserver(self, selector: #selector(Application.willChangeStatusBarOrientation(_:)), name: NSNotification.Name.UIApplicationDidChangeStatusBarFrame, object: nil)
        center.addObserver(self, selector: #selector(Application.willChangeStatusBarFrame(_:)), name: NSNotification.Name.UIApplicationWillChangeStatusBarFrame, object: nil)
        center.addObserver(self, selector: #selector(Application.willEnterForeground(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        center.addObserver(self, selector: #selector(Application.willResignActive(_:)), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        center.addObserver(self, selector: #selector(Application.willTerminate(_:)), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
        center.addObserver(self, selector: #selector(Application.sizeCategoryDidChange(_:)), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    }

    deinit {
        let center: NotificationCenter = NotificationCenter.default
        center.removeObserver(self)
    }

    @objc
    func didChangeStatusBarFrame(_ notification: Foundation.Notification) {
        postNotification(Notifications.DidChangeStatusBarFrame, value: self)
    }

    @objc
    func didChangeStatusBarOrientation(_ notification: Foundation.Notification) {
        if let orientationInt = notification.userInfo?[UIApplicationStatusBarOrientationUserInfoKey] as? Int,
            let orientation = UIInterfaceOrientation(rawValue: orientationInt) {
            postNotification(Notifications.DidChangeStatusBarOrientation, value: orientation)
        }
    }

    @objc
    func didEnterBackground(_ notification: Foundation.Notification) {
        postNotification(Notifications.DidEnterBackground, value: self)
    }

    @objc
    func didFinishLaunching(_ notification: Foundation.Notification) {
        postNotification(Notifications.DidFinishLaunching, value: self)
    }

    @objc
    func didReceiveMemoryWarning(_ notification: Foundation.Notification) {
        postNotification(Notifications.DidReceiveMemoryWarning, value: self)
    }

    @objc
    func protectedDataDidBecomeAvailable(_ notification: Foundation.Notification) {
        postNotification(Notifications.ProtectedDataDidBecomeAvailable, value: self)
    }

    @objc
    func protectedDataWillBecomeUnavailable(_ notification: Foundation.Notification) {
        postNotification(Notifications.ProtectedDataWillBecomeUnavailable, value: self)
    }

    @objc
    func significantTimeChange(_ notification: Foundation.Notification) {
        postNotification(Notifications.SignificantTimeChange, value: self)
    }

    @objc
    func userDidTakeScreenshot(_ notification: Foundation.Notification) {
        postNotification(Notifications.UserDidTakeScreenshot, value: self)
    }

    @objc
    func willChangeStatusBarOrientation(_ notification: Foundation.Notification) {
        postNotification(Notifications.WillChangeStatusBarOrientation, value: self)
    }

    @objc
    func willChangeStatusBarFrame(_ notification: Foundation.Notification) {
        postNotification(Notifications.WillChangeStatusBarFrame, value: self)
    }

    @objc
    func willEnterForeground(_ notification: Foundation.Notification) {
        postNotification(Notifications.WillEnterForeground, value: self)
    }

    @objc
    func willResignActive(_ notification: Foundation.Notification) {
        postNotification(Notifications.WillResignActive, value: self)
    }

    @objc
    func willTerminate(_ notification: Foundation.Notification) {
        postNotification(Notifications.WillTerminate, value: self)
    }

    @objc
    func sizeCategoryDidChange(_ notification: Foundation.Notification) {
        postNotification(Notifications.SizeCategoryDidChange, value: self)
    }
}
