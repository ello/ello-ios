////
///  JoinScreen.swift
//

import SnapKit


class JoinScreen: CredentialsScreen {
    struct Size {
        static let fieldsTopMargin: CGFloat = 55
        static let fieldsErrorMargin: CGFloat = 15
        static let fieldsInnerMargin: CGFloat = 30
        static let termsFontSize: CGFloat = 11
        static let termsBottomInset: CGFloat = 5
    }

    weak var delegate: JoinDelegate?
    var isEmailValid: Bool? = nil {
        didSet {
            if let isEmailValid = isEmailValid {
                emailField.validationState = isEmailValid ? .okSmall : .error
                styleContinueButton(allValid: allFieldsValid())
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
    var isUsernameValid: Bool? = nil {
        didSet {
            if let isUsernameValid = isUsernameValid {
                usernameField.validationState = isUsernameValid ? .okSmall : .error
                styleContinueButton(allValid: allFieldsValid())
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
    var isPasswordValid: Bool? = nil {
        didSet {
            if let isPasswordValid = isPasswordValid {
                passwordField.validationState = isPasswordValid ? .okSmall : .error
                styleContinueButton(allValid: allFieldsValid())
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
    var isOnePasswordAvailable = false {
        didSet { passwordField.hasOnePassword = isOnePasswordAvailable }
    }

    let emailField = ClearTextField()
    let activateEmailButton = UIButton()
    let emailErrorLabel = StyledLabel(style: .smallWhite)
    var emailMarginConstraint: Constraint!

    let usernameField = ClearTextField()
    let activateUsernameButton = UIButton()
    let usernameErrorLabel = StyledLabel(style: .smallWhite)
    var usernameMarginConstraint: Constraint!

    let passwordField = ClearTextField()
    let activatePasswordButton = UIButton()
    let passwordErrorLabel = StyledLabel(style: .smallWhite)
    var passwordMarginConstraint: Constraint!

    let messageLabel = StyledLabel(style: .smallWhite)
    var messageMarginConstraint: Constraint!
    let termsButtonNormal = UIButton()
    let termsButtonKeyboard = UIButton()

    override func setText() {
        titleLabel.text = InterfaceString.Startup.SignUp
        continueButton.setTitle(InterfaceString.Join.Discover, for: .normal)
        emailField.placeholder = InterfaceString.Join.EmailPlaceholder
        usernameField.placeholder = InterfaceString.Join.UsernamePlaceholder
        passwordField.placeholder = InterfaceString.Join.PasswordPlaceholder
    }

    override func bindActions() {
        super.bindActions()
        continueButton.addTarget(self, action: #selector(submitAction), for: .touchUpInside)
        termsButtonNormal.addTarget(self, action: #selector(termsAction), for: .touchUpInside)
        termsButtonKeyboard.addTarget(self, action: #selector(termsAction), for: .touchUpInside)
        passwordField.onePasswordButton.addTarget(self, action: #selector(onePasswordAction(_:)), for: .touchUpInside)
        activateEmailButton.addTarget(self, action: #selector(activateEmail), for: .touchUpInside)
        activateUsernameButton.addTarget(self, action: #selector(activateUsername), for: .touchUpInside)
        activatePasswordButton.addTarget(self, action: #selector(activatePassword), for: .touchUpInside)
        emailField.delegate = self
        usernameField.delegate = self
        passwordField.delegate = self
    }

    override func style() {
        super.style()

        let attrs = NSAttributedString.defaultAttrs([
            .foregroundColor: UIColor.greyA,
            .font: UIFont.defaultFont(Size.termsFontSize),
        ])
        let linkAttrs = NSAttributedString.defaultAttrs([
            .underlineStyle: NSUnderlineStyle.styleSingle.rawValue,
            .foregroundColor: UIColor.greyA,
            .font: UIFont.defaultFont(Size.termsFontSize),
        ])
        // needs i18n
        let attributedTitle = NSAttributedString(string: "By clicking Continue you are agreeing to our ", attributes: attrs) + NSAttributedString(string: "Terms", attributes: linkAttrs)
        termsButtonNormal.setAttributedTitle(attributedTitle, for: .normal)
        termsButtonKeyboard.setAttributedTitle(attributedTitle, for: .normal)

        ElloTextFieldView.styleAsEmailField(emailField)

        ElloTextFieldView.styleAsUsernameField(usernameField)

        ElloTextFieldView.styleAsPasswordField(passwordField)
        passwordField.returnKeyType = .join
        passwordField.hasOnePassword = isOnePasswordAvailable

        messageLabel.isMultiline = true

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

    override func backAction() {
        delegate?.backAction()
    }
}

extension JoinScreen {
    func allFieldsValid() -> Bool {
        if let isEmailValid = isEmailValid,
            let isUsernameValid = isUsernameValid,
            let isPasswordValid = isPasswordValid
        {
            return isEmailValid && isUsernameValid && isPasswordValid
        }
        else {
            return false
        }
    }
}

extension JoinScreen {
    @objc
    func activateEmail() {
      _ = emailField.becomeFirstResponder()
    }

    @objc
    func activateUsername() {
      _ = usernameField.becomeFirstResponder()
    }

    @objc
    func activatePassword() {
      _ = passwordField.becomeFirstResponder()
    }

    @objc
    func submitAction() {
        delegate?.submit(email: email, username: username, password: password)
    }

    @objc
    func termsAction() {
        Tracker.shared.tappedTsAndCs()
        delegate?.termsAction()
    }

    @objc
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
        let usernameAttrs: [NSAttributedStringKey: Any] = [
            .font: UIFont.defaultFont(12),
            .underlineStyle: NSUnderlineStyle.styleSingle.rawValue,
        ]
        let plainAttrs: [NSAttributedStringKey: Any] = [
            .font: UIFont.defaultFont(12),
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
        let plainAttrs: [NSAttributedStringKey: Any] = [
            .font: UIFont.defaultFont(12),
        ]
        showMessageAttributed(NSAttributedString(string: text, attributes: plainAttrs))
    }

    func showMessageAttributed(_ attrd: NSAttributedString) {
        messageLabel.attributedText = attrd

        elloAnimate {
            self.messageMarginConstraint.activate()
            self.messageLabel.alpha = 1.0
            self.layoutIfNeeded()
        }
    }

    func hideMessage() {
        elloAnimate {
            self.messageMarginConstraint.deactivate()
            self.messageLabel.alpha = 0.0
            self.layoutIfNeeded()
        }
    }

    func showUsernameError(_ text: String) {
        usernameErrorLabel.text = text
        isUsernameValid = false

        elloAnimate {
            self.usernameMarginConstraint.activate()
            self.usernameErrorLabel.alpha = 1.0
            self.layoutIfNeeded()
        }
    }

    func hideUsernameError() {
        elloAnimate {
            self.usernameMarginConstraint.deactivate()
            self.usernameErrorLabel.alpha = 0.0
            self.layoutIfNeeded()
        }
    }

    func showEmailError(_ text: String) {
        emailErrorLabel.text = text
        isEmailValid = false

        elloAnimate {
            self.emailMarginConstraint.activate()
            self.emailErrorLabel.alpha = 1.0
            self.layoutIfNeeded()
        }
    }

    func hideEmailError() {
        elloAnimate {
            self.emailMarginConstraint.deactivate()
            self.emailErrorLabel.alpha = 0.0
            self.layoutIfNeeded()
        }
    }

    func showPasswordError(_ text: String) {
        passwordErrorLabel.text = text
        isPasswordValid = false

        elloAnimate {
            self.passwordMarginConstraint.activate()
            self.passwordErrorLabel.alpha = 1.0
            self.layoutIfNeeded()
        }
    }

    func hidePasswordError() {
        elloAnimate {
            self.passwordMarginConstraint.deactivate()
            self.passwordErrorLabel.alpha = 0.0
            self.layoutIfNeeded()
        }
    }

    func showError(_ text: String) {
        showPasswordError(text)
    }
}
