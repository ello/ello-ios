////
///  AppDelegate.swift
//

import Keys
import TimeAgoInWords
import PINRemoteImage
import PINCache
import ElloUIFonts
import Quantcast_Measure


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    static var restrictRotation = true

    var window: UIWindow?
    var windowSizeChangedNotification: NotificationObserver?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let debugServer = DebugServer.fromDefaults {
            APIKeys.shared = debugServer.apiKeys
        }

        #if DEBUG
        NSSetUncaughtExceptionHandler { exception in
            print(exception)
            for sym in exception.callStackSymbols {
                print(sym)
            }
        }

        Tracker.shared.overrideAgent = NullAgent()
        #endif

        Keyboard.setup()
        AutoCompleteService.loadEmojiJSON("emojis")
        BadgesService.loadStaticBadges()
        UIFont.loadFonts()
        ElloLinkedStore.shared.writeConnection.readWrite { transaction in
            transaction.removeAllObjectsInAllCollections()
        }

        if Globals.isTesting {
            if UIScreen.main.scale > 2 {
                fatalError("Tests should be run in a @2x retina device (for snapshot specs to work)")
            }

            if Bundle.main.bundleIdentifier != "co.ello.ElloDev" {
                fatalError("Tests should be run with a bundle id of co.ello.ElloDev")
            }
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.rootViewController = UIViewController()
            window.makeKeyAndVisible()
            self.window = window
            return true
        }

        let window = UIWindow(frame: UIScreen.main.bounds)
        let appController = AppViewController()
        window.rootViewController = appController
        window.makeKeyAndVisible()
        self.window = window
        Globals.windowSize = window.frame.size

        setupGlobalStyles()
        setupCaches()
        checkAppStorage()

        if let payload = launchOptions?[.remoteNotification] as? [String: Any] {
            PushNotificationController.shared.receivedNotification(application, action: nil, userInfo: payload)
        }

        Tracker.shared.sessionStarted()

        windowSizeChangedNotification = NotificationObserver(notification: Application.Notifications.WindowSizeWillChange) { size in
            Globals.windowSize = size
        }

        return true
    }

    func setupGlobalStyles() {
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.greyA,
            .font: UIFont.defaultFont(12),
        ]
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .highlighted)

        // Kill all the tildes
        TimeAgoInWordsStrings.updateStrings(["about": ""])
    }

    func setupCaches() {
        let manager = PINRemoteImageManager.shared()
        let diskAgeLimit: TimeInterval = 1_209_600
        let diskByteLimit: UInt = 250_000_000
        let memoryByteLimit: UInt = 10_000_000
        manager.pinCache?.diskCache.ageLimit = diskAgeLimit
        manager.pinCache?.diskCache.byteLimit = diskByteLimit
        manager.pinCache?.memoryCache.costLimit = memoryByteLimit
        _ = CategoryService().loadCategories()
    }

    func checkAppStorage() {
        clearCaches()

        let killDate = Date(timeIntervalSince1970: 1516655690) // jan 22, 2018
        let (text, size) = Tmp.sizeDiagnostics()
        guard Globals.now < killDate, size > 300_000_000 else { return }

        S3UploadingService(endpoint: .amazonLoggingCredentials)
            .upload(text, filename: "appsize.txt")
            .ignoreErrors()
    }

    func clearCaches() {
        Tmp.clear()
        URLCache.shared.removeAllCachedResponses()
        TemporaryCache.clear()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        clearCaches()

        let manager = PINRemoteImageManager.shared()
        manager.pinCache?.diskCache.trim(toSize: 0)
        PINDiskCache.shared.trim(toSize: 0)

        Tracker.shared.sessionEnded()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        Tracker.shared.sessionStarted()
    }

}

// MARK: Notifications
extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PushNotificationController.shared.updateToken(deviceToken)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        PushNotificationController.shared.receivedNotification(application, action: nil, userInfo: userInfo)
        completionHandler(.noData)
    }

    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}

extension AppDelegate {
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        guard
            let appVC = window?.rootViewController as? AppViewController
        else {
            return true
        }

        appVC.navigateToDeepLink(url.absoluteString)
        return true
    }
}

extension AppDelegate {

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            if AppDelegate.restrictRotation {
                return .portrait
            }
            return .allButUpsideDown
        }
        return .all
    }
}

// universal links
extension AppDelegate {
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        guard
            let webpageURL = userActivity.webpageURL,
            let appVC = window?.rootViewController as? AppViewController,
            userActivity.activityType == NSUserActivityTypeBrowsingWeb
        else { return false }


        appVC.navigateToDeepLink(webpageURL.absoluteString)
        return true
    }
}
