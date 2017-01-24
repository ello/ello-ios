////
///  LoginScreen.swift
//

import SnapKit


class LoginScreen: CredentialsScreen {
    struct Size {
        static let fieldsTopMargin: CGFloat = 55
        static let fieldsInnerMargin: CGFloat = 30
        static let buttonHeight: CGFloat = 50
        static let buttonInset: CGFloat = 10
        static let forgotPasswordFontSize: CGFloat = 11
    }

    weak var delegate: LoginDelegate?
    var username: String {
        get { return usernameField.text?.trimmingCharacters(in: CharacterSet.whitespaces) ?? "" }
        set { usernameField.text = newValue }
    }
    var usernameValid: Bool? = nil {
        didSet {
            if let usernameValid = usernameValid {
                usernameField.validationState = usernameValid ? .okSmall : .error
                styleContinueButton()
            }
            else {
                usernameField.validationState = .none
            }
        }
    }
    var password: String {
        get { return passwordField.text ?? "" }
        set { passwordField.text = newValue }
    }
    var passwordValid: Bool? = nil {
        didSet {
            if let passwordValid = passwordValid {
                passwordField.validationState = passwordValid ? .okSmall : .error
                styleContinueButton()
            }
            else {
                passwordField.validationState = .none
            }
        }
    }
    var onePasswordAvailable = false {
        didSet { passwordField.hasOnePassword = onePasswordAvailable }
    }

    let usernameField = ClearTextField()
    fileprivate let activateUsernameButton = UIButton()
    let passwordField = ClearTextField()
    fileprivate let activatePasswordButton = UIButton()
    fileprivate let errorLabel = StyledLabel(style: .SmallWhite)

    fileprivate let forgotPasswordButton = UIButton()
    fileprivate let continueButton = StyledButton(style: .RoundedGray)
    fileprivate let continueBackground = UIView()

    override func setText() {
        titleLabel.text = InterfaceString.Startup.Login
        usernameField.placeholder = InterfaceString.Login.UsernamePlaceholder
        passwordField.placeholder = InterfaceString.Login.PasswordPlaceholder
        continueButton.setTitle(InterfaceString.Login.Continue, for: .normal)
        forgotPasswordButton.setTitle(InterfaceString.Login.ForgotPassword, for: .normal)
    }

    override func bindActions() {
        super.bindActions()
        continueButton.addTarget(self, action: #selector(submitAction), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordAction), for: .touchUpInside)
        passwordField.onePasswordButton.addTarget(self, action: #selector(onePasswordAction(_:)), for: .touchUpInside)
        usernameField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        usernameField.delegate = self
        activateUsernameButton.addTarget(self, action: #selector(activateUsername), for: .touchUpInside)
        passwordField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordField.delegate = self
        activatePasswordButton.addTarget(self, action: #selector(activatePassword), for: .touchUpInside)
    }

    override func style() {
        super.style()

        ElloTextFieldView.styleAsEmailField(usernameField)

        ElloTextFieldView.styleAsPasswordField(passwordField)
        passwordField.hasOnePassword = onePasswordAvailable

        continueBackground.backgroundColor = .white

        forgotPasswordButton.titleLabel?.font = UIFont.defaultFont(Size.forgotPasswordFontSize)
        forgotPasswordButton.setTitleColor(.greyA(), for: .normal)
    }

    fileprivate func styleContinueButton() {
        let allValid: Bool
        if let usernameValid = usernameValid,
            let passwordValid = passwordValid
        {
            allValid = usernameValid && passwordValid
        }
        else {
            allValid = false
        }

        if allValid {
            continueButton.style = .Green
        }
        else {
            continueButton.style = .RoundedGray
        }
    }

    override func arrange() {
        super.arrange()

        scrollView.addSubview(activateUsernameButton)
        scrollView.addSubview(usernameField)
        scrollView.addSubview(activatePasswordButton)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(forgotPasswordButton)
        scrollView.addSubview(errorLabel)

        addSubview(continueBackground)
        continueBackground.addSubview(continueButton)

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

        usernameField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Size.fieldsTopMargin)
            make.leading.trailing.equalTo(scrollView).inset(CredentialsScreen.Size.inset)
        }
        activateUsernameButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(scrollView)
            make.centerY.equalTo(usernameField)
            make.height.equalTo(usernameField).offset(Size.fieldsInnerMargin)
        }

        passwordField.snp.makeConstraints { make in
            make.top.equalTo(usernameField.snp.bottom).offset(Size.fieldsInnerMargin)
            make.leading.trailing.equalTo(scrollView).inset(CredentialsScreen.Size.inset)
        }
        activatePasswordButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(scrollView)
            make.centerY.equalTo(passwordField)
            make.height.equalTo(passwordField).offset(Size.fieldsInnerMargin)
        }

        forgotPasswordButton.snp.makeConstraints { make in
            make.top.equalTo(passwordField.snp.bottom).offset(Size.fieldsInnerMargin)
            make.trailing.equalTo(scrollView).inset(Size.buttonInset)
        }

        continueButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self).inset(Size.buttonInset)
            make.bottom.equalTo(keyboardAnchor.snp.top).offset(-Size.buttonInset)
            make.height.equalTo(Size.buttonHeight)
        }

        continueBackground.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(self)
            make.top.equalTo(continueButton).offset(-Size.buttonInset)
        }

        errorLabel.snp.makeConstraints { make in
            make.firstBaseline.equalTo(forgotPasswordButton)
            make.leading.trailing.equalTo(scrollView).inset(Size.inset)
            make.bottom.lessThanOrEqualTo(scrollView).inset(Size.inset)
        }
    }

    override func resignFirstResponder() -> Bool {
        _ = usernameField.resignFirstResponder()
        _ = passwordField.resignFirstResponder()
        return super.resignFirstResponder()
    }
}

// MARK: Actions
extension LoginScreen {
    override func backAction() {
        delegate?.backAction()
    }

    func forgotPasswordAction() {
        delegate?.forgotPasswordAction()
    }

    func submitAction() {
        delegate?.submit(username: username, password: password)
    }

    func onePasswordAction(_ sender: UIView) {
        delegate?.onePasswordAction(sender)
    }

    func activateUsername() {
        _ = usernameField.becomeFirstResponder()
    }

    func activatePassword() {
        _ = passwordField.becomeFirstResponder()
    }
}

// MARK: UITextFieldDelegate
extension LoginScreen: UITextFieldDelegate {
    func textFieldDidChange(_ textField: UITextField) {
        delegate?.validate(username: username, password: password)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.setNeedsLayout()
        textField.layoutIfNeeded()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case usernameField:
            Tracker.shared.enteredEmail()
            _ = passwordField.becomeFirstResponder()
            return true
        case passwordField:
            Tracker.shared.enteredPassword()
            delegate?.submit(username: username, password: password)
            return false
        default:
            return true
        }
    }
}

// MARK: LoginScreenProtocol
extension LoginScreen: LoginScreenProtocol {
    func loadingHUD(visible: Bool) {
        if visible {
            ElloHUD.showLoadingHudInView(self)
        }
        else {
            ElloHUD.hideLoadingHudInView(self)
        }
        usernameField.isEnabled = !visible
        passwordField.isEnabled = !visible
        isUserInteractionEnabled = !visible
    }

    func showError(_ text: String) {
        errorLabel.text = text
        usernameValid = false
        passwordValid = false

        animate {
            self.errorLabel.alpha = 1.0
            self.layoutIfNeeded()
        }
    }

    func hideError() {
        animate {
            self.errorLabel.alpha = 0.0
            self.layoutIfNeeded()
        }
    }
}
