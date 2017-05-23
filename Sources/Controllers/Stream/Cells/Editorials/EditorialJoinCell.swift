////
///  EditorialJoinCell.swift
//

class EditorialJoinCell: EditorialCell {
    fileprivate let joinLabel = StyledLabel(style: .largerWhite)
    fileprivate let emailField = ElloTextField()
    fileprivate let usernameField = ElloTextField()
    fileprivate let passwordField = ElloTextField()
    fileprivate let submitButton = StyledButton(style: .editorialJoin)

    var onJoinChange: ((Editorial.JoinInfo) -> Void)?

    fileprivate var isValid: Bool {
        guard
            let email = emailField.text,
            let username = usernameField.text,
            let password = passwordField.text
        else { return false }

        return Validator.hasValidSignUpCredentials(email: email, username: username, password: password)
    }

    @objc
    func submitTapped() {
        guard
            let email = emailField.text,
            let username = usernameField.text,
            let password = passwordField.text
        else { return }

        let responder = target(forAction: #selector(EditorialResponder.submitJoin(cell:email:username:password:)), withSender: self) as? EditorialResponder
        responder?.submitJoin(cell: self, email: email, username: username, password: password)
    }

    override func updateConfig() {
        super.updateConfig()
        emailField.text = config.join?.email
        usernameField.text = config.join?.username
        passwordField.text = config.join?.password
    }

    override func bindActions() {
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        emailField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        usernameField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    override func style() {
        super.style()

        joinLabel.text = InterfaceString.Editorials.Join
        joinLabel.numberOfLines = 0
        ElloTextFieldView.styleAsEmailField(emailField)
        ElloTextFieldView.styleAsUsernameField(usernameField)
        ElloTextFieldView.styleAsPasswordField(passwordField)
        emailField.backgroundColor = .white
        emailField.placeholder = InterfaceString.Editorials.EmailPlaceholder
        usernameField.backgroundColor = .white
        usernameField.placeholder = InterfaceString.Editorials.UsernamePlaceholder
        passwordField.backgroundColor = .white
        passwordField.placeholder = InterfaceString.Editorials.PasswordPlaceholder
        submitButton.isEnabled = false
        submitButton.setTitle(InterfaceString.Editorials.SubmitJoin, for: .normal)
    }

    override func arrange() {
        super.arrange()

        editorialContentView.addSubview(joinLabel)
        editorialContentView.addSubview(emailField)
        editorialContentView.addSubview(usernameField)
        editorialContentView.addSubview(passwordField)
        editorialContentView.addSubview(submitButton)

        joinLabel.snp.makeConstraints { make in
            make.top.equalTo(editorialContentView).inset(Size.smallTopMargin)
            make.leading.equalTo(editorialContentView).inset(Size.defaultMargin)
            make.trailing.lessThanOrEqualTo(editorialContentView).inset(Size.defaultMargin).priority(Priority.required)
        }

        let fields = [emailField, usernameField, passwordField]
        fields.eachPair { prevField, field in
            field.snp.makeConstraints { make in
                make.leading.trailing.equalTo(editorialContentView).inset(Size.defaultMargin)
                if let prevField = prevField {
                    make.height.equalTo(prevField)
                    make.top.equalTo(prevField.snp.bottom).offset(Size.textFieldMargin)
                }
                else {
                    make.top.equalTo(joinLabel.snp.bottom).offset(Size.defaultMargin)
                }
            }
        }

        submitButton.snp.makeConstraints { make in
            make.height.equalTo(Size.buttonHeight)
            make.top.equalTo(fields.last!.snp.bottom).offset(Size.textFieldMargin)
            make.bottom.equalTo(editorialContentView).offset(-Size.defaultMargin)
            make.leading.trailing.equalTo(editorialContentView).inset(Size.defaultMargin)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onJoinChange = nil
    }
}

extension EditorialJoinCell {
    func textFieldDidChange() {
        let info: Editorial.JoinInfo = (email: emailField.text, username: usernameField.text, password: passwordField.text)
        onJoinChange?(info)
        submitButton.isEnabled = isValid
    }
}
