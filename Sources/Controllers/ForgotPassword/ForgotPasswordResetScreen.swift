////
///  ForgotPasswordResetScreen.swift
//

import SnapKit


class ForgotPasswordResetScreen: CredentialsScreen {
    struct Size {
        static let fieldsTopMargin: CGFloat = 55
        static let fieldsErrorMargin: CGFloat = 15
        static let fieldsInnerMargin: CGFloat = 30
    }
    weak var delegate: ForgotPasswordResetScreenDelegate?

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

    let passwordField = ClearTextField()
    let activatePasswordButton = UIButton()
    let passwordErrorLabel = StyledLabel(style: .smallWhite)
    var passwordMarginConstraint: Constraint!

    let failureLabel = StyledLabel(style: .white)

    override func setText() {
        titleLabel.text = InterfaceString.Startup.ForgotPasswordReset
        continueButton.title = InterfaceString.Startup.Reset
        passwordField.placeholder = InterfaceString.Join.PasswordPlaceholder
        failureLabel.text = InterfaceString.Startup.ForgotPasswordResetError
    }

    override func bindActions() {
        continueButton.addTarget(self, action: #selector(submitAction), for: .touchUpInside)
        activatePasswordButton.addTarget(
            self,
            action: #selector(activatePassword),
            for: .touchUpInside
        )
        passwordField.delegate = self
    }

    override func style() {
        ElloTextFieldView.styleAsPasswordField(passwordField)

        failureLabel.isMultiline = true
        failureLabel.isHidden = true
    }

    override func arrange() {
        super.arrange()

        scrollView.addSubview(activatePasswordButton)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(passwordErrorLabel)
        scrollView.addSubview(failureLabel)

        activatePasswordButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(scrollView)
            make.centerY.equalTo(passwordField)
            make.height.equalTo(passwordField).offset(Size.fieldsInnerMargin)
        }
        passwordField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Size.fieldsTopMargin)
            make.leading.trailing.equalTo(scrollView).inset(CredentialsScreen.Size.inset)
        }
        passwordErrorLabel.snp.makeConstraints { make in
            passwordMarginConstraint =
                make.top.equalTo(passwordField.snp.bottom).offset(Size.fieldsErrorMargin).priority(
                    Priority.required
                ).constraint
            make.top.equalTo(passwordField.snp.bottom).priority(Priority.medium)
            make.leading.trailing.equalTo(scrollView).inset(CredentialsScreen.Size.inset)
        }
        passwordMarginConstraint.deactivate()

        failureLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Size.fieldsTopMargin)
            make.leading.trailing.equalTo(scrollView).inset(CredentialsScreen.Size.inset)
        }
    }

    @objc
    func submitAction() {
        delegate?.submit(password: passwordField.text ?? "")
    }

    override func backAction() {
        delegate?.backAction()
    }
}


extension ForgotPasswordResetScreen: ForgotPasswordResetScreenProtocol {

    override func resignFirstResponder() -> Bool {
        _ = passwordField.resignFirstResponder()
        return super.resignFirstResponder()
    }

    func showFailureMessage() {
        failureLabel.isVisible = true
        activatePasswordButton.isHidden = true
        passwordField.isHidden = true
        passwordErrorLabel.isHidden = true
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

    func loadingHUD(visible: Bool) {
        if visible {
            ElloHUD.showLoadingHudInView(self)
        }
        else {
            ElloHUD.hideLoadingHudInView(self)
        }
        passwordField.isEnabled = !visible
        isUserInteractionEnabled = !visible
    }


    func hidePasswordError() {
        elloAnimate {
            self.passwordMarginConstraint.deactivate()
            self.passwordErrorLabel.alpha = 0.0
            self.layoutIfNeeded()
        }
    }
}

extension ForgotPasswordResetScreen: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.setNeedsLayout()
        textField.layoutIfNeeded()
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn nsrange: NSRange,
        replacementString: String
    ) -> Bool {
        guard let delegate = delegate else { return true }

        var password = textField.text ?? ""
        if let range = password.rangeFromNSRange(nsrange) {
            password.replaceSubrange(range, with: replacementString)
        }
        delegate.validate(password: password)
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

extension ForgotPasswordResetScreen {
    @objc
    func activatePassword() {
        _ = passwordField.becomeFirstResponder()
    }

    func allFieldsValid() -> Bool {
        if let isPasswordValid = isPasswordValid {
            return isPasswordValid
        }
        else {
            return false
        }
    }
}
