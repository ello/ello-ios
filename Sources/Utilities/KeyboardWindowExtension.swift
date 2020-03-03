////
///  KeyboardWindowExtension.swift
//

extension Keyboard {
    @objc
    func willShow(_ notification: Foundation.Notification) {
        isActive = true
        isAdjusting = bottomInset > 0

        setFromNotification(notification)
        endFrame =
            (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue)
            .cgRectValue
        let window = UIWindow.mainWindow
        bottomInset = window.frame.size.height - endFrame.origin.y
        isExternal = endFrame.size.height > bottomInset

        postNotification(Notifications.KeyboardWillShow, value: self)
    }

    @objc
    func willHide(_ notification: Foundation.Notification) {
        setFromNotification(notification)
        endFrame =
            (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue)
            .cgRectValue
        bottomInset = 0
        isAdjusting = false

        let windowBottom = UIWindow.mainWindow.frame.size.height
        if endFrame.origin.y >= windowBottom {
            isActive = false
            isExternal = false
        }
        else {
            isExternal = true
        }

        postNotification(Notifications.KeyboardWillHide, value: self)
    }
}
