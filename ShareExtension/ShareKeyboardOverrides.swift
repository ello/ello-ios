////
///  ShareKeyboardOverrides.swift
//

import Foundation
import UIKit

extension Keyboard {

    // App extensions do not have access to
    // UIApplication.sharedApplication, override
    // these two methods and remove sharedApplication
    // references in ShareExtension

    @objc
    func willShow(_ notification : Foundation.Notification) {
        active = true
        setFromNotification(notification)
        endFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        postNotification(Notifications.KeyboardWillShow, value: self)
    }

    @objc
    func willHide(_ notification : Foundation.Notification) {
        setFromNotification(notification)
        postNotification(Notifications.KeyboardWillHide, value: self)
    }
}

