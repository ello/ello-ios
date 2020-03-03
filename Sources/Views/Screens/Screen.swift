////
///  Screen.swift
//

import SnapKit


// Easy keyboard views: pin an anchor to `keyboardAnchor.top`. It'll animate
// automatically, too.
class Screen: UIView {
    let keyboardAnchor = UIView()
    private var keyboardTopConstraint: Constraint!
    private var keyboardWillShowObserver: NotificationObserver?
    private var keyboardWillHideObserver: NotificationObserver?

    convenience init() {
        self.init(frame: UIScreen.main.bounds)
    }

    required override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(keyboardAnchor)
        backgroundColor = .white

        keyboardInit()
        setup()
        style()
        bindActions()
        setText()
        arrange()
        if frame.width > 0 && frame.height > 0 {
            layoutIfNeeded()
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        keyboardInit()
        setup()
        style()
        bindActions()
        setText()
        arrange()
        if frame.width > 0 && frame.height > 0 {
            layoutIfNeeded()
        }
    }

    deinit {
        teardownKeyboardObservers()
    }

    override func traitCollectionDidChange(_ prev: UITraitCollection?) {
        super.traitCollectionDidChange(prev)
        style()
    }

    func setup() {}
    func style() {}
    func bindActions() {}
    func setText() {}
    func arrange() {}

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)

        if newWindow != nil && window == nil {
            setupKeyboardObservers()
            keyboardWillChange(Keyboard.shared, animated: false)
        }
        else if newWindow == nil && window != nil {
            teardownKeyboardObservers()
        }
    }

    private func setupKeyboardObservers() {
        keyboardWillShowObserver = NotificationObserver(
            notification: Keyboard.Notifications.KeyboardWillShow,
            block: keyboardWillChangeAnimated
        )
        keyboardWillHideObserver = NotificationObserver(
            notification: Keyboard.Notifications.KeyboardWillHide,
            block: keyboardWillChangeAnimated
        )
    }

    private func teardownKeyboardObservers() {
        keyboardWillShowObserver?.removeObserver()
        keyboardWillHideObserver?.removeObserver()
        keyboardWillShowObserver = nil
        keyboardWillHideObserver = nil
    }

    func keyboardWillChangeAnimated(_ keyboard: Keyboard) {
        keyboardWillChange(keyboard, animated: true)
    }

    func keyboardWillChange(_ keyboard: Keyboard, animated: Bool) {
        let bottomInset = keyboard.keyboardBottomInset(inView: self)
        elloAnimate(duration: keyboard.duration, options: keyboard.options, animated: animated) {
            self.keyboardTopConstraint.update(offset: -bottomInset)
            self.keyboardIsAnimating(keyboard)
            self.layoutIfNeeded()
        }
    }

    func keyboardIsAnimating(_ keyboard: Keyboard) {}

    private func keyboardInit() {
        keyboardAnchor.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(self)
            keyboardTopConstraint =
                make.top.equalTo(self.snp.bottom).priority(Priority.required).constraint
        }
    }
}
