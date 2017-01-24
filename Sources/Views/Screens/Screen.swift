////
///  Screen.swift
//

import SnapKit


/// Easy keyboard views: pin an anchor to `keyboardAnchor.top`. It'll animate automatically, too.
class Screen: UIView {
    let keyboardAnchor = UIView()
    fileprivate var keyboardTopConstraint: Constraint!
    fileprivate var keyboardWillShowObserver: NotificationObserver?
    fileprivate var keyboardWillHideObserver: NotificationObserver?

    convenience init() {
        self.init(frame: UIScreen.main.bounds)
    }

    required override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(keyboardAnchor)
        backgroundColor = .white

        screenInit()
        style()
        bindActions()
        setText()
        arrange()

        // for controllers that use "container" views, they need to be set to the correct dimensions,
        // otherwise there'll be constraint violations.
        layoutIfNeeded()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        teardownKeyboardObservers()
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)

        if newWindow != nil && window == nil {
            setupKeyboardObservers()
        }
        else if newWindow == nil && window != nil {
            teardownKeyboardObservers()
        }
    }

    fileprivate func setupKeyboardObservers() {
        keyboardWillShowObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillShow, block: keyboardWillChange)
        keyboardWillHideObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillHide, block: keyboardWillChange)
    }

    fileprivate func teardownKeyboardObservers() {
        keyboardWillShowObserver?.removeObserver()
        keyboardWillHideObserver?.removeObserver()
        keyboardWillShowObserver = nil
        keyboardWillHideObserver = nil
    }

    func keyboardWillChange(_ keyboard: Keyboard) {
        let bottomInset = keyboard.keyboardBottomInset(inView: self)
        animate(duration: keyboard.duration, options: keyboard.options, completion: { _ in self.keyboardDidAnimate() }) {
            self.keyboardTopConstraint.update(offset: -bottomInset)
            self.keyboardIsAnimating(keyboard)
            self.layoutIfNeeded()
        }
    }

    func keyboardIsAnimating(_ keyboard: Keyboard) {}
    func keyboardDidAnimate() {}

    func screenInit() {}
    func style() {}
    func bindActions() {}
    func setText() {}
    func arrange() {
        keyboardAnchor.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(self)
            keyboardTopConstraint = make.top.equalTo(self.snp.bottom).constraint
        }
    }
}
