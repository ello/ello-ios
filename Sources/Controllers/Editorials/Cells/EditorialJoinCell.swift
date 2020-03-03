////
///  EditorialJoinCell.swift
//

class EditorialJoinCell: EditorialCellContent {
    private let joinLabel = StyledLabel(style: .editorialHeader)
    private let joinCaption = StyledLabel(style: .editorialCaption)
    private let emailField = ElloTextField()
    private let usernameField = ElloTextField()
    private let passwordField = ElloTextField()
    private let submitButton = StyledButton(style: .editorialJoin)

    var onJoinChange: ((Editorial.JoinInfo) -> Void)?

    private var isValid: Bool {
        guard
            let email = emailField.text,
            let username = usernameField.text,
            let password = passwordField.text
        else { return false }

        return Validator.hasValidSignUpCredentials(
            email: email,
            username: username,
            password: password
        )
    }

    @objc
    func submitTapped() {
        guard
            let email = emailField.text,
            let username = usernameField.text,
            let password = passwordField.text
        else { return }

        let info: Editorial.JoinInfo = (
            email: emailField.text, username: usernameField.text, password: passwordField.text,
            submitted: true
        )
        onJoinChange?(info)

        emailField.isEnabled = false
        usernameField.isEnabled = false
        passwordField.isEnabled = false
        submitButton.isEnabled = false

        let responder: EditorialToolsResponder? = findResponder()
        responder?.submitJoin(
            cell: self.editorialCell,
            email: email,
            username: username,
            password: password
        )
    }

    override func style() {
        super.style()

        joinLabel.text = InterfaceString.Editorials.Join
        joinLabel.isMultiline = true
        joinCaption.text = InterfaceString.Editorials.JoinCaption
        joinCaption.isMultiline = true
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
        submitButton.title = InterfaceString.Editorials.SubmitJoin
    }

    override func updateConfig() {
        super.updateConfig()

        emailField.text = config.join?.email
        usernameField.text = config.join?.username
        passwordField.text = config.join?.password

        let enabled = !(config.join?.submitted ?? false)
        emailField.isEnabled = enabled
        usernameField.isEnabled = enabled
        passwordField.isEnabled = enabled
        submitButton.isEnabled = enabled
    }

    override func bindActions() {
        super.bindActions()

        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        emailField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        usernameField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    override func arrange() {
        super.arrange()

        editorialContentView.addSubview(joinLabel)
        editorialContentView.addSubview(joinCaption)
        editorialContentView.addSubview(emailField)
        editorialContentView.addSubview(usernameField)
        editorialContentView.addSubview(passwordField)
        editorialContentView.addSubview(submitButton)

        joinLabel.snp.makeConstraints { make in
            make.top.equalTo(editorialContentView).inset(Size.smallTopMargin)
            make.leading.equalTo(editorialContentView).inset(Size.defaultMargin)
            make.trailing.lessThanOrEqualTo(editorialContentView).inset(Size.defaultMargin)
                .priority(Priority.required)
        }

        joinCaption.snp.makeConstraints { make in
            make.top.equalTo(joinLabel.snp.bottom).offset(Size.textFieldMargin)
            make.leading.equalTo(editorialContentView).inset(Size.defaultMargin)
            make.trailing.lessThanOrEqualTo(editorialContentView).inset(Size.defaultMargin)
                .priority(Priority.required)
        }

        let fields = [emailField, usernameField, passwordField]
        fields.forEach { field in
            field.snp.makeConstraints { make in
                make.leading.trailing.equalTo(editorialContentView).inset(Size.defaultMargin)
            }
        }

        submitButton.snp.makeConstraints { make in
            make.height.equalTo(Size.buttonHeight).priority(Priority.required)
            make.bottom.equalTo(editorialContentView).offset(-Size.defaultMargin.bottom)
            make.leading.trailing.equalTo(editorialContentView).inset(Size.defaultMargin)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()  // why-t-f is this necessary!?

        // doing this simple height calculation in auto layout was a total waste of time
        let fields = [emailField, usernameField, passwordField]
        let textFieldsBottom = frame.height - Size.defaultMargin.bottom - Size.buttonHeight
            - Size.textFieldMargin
        var remainingHeight = textFieldsBottom - joinCaption.frame.maxY - Size.textFieldMargin
            - CGFloat(fields.count) * Size.joinMargin
        if remainingHeight < Size.minFieldHeight * 3 {
            joinCaption.isHidden = true
            remainingHeight += joinCaption.frame.height + Size.textFieldMargin
        }
        else {
            joinCaption.isVisible = true
        }
        let fieldHeight: CGFloat = min(
            max(ceil(remainingHeight / 3), Size.minFieldHeight),
            Size.maxFieldHeight
        )
        var y: CGFloat = textFieldsBottom
        for field in fields.reversed() {
            y -= fieldHeight
            field.frame.origin.y = y
            field.frame.size.height = fieldHeight
            y -= Size.joinMargin
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onJoinChange = nil
    }
}

extension EditorialJoinCell {
    @objc
    func textFieldDidChange() {
        let info: Editorial.JoinInfo = (
            email: emailField.text, username: usernameField.text, password: passwordField.text,
            submitted: false
        )
        onJoinChange?(info)
        submitButton.isEnabled = isValid
    }
}
