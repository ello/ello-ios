////
///  KeyboardWindowExtension.swift
//

import Foundation
import UIKit

extension Keyboard {
    @objc
    func willShow(_ notification: Foundation.Notification) {
        active = true
        setFromNotification(notification)
        endFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let window = UIWindow.mainWindow
        bottomInset = window.frame.size.height - endFrame.origin.y
        external = endFrame.size.height > bottomInset

        postNotification(Notifications.KeyboardWillShow, value: self)
    }

    @objc
    func willHide(_ notification: Foundation.Notification) {
        setFromNotification(notification)
        endFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        bottomInset = 0

        let windowBottom = UIWindow.mainWindow.frame.size.height
        if endFrame.origin.y >= windowBottom {
            active = false
            external = false
        }
        else {
            external = true
        }

        postNotification(Notifications.KeyboardWillHide, value: self)
    }
}
