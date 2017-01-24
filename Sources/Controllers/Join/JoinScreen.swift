////
///  JoinScreen.swift
//

import SnapKit


class JoinScreen: CredentialsScreen {
    struct Size {
        static let fieldsTopMargin: CGFloat = 55
        static let fieldsErrorMargin: CGFloat = 15
        static let fieldsInnerMargin: CGFloat = 30
        static let buttonHeight: CGFloat = 50
        static let buttonInset: CGFloat = 10
        static let termsFontSize: CGFloat = 11
        static let termsBottomInset: CGFloat = 5
    }

    weak var delegate: JoinDelegate?
    var emailValid: Bool? = nil {
        didSet {
            if let emailValid = emailValid {
                emailField.validationState = emailValid ? .okSmall : .error
                styleDiscoverButton()
            }
            else {
                emailField.validationState = .none
            }
        }
    }
    var email: String {
        get { return emailField.text?.trimmingCharacters(in: CharacterSet.whitespaces) ?? "" }
        set { emailField.text = newValue }
    }
    var usernameValid: Bool? = nil {
        didSet {
            if let usernameValid = usernameValid {
                usernameField.validationState = usernameValid ? .okSmall : .error
                styleDiscoverButton()
            }
            else {
                usernameField.validationState = .none
            }
        }
    }
    var username: String {
        get { return usernameField.text?.trimmingCharacters(in: CharacterSet.whitespaces) ?? "" }
        set { usernameField.text = newValue }
    }
    var passwordValid: Bool? = nil {
        didSet {
            if let passwordValid = passwordValid {
                passwordField.validationState = passwordValid ? .okSmall : .error
                styleDiscoverButton()
            }
            else {
                passwordField.validationState = .none
            }
        }
    }
    var password: String {
        get { return passwordField.text ?? "" }
        set { passwordField.text = newValue }
    }
    var onePasswordAvailable = false {
        didSet { passwordField.hasOnePassword = onePasswordAvailable }
    }

    let emailField = ClearTextField()
    let activateEmailButton = UIButton()
    let emailErrorLabel = StyledLabel(style: .SmallWhite)
    var emailMarginConstraint: Constraint!

    let usernameField = ClearTextField()
    let activateUsernameButton = UIButton()
    let usernameErrorLabel = StyledLabel(style: .SmallWhite)
    var usernameMarginConstraint: Constraint!

    let passwordField = ClearTextField()
    let activatePasswordButton = UIButton()
    let passwordErrorLabel = StyledLabel(style: .SmallWhite)
    var passwordMarginConstraint: Constraint!

    let messageLabel = StyledLabel(style: .SmallWhite)
    var messageMarginConstraint: Constraint!
    let termsButtonNormal = UIButton()
    let termsButtonKeyboard = UIButton()

    let discoverButton = StyledButton(style: .RoundedGray)
    let continueBackground = UIView()

    override func setText() {
        titleLabel.text = InterfaceString.Startup.SignUp
        discoverButton.setTitle(InterfaceString.Join.Discover, for: .normal)
    }

    override func bindActions() {
        super.bindActions()
        discoverButton.addTarget(self, action: #selector(submitAction), for: .touchUpInside)
        termsButtonNormal.addTarget(self, action: #selector(termsAction), for: .touchUpInside)
        termsButtonKeyboard.addTarget(self, action: #selector(termsAction), for: .touchUpInside)
        passwordField.onePasswordButton.addTarget(self, action: #selector(onePasswordAction(_:)), for: .touchUpInside)
        activateEmailButton.addTarget(self, action: #selector(activateEmail), for: .touchUpInside)
        activateUsernameButton.addTarget(self, action: #selector(activateUsername), for: .touchUpInside)
        activatePasswordButton.addTarget(self, action: #selector(activatePassword), for: .touchUpInside)
    }

    override func style() {
        super.style()

        let attrs = ElloAttributedString.attrs([
            NSForegroundColorAttributeName: UIColor.greyA(),
            NSFontAttributeName: UIFont.defaultFont(Size.termsFontSize),
        ])
        let linkAttrs = ElloAttributedString.attrs(ElloAttributedString.linkAttrs(), [
            NSForegroundColorAttributeName: UIColor.greyA(),
            NSFontAttributeName: UIFont.defaultFont(Size.termsFontSize),
        ])
        // needs i18n
        let attributedTitle = NSAttributedString(string: "By clicking Continue you are agreeing to our ", attributes: attrs) + NSAttributedString(string: "Terms", attributes: linkAttrs)
        termsButtonNormal.setAttributedTitle(attributedTitle, for: .normal)
        termsButtonKeyboard.setAttributedTitle(attributedTitle, for: .normal)

        ElloTextFieldView.styleAsEmailField(emailField)
        emailField.placeholder = InterfaceString.Join.EmailPlaceholder
        emailField.delegate = self

        ElloTextFieldView.styleAsUsernameField(usernameField)
        usernameField.placeholder = InterfaceString.Join.UsernamePlaceholder
        usernameField.delegate = self

        ElloTextFieldView.styleAsPasswordField(passwordField)
        passwordField.placeholder = InterfaceString.Join.PasswordPlaceholder
        passwordField.delegate = self
        passwordField.returnKeyType = .join
        passwordField.hasOnePassword = onePasswordAvailable

        messageLabel.numberOfLines = 0

        termsButtonNormal.isHidden = Keyboard.shared.active
        termsButtonKeyboard.isHidden = !Keyboard.shared.active

        continueBackground.backgroundColor = .white
    }

    override func arrange() {
        super.arrange()

        scrollView.addSubview(activateEmailButton)
        scrollView.addSubview(emailField)
        scrollView.addSubview(emailErrorLabel)
        scrollView.addSubview(activateUsernameButton)
        scrollView.addSubview(usernameField)
        scrollView.addSubview(usernameErrorLabel)
        scrollView.addSubview(messageLabel)
        scrollView.addSubview(activatePasswordButton)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(passwordErrorLabel)
        scrollView.addSubview(termsButtonKeyboard)

        addSubview(termsButtonNormal)
        addSubview(continueBackground)
        continueBackground.addSubview(discoverButton)

        scrollView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self)
            make.top.equalTo(blackBar.snp.bottom)
            make.bottom.equalTo(continueBackground.snp.top)
        }

        let scrollViewAnchor = UIView()
        scrollView.addSubview(scrollViewAnchor)
        scrollViewAnchor.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(scrollView)
            scrollViewWidthConstraint = make.width.equalTo(frame.size.width).priority(Priority.required).constraint
        }

        activateEmailButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(scrollView)
            make.centerY.equalTo(emailField)
            make.height.equalTo(emailField).offset(Size.fieldsInnerMargin)
        }
        emailField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Size.fieldsTopMargin)
            make.leading.trailing.equalTo(scrollView).inset(CredentialsScreen.Size.inset)
        }
        emailErrorLabel.snp.makeConstraints { make in
            emailMarginConstraint = make.top.equalTo(emailField.snp.bottom).offset(Size.fieldsErrorMargin).priority(Priority.required).constraint
            make.top.equalTo(emailField.snp.bottom).priority(Priority.medium)
            make.leading.trailing.equalTo(scrollView).inset(CredentialsScreen.Size.inset)
        }
        emailMarginConstraint.deactivate()

        activateUsernameButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(scrollView)
            make.centerY.equalTo(usernameField)
            make.height.equalTo(usernameField).offset(Size.fieldsInnerMargin)
        }
        usernameField.snp.makeConstraints { make in
            make.top.equalTo(emailErrorLabel.snp.bottom).offset(Size.fieldsInnerMargin)
            make.leading.trailing.equalTo(scrollView).inset(CredentialsScreen.Size.inset)
        }
        usernameErrorLabel.snp.makeConstraints { make in
            usernameMarginConstraint = make.top.equalTo(usernameField.snp.bottom).offset(Size.fieldsErrorMargin).priority(Priority.required).constraint
            make.top.equalTo(usernameField.snp.bottom).priority(Priority.medium)
            make.leading.trailing.equalTo(scrollView).inset(CredentialsScreen.Size.inset)
        }
        usernameMarginConstraint.deactivate()

        messageLabel.snp.makeConstraints { make in
            messageMarginConstraint = make.top.equalTo(usernameErrorLabel.snp.bottom).offset(Size.fieldsErrorMargin).priority(Priority.required).constraint
            make.top.equalTo(usernameErrorLabel.snp.bottom).priority(Priority.medium)
            make.leading.trailing.equalTo(scrollView).inset(CredentialsScreen.Size.inset)
        }
        messageMarginConstraint.deactivate()

        activatePasswordButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(scrollView)
            make.centerY.equalTo(passwordField)
            make.height.equalTo(passwordField).offset(Size.fieldsInnerMargin)
        }
        passwordField.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(Size.fieldsInnerMargin)
            make.leading.trailing.equalTo(scrollView).inset(CredentialsScreen.Size.inset)
        }
        passwordErrorLabel.snp.makeConstraints { make in
            passwordMarginConstraint = make.top.equalTo(passwordField.snp.bottom).offset(Size.fieldsErrorMargin).priority(Priority.required).constraint
            make.top.equalTo(passwordField.snp.bottom).priority(Priority.medium)
            make.leading.trailing.equalTo(scrollView).inset(CredentialsScreen.Size.inset)
            make.bottom.lessThanOrEqualTo(scrollView).inset(Size.inset)
        }
        passwordMarginConstraint.deactivate()

        termsButtonKeyboard.snp.makeConstraints { make in
            make.leading.equalTo(scrollView).inset(CredentialsScreen.Size.inset)
            make.top.equalTo(passwordErrorLabel.snp.bottom).offset(Size.inset)
            make.bottom.equalTo(scrollView).inset(CredentialsScreen.Size.inset)
        }

        termsButtonNormal.snp.makeConstraints { make in
            make.leading.equalTo(scrollView).inset(CredentialsScreen.Size.inset)
            make.bottom.equalTo(continueBackground.snp.top).offset(-Size.termsBottomInset)
        }

        discoverButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self).inset(Size.buttonInset)
            make.bottom.equalTo(keyboardAnchor.snp.top).offset(-Size.buttonInset)
            make.height.equalTo(Size.buttonHeight)
        }

        continueBackground.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(self)
            make.top.equalTo(discoverButton).offset(-Size.buttonInset)
        }
    }

    override func resignFirstResponder() -> Bool {
        _ = emailField.resignFirstResponder()
        _ = usernameField.resignFirstResponder()
        _ = passwordField.resignFirstResponder()
        return super.resignFirstResponder()
    }

    override func keyboardIsAnimating(_ keyboard: Keyboard) {
        termsButtonNormal.isHidden = keyboard.active
        termsButtonKeyboard.isHidden = !keyboard.active
    }
}

extension JoinScreen {
    fileprivate func styleDiscoverButton() {
        let allValid: Bool
        if let emailValid = emailValid,
            let usernameValid = usernameValid,
            let passwordValid = passwordValid
        {
            allValid = emailValid && usernameValid && passwordValid
        }
        else {
            allValid = false
        }

        if allValid {
            discoverButton.style = .Green
        }
        else {
            discoverButton.style = .RoundedGray
        }
    }
}

extension JoinScreen {
    func activateEmail() {
      _ = emailField.becomeFirstResponder()
    }

    func activateUsername() {
      _ = usernameField.becomeFirstResponder()
    }

    func activatePassword() {
      _ = passwordField.becomeFirstResponder()
    }

    override func backAction() {
        delegate?.backAction()
    }

    func submitAction() {
        delegate?.submit(email: email, username: username, password: password)
    }

    func termsAction() {
        delegate?.termsAction()
    }

    func onePasswordAction(_ sender: UIView) {
        delegate?.onePasswordAction(sender)
    }
}

extension JoinScreen: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.setNeedsLayout()
        textField.layoutIfNeeded()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn nsrange: NSRange, replacementString: String) -> Bool {
        guard let delegate = delegate else { return true }

        var text = textField.text ?? ""
        if let range = text.rangeFromNSRange(nsrange) {
            text.replaceSubrange(range, with: replacementString)
        }
        var email = self.email,
            username = self.username,
            password = self.password
        switch textField {
        case emailField:
            email = text
        case usernameField:
            username = text
        case passwordField:
            password = text
        default:
            break
        }

        delegate.validate(email: email, username: username, password: password)
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailField:
            Tracker.shared.enteredEmail()
            _ = usernameField.becomeFirstResponder()
            return true
        case usernameField:
            Tracker.shared.enteredEmail()
            _ = passwordField.becomeFirstResponder()
            return true
        case passwordField:
            Tracker.shared.enteredPassword()
            delegate?.submit(email: email, username: username, password: password)
            return false
        default:
            return true
        }
    }
}

extension JoinScreen: JoinScreenProtocol {
    func loadingHUD(visible: Bool) {
        if visible {
            ElloHUD.showLoadingHudInView(self)
        }
        else {
            ElloHUD.hideLoadingHudInView(self)
        }
        emailField.isEnabled = !visible
        usernameField.isEnabled = !visible
        passwordField.isEnabled = !visible
        isUserInteractionEnabled = !visible
    }

    func showUsernameSuggestions(_ usernames: [String]) {
        let usernameAttrs = [
            NSFontAttributeName: UIFont.defaultFont(12),
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue as AnyObject,
        ]
        let plainAttrs = [
            NSFontAttributeName: UIFont.defaultFont(12),
        ]
        let suggestions: NSAttributedString = usernames.reduce(NSAttributedString(string: "", attributes: plainAttrs)) { attrdString, username in
            let usernameAttrd = NSAttributedString(string: username, attributes: usernameAttrs)
            if attrdString.string.isEmpty {
                return usernameAttrd
            }
            return attrdString + NSAttributedString(string: ", ", attributes: plainAttrs) + usernameAttrd
        }
        let msg = NSAttributedString(string: InterfaceString.Join.UsernameSuggestionPrefix, attributes: plainAttrs) + suggestions
        showMessageAttributed(msg)
    }

    func showMessage(_ text: String) {
        let plainAttrs = [
            NSFontAttributeName: UIFont.defaultFont(12),
        ]
        showMessageAttributed(NSAttributedString(string: text, attributes: plainAttrs))
    }

    func showMessageAttributed(_ attrd: NSAttributedString) {
        messageLabel.attributedText = attrd

        animate {
            self.messageMarginConstraint.activate()
            self.messageLabel.alpha = 1.0
            self.layoutIfNeeded()
        }
    }

    func hideMessage() {
        animate {
            self.messageMarginConstraint.deactivate()
            self.messageLabel.alpha = 0.0
            self.layoutIfNeeded()
        }
    }

    func showUsernameError(_ text: String) {
        usernameErrorLabel.text = text
        usernameValid = false

        animate {
            self.usernameMarginConstraint.activate()
            self.usernameErrorLabel.alpha = 1.0
            self.layoutIfNeeded()
        }
    }

    func hideUsernameError() {
        animate {
            self.usernameMarginConstraint.deactivate()
            self.usernameErrorLabel.alpha = 0.0
            self.layoutIfNeeded()
        }
    }

    func showEmailError(_ text: String) {
        emailErrorLabel.text = text
        emailValid = false

        animate {
            self.emailMarginConstraint.activate()
            self.emailErrorLabel.alpha = 1.0
            self.layoutIfNeeded()
        }
    }

    func hideEmailError() {
        animate {
            self.emailMarginConstraint.deactivate()
            self.emailErrorLabel.alpha = 0.0
            self.layoutIfNeeded()
        }
    }

    func showPasswordError(_ text: String) {
        passwordErrorLabel.text = text
        passwordValid = false

        animate {
            self.passwordMarginConstraint.activate()
            self.passwordErrorLabel.alpha = 1.0
            self.layoutIfNeeded()
        }
    }

    func hidePasswordError() {
        animate {
            self.passwordMarginConstraint.deactivate()
            self.passwordErrorLabel.alpha = 0.0
            self.layoutIfNeeded()
        }
    }

    func showError(_ text: String) {
        showPasswordError(text)
    }
}
