////
///  Notifications.swift
//

struct AuthenticationNotifications {
    static let userLoggedOut = TypedNotification<()>(name: "UserElloLoggedOutNotification")
    static let invalidToken = TypedNotification<Bool>(name: "ElloInvalidTokenNotification")
}
