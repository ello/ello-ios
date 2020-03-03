////
///  ForgotPasswordEmailScreen.swift
//

import SnapKit


class ForgotPasswordEmailScreen: CredentialsScreen {
    struct Size {
        static let fieldsTopMargin: CGFloat = 55
        static let fieldsErrorMargin: CGFloat = 15
        static let fieldsInnerMargin: CGFloat = 30
    }
    weak var delegate: ForgotPasswordEmailScreenDelegate?

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

    let emailField = ClearTextField()
    let activateEmailButton = UIButton()
    let emailErrorLabel = StyledLabel(style: .smallWhite)
    var emailMarginConstraint: Constraint!

    let successLabel = StyledLabel(style: .white)

    override func setup() {
        successLabel.isHidden = true
    }

    override func style() {
        ElloTextFieldView.styleAsEmailField(emailField)

        successLabel.isMultiline = true
    }

    override func setText() {
        titleLabel.text = InterfaceString.Startup.ForgotPasswordEnter
        successLabel.text = InterfaceString.Startup.ForgotPasswordEnterSuccess
        continueButton.title = InterfaceString.Startup.Reset
        emailField.placeholder = InterfaceString.Join.EmailPlaceholder
    }

    override func bindActions() {
        continueButton.addTarget(self, action: #selector(submitAction), for: .touchUpInside)
        activateEmailButton.addTarget(self, action: #selector(activateEmail), for: .touchUpInside)
        emailField.delegate = self
    }

    override func arrange() {
        super.arrange()

        scrollView.addSubview(activateEmailButton)
        scrollView.addSubview(emailField)
        scrollView.addSubview(emailErrorLabel)
        scrollView.addSubview(successLabel)

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

        successLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Size.fieldsTopMargin)
            make.leading.trailing.equalTo(scrollView).inset(CredentialsScreen.Size.inset)
        }
    }

    @objc
    func submitAction() {
        delegate?.submit(email: emailField.text ?? "")
    }

    override func backAction() {
        delegate?.backAction()
    }
}


extension ForgotPasswordEmailScreen: ForgotPasswordEmailScreenProtocol {

    override func resignFirstResponder() -> Bool {
        _ = emailField.resignFirstResponder()
        return super.resignFirstResponder()
    }

    func showSubmitMessage() {
        successLabel.isVisible = true
        activateEmailButton.isHidden = true
        emailField.isHidden = true
        emailErrorLabel.isHidden = true
        styleContinueButton(allValid: false)
        continueButton.isUserInteractionEnabled = false
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

    func loadingHUD(visible: Bool) {
        if visible {
            ElloHUD.showLoadingHudInView(self)
        }
        else {
            ElloHUD.hideLoadingHudInView(self)
        }
        emailField.isEnabled = !visible
        isUserInteractionEnabled = !visible
    }


    func hideEmailError() {
        elloAnimate {
            self.emailMarginConstraint.deactivate()
            self.emailErrorLabel.alpha = 0.0
            self.layoutIfNeeded()
        }
    }
}

extension ForgotPasswordEmailScreen: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.setNeedsLayout()
        textField.layoutIfNeeded()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn nsrange: NSRange, replacementString: String) -> Bool {
        guard let delegate = delegate else { return true }

        var email = textField.text ?? ""
        if let range = email.rangeFromNSRange(nsrange) {
            email.replaceSubrange(range, with: replacementString)
        }
        delegate.validate(email: email)
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

extension ForgotPasswordEmailScreen {
    @objc
    func activateEmail() {
      _ = emailField.becomeFirstResponder()
    }

    func allFieldsValid() -> Bool {
        if let isEmailValid = isEmailValid {
            return isEmailValid
        }
        else {
            return false
        }
    }
}
