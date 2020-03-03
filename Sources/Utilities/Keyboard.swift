////
///  Keyboard.swift
//

class Keyboard {
    struct Notifications {
        static let KeyboardWillShow = TypedNotification<Keyboard>(
            name: "com.Ello.Keyboard.KeyboardWillShow"
        )
        static let KeyboardDidShow = TypedNotification<Keyboard>(
            name: "com.Ello.Keyboard.KeyboardDidShow"
        )
        static let KeyboardWillHide = TypedNotification<Keyboard>(
            name: "com.Ello.Keyboard.KeyboardWillHide"
        )
        static let KeyboardDidHide = TypedNotification<Keyboard>(
            name: "com.Ello.Keyboard.KeyboardDidHide"
        )
    }

    static let shared = Keyboard()

    class func setup() {
        _ = shared
    }

    var isActive = false
    var isExternal = false
    var isAdjusting = false
    var bottomInset: CGFloat = 0.0
    var endFrame: CGRect = .zero
    var curve = UIView.AnimationCurve.linear
    var options = UIView.AnimationOptions.curveLinear
    var duration: Double = 0.0

    init() {
        let center: NotificationCenter = NotificationCenter.default
        center.addObserver(
            self,
            selector: #selector(Keyboard.willShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        center.addObserver(
            self,
            selector: #selector(Keyboard.didShow(_:)),
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )
        center.addObserver(
            self,
            selector: #selector(Keyboard.willHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        center.addObserver(
            self,
            selector: #selector(Keyboard.didHide(_:)),
            name: UIResponder.keyboardDidHideNotification,
            object: nil
        )
    }

    deinit {
        let center: NotificationCenter = NotificationCenter.default
        center.removeObserver(self)
    }

    func keyboardBottomInset(inView: UIView) -> CGFloat {
        let window: UIView = inView.window ?? inView
        let bottom = window.convert(
            CGPoint(x: 0, y: window.bounds.size.height - bottomInset),
            to: inView.superview
        ).y
        let inset = inView.frame.size.height - bottom
        if inset < 0 {
            return 0
        }
        else {
            return inset
        }
    }

    @objc
    func didShow(_ notification: Foundation.Notification) {
        isAdjusting = false
        postNotification(Notifications.KeyboardDidShow, value: self)
    }

    @objc
    func didHide(_ notification: Foundation.Notification) {
        postNotification(Notifications.KeyboardDidHide, value: self)
    }

    func setFromNotification(_ notification: Foundation.Notification) {
        if let durationValue =
            notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
        {
            duration = durationValue.doubleValue
        }
        else {
            duration = 0
        }

        if let rawCurveValue = (
            notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        ) {
            let rawCurve = rawCurveValue.intValue
            curve = UIView.AnimationCurve(rawValue: rawCurve) ?? .easeOut
            let curveInt = UInt(rawCurve << 16)
            options = UIView.AnimationOptions(rawValue: curveInt)
        }
        else {
            curve = .easeOut
            options = .curveEaseOut
        }
    }

}
