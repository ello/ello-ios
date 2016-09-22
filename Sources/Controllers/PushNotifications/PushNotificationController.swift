////
///  PushNotificationController.swift
//

import SwiftyUserDefaults
import UserNotifications


private let NeedsPermissionKey = "PushNotificationNeedsPermission"
private let DeniedPermissionKey = "PushNotificationDeniedPermission"

public struct PushNotificationNotifications {
    static let interactedWithPushNotification = TypedNotification<PushPayload>(name: "com.Ello.PushNotification.Interaction")
    static let receivedPushNotification = TypedNotification<PushPayload>(name: "com.Ello.PushNotification.Received")
}

public class PushNotificationController: NSObject {
    public static let sharedController = PushNotificationController(defaults: GroupDefaults, keychain: ElloKeychain())

    private let defaults: NSUserDefaults
    private var keychain: KeychainType

    public var needsPermission: Bool {
        get { return defaults[NeedsPermissionKey].bool ?? true }
        set { defaults[NeedsPermissionKey] = newValue }
    }

    public var permissionDenied: Bool {
        get { return defaults[DeniedPermissionKey].bool ?? false }
        set { defaults[DeniedPermissionKey] = newValue }
    }

    public init(defaults: NSUserDefaults, keychain: KeychainType) {
        self.defaults = defaults
        self.keychain = keychain
    }
}

extension PushNotificationController: UNUserNotificationCenterDelegate {

    // foreground - notification incoming while using the app
    @objc @available(iOS 10.0, *)
    public func userNotificationCenter(center: UNUserNotificationCenter, willPresentNotification notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        receivedNotification(UIApplication.sharedApplication(), userInfo: notification.request.content.userInfo)
        completionHandler(UNNotificationPresentationOptions.Sound)
    }

    // background - user interacted with notification outside of the app
    @objc @available(iOS 10.0, *)
    public func userNotificationCenter(center: UNUserNotificationCenter, didReceiveNotificationResponse response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {

        receivedNotification(UIApplication.sharedApplication(), userInfo: response.notification.request.content.userInfo)

        completionHandler()
    }
}

public extension PushNotificationController {
    func requestPushAccessIfNeeded() -> AlertViewController? {
        guard AuthToken().isPasswordBased else { return .None }
        guard !permissionDenied else { return .None }

        guard !needsPermission else { return alertViewController() }

        registerForRemoteNotifications()
        return .None
    }

    func registerForRemoteNotifications() {
        self.needsPermission = false
        registerStoredToken()
        let app = UIApplication.sharedApplication()

        if #available(iOS 10.0, *){
            let userNC = UNUserNotificationCenter.currentNotificationCenter()
            userNC.delegate = self
            userNC.requestAuthorizationWithOptions([.Badge, .Sound, .Alert]) {
                (granted, _) in
                if granted {
                    app.registerForRemoteNotifications()
                }
            }
        }

        else { //If user is not on iOS 10 use the old methods we've been using
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: .None)
            app.registerUserNotificationSettings(settings)
            app.registerForRemoteNotifications()
        }
    }

    func updateToken(token: NSData) {
        keychain.pushToken = token
        ProfileService().updateUserDeviceToken(token)
    }

    func registerStoredToken() {
        if let token = keychain.pushToken {
            ProfileService().updateUserDeviceToken(token)
        }
    }

    func deregisterStoredToken() {
        if let token = keychain.pushToken {
            ProfileService().removeUserDeviceToken(token)
        }
    }

    func receivedNotification(application: UIApplication, userInfo: [NSObject: AnyObject]) {
        updateBadgeCount(userInfo)
        if !hasAlert(userInfo) { return }

        let payload = PushPayload(info: userInfo as! [String: AnyObject])
        switch application.applicationState {
        case .Active:
            NotificationBanner.displayAlertForPayload(payload)
        default:
            postNotification(PushNotificationNotifications.interactedWithPushNotification, value: payload)
        }
    }

    func updateBadgeCount(userInfo: [NSObject: AnyObject]) {
        if let aps = userInfo["aps"] as? [NSObject: AnyObject],
            badges = aps["badge"] as? Int
        {
            updateBadgeNumber(badges)
        }
    }

    func updateBadgeNumber(badges: Int) {
        UIApplication.sharedApplication().applicationIconBadgeNumber = badges
    }

    func hasAlert(userInfo: [NSObject: AnyObject]) -> Bool {
        if let aps = userInfo["aps"] as? [NSObject: AnyObject]
            where aps["alert"] is [NSObject: AnyObject]
        {
            return true
        }
        else {
            return false
        }
    }
}

private extension PushNotificationController {
    func alertViewController() -> AlertViewController {
        let alert = AlertViewController(message: InterfaceString.PushNotifications.PermissionPrompt)
        alert.dismissable = false

        let allowAction = AlertAction(title: InterfaceString.PushNotifications.PermissionYes, style: .Dark) { _ in
            self.registerForRemoteNotifications()
        }
        alert.addAction(allowAction)

        let disallowAction = AlertAction(title: InterfaceString.PushNotifications.PermissionNo, style: .Light) { _ in
            self.needsPermission = false
            self.permissionDenied = true
        }
        alert.addAction(disallowAction)
        return alert
    }
}
