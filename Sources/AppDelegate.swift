////
///  AppDelegate.swift
//

import Crashlytics
import Keys
import TimeAgoInWords
import PINRemoteImage
import PINCache
import ElloUIFonts


@UIApplicationMain
public class AppDelegate: UIResponder, UIApplicationDelegate {

    public static var restrictRotation = true

    public var window: UIWindow?

    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Keyboard.setup()
        Rate.sharedRate.setup()
        AutoCompleteService.loadEmojiJSON("emojis")
        UIFont.loadFonts()

        if AppSetup.sharedState.isTesting {
            if UIScreen.mainScreen().scale > 2 {
                fatalError("Tests should be run in a @2x retina device (for snapshot specs to work)")
            }

            if NSBundle.mainBundle().bundleIdentifier != "co.ello.ElloDev" {
                fatalError("Tests should be run with a bundle id of co.ello.ElloDev")
            }
            let window = UIWindow(frame: UIScreen.mainScreen().bounds)
            window.rootViewController = UIViewController()
            window.makeKeyAndVisible()
            self.window = window
            return true
        }

        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window.rootViewController = AppViewController()
        window.makeKeyAndVisible()
        self.window = window

        UIApplication.sharedApplication().statusBarStyle = .LightContent

        setupGlobalStyles()
        setupCaches()
        if !AppSetup.sharedState.isSimulator && !AppSetup.sharedState.isTesting {
            inBackground {
                Crashlytics.startWithAPIKey(ElloKeys().crashlyticsKey())
            }
        }

        if let payload = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [String: AnyObject] {
            log("notification received \(NSDate())", message: payload)
            PushNotificationController.sharedController.receivedNotification(application, userInfo: payload)
        }

        return true
    }

    func setupGlobalStyles() {
        let font = UIFont.defaultFont()
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.greyA()]
        UINavigationBar.appearance().barTintColor = UIColor.whiteColor()

        let attributes = [
            NSForegroundColorAttributeName: UIColor.greyA(),
            NSFontAttributeName: UIFont.defaultFont(12),
        ]
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, forState: .Normal)

        let normalTitleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.blackColor(),
            NSFontAttributeName: UIFont.defaultFont(11.0)
        ]
        let selectedTitleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont.defaultFont(11.0)
        ]
        UISegmentedControl.appearance().setTitleTextAttributes(normalTitleTextAttributes, forState: .Normal)
        UISegmentedControl.appearance().setTitleTextAttributes(selectedTitleTextAttributes, forState: .Selected)
        UISegmentedControl.appearance().setBackgroundImage(UIImage.imageWithColor(UIColor.whiteColor()), forState: .Normal, barMetrics: .Default)
        UISegmentedControl.appearance().setBackgroundImage(UIImage.imageWithColor(UIColor.blackColor()), forState: .Selected, barMetrics: .Default)

        // Kill all the tildes
        TimeAgoInWordsStrings.updateStrings(["about": ""])
    }

    func setupCaches() {
        let manager = PINRemoteImageManager.sharedImageManager()
        let twoWeeks: NSTimeInterval = 1209600
        let twoHundredFiftyMegaBytes: UInt = 250000000
        manager.cache.diskCache.byteLimit = twoHundredFiftyMegaBytes
        manager.cache.diskCache.ageLimit = twoWeeks

        CategoryService().loadCategories({ _ in })
    }

    public func applicationDidEnterBackground(application: UIApplication) {
        Tracker.sharedTracker.sessionEnded()
    }

    public func applicationWillEnterForeground(application: UIApplication) {
        Tracker.sharedTracker.sessionStarted()
    }

}

// MARK: Notifications
extension AppDelegate {
    public func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        PushNotificationController.sharedController.updateToken(deviceToken)
    }

    public func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject: AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        log("notification received \(NSDate())", message: userInfo)
        PushNotificationController.sharedController.receivedNotification(application, userInfo: userInfo)
        completionHandler(.NoData)
    }
}

// MARK: URLs
extension AppDelegate {
    public func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        guard let
            appVC = window?.rootViewController as? AppViewController,
            urlString = url.absoluteString
        else {
            return true
        }

        appVC.navigateToDeepLink(urlString)
        return true
    }
}

extension AppDelegate {

    public func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            if AppDelegate.restrictRotation {
                return .Portrait
            }
            return .AllButUpsideDown
        }
        return .All
    }
}


// universal links
extension AppDelegate {
    public func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        guard let
            webpageURL = userActivity.webpageURL,
            appVC = window?.rootViewController as? AppViewController,
            webpage = webpageURL.absoluteString
        where userActivity.activityType == NSUserActivityTypeBrowsingWeb
        else { return false }


        appVC.navigateToDeepLink(webpage)
        return true
    }
}
