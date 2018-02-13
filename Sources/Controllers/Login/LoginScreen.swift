////
///  LoginScreen.swift
//

import SnapKit


class LoginScreen: CredentialsScreen {
    struct Size {
        static let fieldsTopMargin: CGFloat = 55
        static let fieldsInnerMargin: CGFloat = 30
        static let forgotPasswordFontSize: CGFloat = 11
    }

    weak var delegate: LoginScreenDelegate?
    var username: String {
        get { return usernameField.text?.trimmingCharacters(in: CharacterSet.whitespaces) ?? "" }
        set { usernameField.text = newValue }
    }
    var isUsernameValid: Bool? = nil {
        didSet {
            if let usernameValid = isUsernameValid {
                usernameField.validationState = usernameValid ? .okSmall : .error
                styleContinueButton(allValid: allFieldsValid())
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
    var isPasswordValid: Bool? = nil {
        didSet {
            if let passwordValid = isPasswordValid {
                passwordField.validationState = passwordValid ? .okSmall : .error
                styleContinueButton(allValid: allFieldsValid())
            }
            else {
                passwordField.validationState = .none
            }
        }
    }
    var isOnePasswordAvailable = false {
        didSet { passwordField.hasOnePassword = isOnePasswordAvailable }
    }

    let usernameField = ClearTextField()
    private let activateUsernameButton = UIButton()
    let passwordField = ClearTextField()
    private let activatePasswordButton = UIButton()
    private let errorLabel = StyledLabel(style: .smallWhite)

    private let forgotPasswordButton = UIButton()

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
        passwordField.hasOnePassword = isOnePasswordAvailable

        continueBackground.backgroundColor = .white

        forgotPasswordButton.titleLabel?.font = UIFont.defaultFont(Size.forgotPasswordFontSize)
        forgotPasswordButton.setTitleColor(.greyA, for: .normal)
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

    override func backAction() {
        delegate?.backAction()
    }
}

extension LoginScreen {
    func allFieldsValid() -> Bool {
        if let usernameValid = isUsernameValid,
            let passwordValid = isPasswordValid
        {
            return usernameValid && passwordValid
        }
        else {
            return false
        }
    }
}

// MARK: Actions
extension LoginScreen {

    @objc
    func forgotPasswordAction() {
        delegate?.forgotPasswordAction()
    }

    @objc
    func submitAction() {
        delegate?.submit(username: username, password: password)
    }

    @objc
    func onePasswordAction(_ sender: UIView) {
        delegate?.onePasswordAction(sender)
    }

    @objc
    func activateUsername() {
        _ = usernameField.becomeFirstResponder()
    }

    @objc
    func activatePassword() {
        _ = passwordField.becomeFirstResponder()
    }
}

// MARK: UITextFieldDelegate
extension LoginScreen: UITextFieldDelegate {
    @objc
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
        isUsernameValid = false
        isPasswordValid = false

        elloAnimate {
            self.errorLabel.alpha = 1.0
            self.layoutIfNeeded()
        }
    }

    func hideError() {
        elloAnimate {
            self.errorLabel.alpha = 0.0
            self.layoutIfNeeded()
        }
    }
}
