////
///  NotificationBanner.swift
//

import CRToast

struct NotificationBanner {
    static func displayAlert(payload: PushPayload) {
        configureDefaultsWith(payload: payload)
        CRToastManager.showNotification(withMessage: payload.message) { }
    }

    static func displayAlert(message: String) {
        configureDefaults()
        CRToastManager.showNotification(withMessage: message) { }
    }
}

private extension NotificationBanner {
    static func configureDefaults() {
        CRToastManager.setDefaultOptions(
            [
                kCRToastTimeIntervalKey: 4,
                kCRToastNotificationTypeKey: CRToastType.navigationBar.rawValue,
                kCRToastNotificationPresentationTypeKey: CRToastPresentationType.cover.rawValue,

                kCRToastTextColorKey: UIColor.white,
                kCRToastBackgroundColorKey: UIColor.black,

                kCRToastAnimationOutDirectionKey: CRToastAnimationDirection.top.rawValue,

                kCRToastAnimationInTimeIntervalKey: DefaultAnimationDuration,
                kCRToastAnimationOutTimeIntervalKey: DefaultAnimationDuration,

                kCRToastFontKey: UIFont.defaultFont(),
                kCRToastTextAlignmentKey: NSTextAlignment.left.rawValue,
                kCRToastTextMaxNumberOfLinesKey: 2,
            ]
        )
    }

    static func configureDefaultsWith(payload: PushPayload) {
        configureDefaults()

        let interactionResponder = CRToastInteractionResponder(interactionType: CRToastInteractionType.tap, automaticallyDismiss: true) { _ in
            postNotification(PushNotificationNotifications.interactedWithPushNotification, value: payload)
        }

        let dismissResponder = CRToastInteractionResponder(interactionType: CRToastInteractionType.swipe, automaticallyDismiss: true) { _ in
        }

        CRToastManager.setDefaultOptions(
            [
                kCRToastInteractionRespondersKey: [interactionResponder, dismissResponder],
            ]
        )
    }
}
