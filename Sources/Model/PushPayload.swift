////
///  PushPayload.swift
//

struct PushPayload {
    let info: [String: AnyObject]

    var applicationTarget: String {
        return info["application_target"] as? String ?? ""
    }

    var message: String {
        let aps = info["aps"] as? [String: AnyObject]
        let alert = aps?["alert"] as? [String: String]
        return alert?["body"] ?? "New Notification"
    }
}

// {"application_target": "notifications/posts/6178""aps": {"alert": {"body": "Hello, Ello!"}}}
// PushNotificationController.sharedController.receivedNotification(UIApplication.sharedApplication(), userInfo: ["application_target": "notifications/posts/6178", "aps": ["alert": ["body": "Hello, Ello!"]]])
