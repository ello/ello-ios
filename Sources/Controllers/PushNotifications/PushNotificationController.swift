////
///  PushNotificationController.swift
//

import SwiftyUserDefaults
import UserNotifications


private let NeedsPermissionKey = "PushNotificationNeedsPermission"
private let DeniedPermissionKey = "PushNotificationDeniedPermission"

struct PushNotificationNotifications {
    static let interactedWithPushNotification = TypedNotification<PushPayload>(name: "com.Ello.PushNotification.Interaction")
    static let receivedPushNotification = TypedNotification<PushPayload>(name: "com.Ello.PushNotification.Received")
}

struct PushActions {
    static let postCategory = "co.ello.POST_CATEGORY"
    static let commentCategory = "co.ello.COMMENT_CATEGORY"
    static let userCategory = "co.ello.USER_CATEGORY"
    static let userMessageCategory = "co.ello.USER_MESSAGE_CATEGORY"
    static let artistInviteSubmissionCategory = "co.ello.ARTIST_INVITE_SUBMISSION_CATEGORY"

    static let followUser = "co.ello.FOLLOW_USER_ACTION"
    static let lovePost = "co.ello.LOVE_POST_ACTION"
    static let postComment = "co.ello.POST_COMMENT_ACTION"
    static let commentReply = "co.ello.COMMENT_REPLY_ACTION"
    static let messageUser = "co.ello.MESSAGE_USER_ACTION"
    static let view = "co.ello.VIEW_ACTION"

    static let userInputKey = "co.ello.PushActions.TextInput"
}

class PushNotificationController: NSObject {
    static let shared = PushNotificationController(defaults: GroupDefaults, keychain: ElloKeychain())

    private let defaults: UserDefaults
    private var keychain: KeychainType

    var needsPermission: Bool {
        get { return defaults[NeedsPermissionKey].bool ?? true }
        set { defaults[NeedsPermissionKey] = newValue }
    }

    var permissionDenied: Bool {
        get { return defaults[DeniedPermissionKey].bool ?? false }
        set { defaults[DeniedPermissionKey] = newValue }
    }

    init(defaults: UserDefaults, keychain: KeychainType) {
        self.defaults = defaults
        self.keychain = keychain
    }
}

extension PushNotificationController: UNUserNotificationCenterDelegate {

    // foreground - notification incoming while using the app
    @objc @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        receivedNotification(UIApplication.shared, action: nil, userInfo: notification.request.content.userInfo)
        completionHandler(UNNotificationPresentationOptions.sound)
    }

    // background - user interacted with notification outside of the app
    @objc @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        var userInfo = response.notification.request.content.userInfo
        if let response = response as? UNTextInputNotificationResponse {
            userInfo[PushActions.userInputKey] = response.userText
        }
        receivedNotification(UIApplication.shared, action: response.actionIdentifier, userInfo: userInfo)
        completionHandler()
    }
}

extension PushNotificationController {
    func requestPushAccessIfNeeded(_ vc: UIViewController) {
        guard AuthToken().isPasswordBased else { return }
        guard !permissionDenied else { return }

        guard !needsPermission else {
            vc.present(alertViewController(), animated: true, completion: nil)
            return
        }

        registerForRemoteNotifications()
        return
    }

    func registerForRemoteNotifications() {
        self.needsPermission = false
        registerStoredToken()
        let app = UIApplication.shared

        if #available(iOS 10.0, *){
            let replyAction = UNTextInputNotificationAction(identifier: PushActions.commentReply, title: InterfaceString.PushNotifications.CommentReply, options: [.authenticationRequired, .foreground], textInputButtonTitle: InterfaceString.Send, textInputPlaceholder: "")
            let messageAction = UNTextInputNotificationAction(identifier: PushActions.messageUser, title: InterfaceString.PushNotifications.MessageUser, options: [.authenticationRequired, .foreground], textInputButtonTitle: InterfaceString.Send, textInputPlaceholder: "")
            let commentAction = UNTextInputNotificationAction(identifier: PushActions.postComment, title: InterfaceString.PushNotifications.PostComment, options: [.authenticationRequired, .foreground], textInputButtonTitle: InterfaceString.Send, textInputPlaceholder: "")
            let loveAction = UNNotificationAction(identifier: PushActions.lovePost, title: InterfaceString.PushNotifications.LovePost, options: [.authenticationRequired])
            let followAction = UNNotificationAction(identifier: PushActions.followUser, title: InterfaceString.PushNotifications.FollowUser, options: [.authenticationRequired])
            let viewAction = UNNotificationAction(identifier: PushActions.view, title: InterfaceString.PushNotifications.View, options: [.authenticationRequired, .foreground])

            let postCategory = UNNotificationCategory(identifier: PushActions.postCategory, actions: [loveAction, commentAction, viewAction], intentIdentifiers: [], options: [])
            let commentCategory = UNNotificationCategory(identifier: PushActions.commentCategory, actions: [replyAction, viewAction], intentIdentifiers: [], options: [])
            let userCategory = UNNotificationCategory(identifier: PushActions.userCategory, actions: [followAction, messageAction, viewAction], intentIdentifiers: [], options: [])
            let userMessageCategory = UNNotificationCategory(identifier: PushActions.userMessageCategory, actions: [messageAction, viewAction], intentIdentifiers: [], options: [])

            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.setNotificationCategories([postCategory, commentCategory, userCategory, userMessageCategory])
            center.requestAuthorization(options: [.badge, .sound, .alert]) { granted, _ in
                if granted {
                    nextTick(app.registerForRemoteNotifications)
                }
            }
        }
        else { //If user is not on iOS 10 use the old methods we've been using
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: [])
            app.registerUserNotificationSettings(settings)
            app.registerForRemoteNotifications()
        }
    }

    func updateToken(_ token: Data) {
        keychain.pushToken = token
        ProfileService().updateUserDeviceToken(token).ignoreErrors()
    }

    func registerStoredToken() {
        if let token = keychain.pushToken {
            ProfileService().updateUserDeviceToken(token).ignoreErrors()
        }
    }

    func deregisterStoredToken() {
        if let token = keychain.pushToken {
            ProfileService().removeUserDeviceToken(token).ignoreErrors()
        }
    }

    func receivedNotification(_ application: UIApplication, action: String?, userInfo: [AnyHashable: Any]) {
        updateBadgeCount(userInfo)
        if !hasAlert(userInfo) { return }

        let payload = PushPayload(info: userInfo as! [String: Any])
        if application.applicationState == .active {
            NotificationBanner.displayAlert(payload: payload)
        }
        else {
            let (type, data) = ElloURI.match(payload.applicationTarget)

            var shouldInteract = true
            switch action ?? PushActions.view {
            case PushActions.postComment, PushActions.commentReply:
                if let text = userInfo[PushActions.userInputKey] as? String, let postId = data {
                    actionPostComment(postId: postId, text: text, payload: payload)
                    shouldInteract = false
                }
            case PushActions.messageUser:
                guard let text = userInfo[PushActions.userInputKey] as? String else { return }

                if case .pushNotificationUser = type, let userId = data {
                    actionMessageUser(userId: userId, text: text, payload: payload)
                    shouldInteract = false
                }
            case PushActions.followUser:
                if case .pushNotificationUser = type, let userId = data {
                    actionFollowUser(userId: userId, payload: payload)
                    shouldInteract = false
                }
            case PushActions.lovePost:
                if type == .pushNotificationPost || type == .pushNotificationComment, let postId = data {
                    actionLovePost(postId: postId, payload: payload)
                    shouldInteract = false
                }
            default:
                break
            }

            if shouldInteract {
                postNotification(PushNotificationNotifications.interactedWithPushNotification, value: payload)
            }
        }
    }

    private func actionPostComment(postId: String, text: String, payload: PushPayload) {
        actionSendMessage(text: text, postEditingService: PostEditingService(parentPostId: postId), payload: payload)
    }

    private func actionMessageUser(userId: String, text: String, payload: PushPayload) {
        UserService().loadUser(.userStream(userParam: userId))
            .then { user -> Void in
                let postText: String
                if text =~ "\(user.atName)\\b" {
                    postText = text
                }
                else {
                    postText = "\(user.atName) \(text)"
                }
                self.actionSendMessage(text: postText, postEditingService: PostEditingService(), payload: payload)
            }
            .ignoreErrors()
    }

    private func actionSendMessage(text: String, postEditingService: PostEditingService, payload: PushPayload) {
        postEditingService.create(content: [.text(text)])
            .then { _ -> Void in
                let message: String
                if postEditingService.parentPostId == nil {
                    message = InterfaceString.Omnibar.CreatedPost
                }
                else {
                    message = InterfaceString.Omnibar.CreatedComment
                }
                NotificationBanner.displayAlert(message: message)
                postNotification(HapticFeedbackNotifications.successfulUserEvent, value: ())
                postNotification(PushNotificationNotifications.interactedWithPushNotification, value: payload)
            }
            .catch { _ in
                if postEditingService.parentPostId != nil {
                    NotificationBanner.displayAlert(message: InterfaceString.Omnibar.CannotComment)
                }
            }
            .ignoreErrors()
    }

    private func actionFollowUser(userId: String, payload: PushPayload) {
        let (_, promise) = RelationshipService().updateRelationship(userId: userId, relationshipPriority: .following)
        promise.always {
            postNotification(PushNotificationNotifications.interactedWithPushNotification, value: payload)
        }
    }

    private func actionLovePost(postId: String, payload: PushPayload) {
        LovesService().lovePost(postId: postId).always {
            postNotification(PushNotificationNotifications.interactedWithPushNotification, value: payload)
        }
    }

    func updateBadgeCount(_ userInfo: [AnyHashable: Any]) {
        guard
            let aps = userInfo["aps"] as? [AnyHashable: Any],
            let badges = aps["badge"] as? Int
        else { return  }

        updateBadgeNumber(badges)
    }

    func updateBadgeNumber(_ badges: Int) {
        UIApplication.shared.applicationIconBadgeNumber = badges
    }

    func hasAlert(_ userInfo: [AnyHashable: Any]) -> Bool {
        let aps = userInfo["aps"] as? [AnyHashable: Any]
        return aps?["alert"] is [NSObject: Any]
    }
}

private extension PushNotificationController {
    func alertViewController() -> AlertViewController {
        let alert = AlertViewController(message: InterfaceString.PushNotifications.PermissionPrompt)
        alert.isDismissable = false

        let allowAction = AlertAction(title: InterfaceString.PushNotifications.PermissionYes, style: .dark) { _ in
            self.registerForRemoteNotifications()
        }
        alert.addAction(allowAction)

        let disallowAction = AlertAction(title: InterfaceString.PushNotifications.PermissionNo, style: .light) { _ in
            self.needsPermission = false
            self.permissionDenied = true
        }
        alert.addAction(disallowAction)
        return alert
    }
}
