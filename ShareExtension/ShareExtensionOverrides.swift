////
///  ShareExtensionOverrides.swift
//

extension Keyboard {

    // App extensions do not have access to
    // UIApplication.sharedApplication, override
    // these two methods and remove sharedApplication
    // references in ShareExtension

    @objc
    func willShow(_ notification : Foundation.Notification) {
        isActive = true
        setFromNotification(notification)
        endFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        postNotification(Notifications.KeyboardWillShow, value: self)
    }

    @objc
    func willHide(_ notification : Foundation.Notification) {
        isActive = false
        setFromNotification(notification)
        postNotification(Notifications.KeyboardWillHide, value: self)
    }
}


extension AlertViewController {
    // do not reference anything in the Keyboard
    // App Extensions are prohibited from using
    // some APIs
    func keyboardUpdateFrame(_ keyboard: Keyboard) {
    }
}


extension Tracker {
}
