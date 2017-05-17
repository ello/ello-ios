////
///  EditorialJoinCell.swift
//

class EditorialJoinCell: EditorialCell {
    fileprivate let joinLabel = StyledLabel(style: .largerWhite)
    fileprivate let emailField = ElloTextField()
    fileprivate let usernameField = ElloTextField()
    fileprivate let passwordField = ElloTextField()
    fileprivate let submitButton = StyledButton(style: .editorialJoin)

    override func style() {
        super.style()

        submitButton.isEnabled = false
        joinLabel.text = InterfaceString.Editorials.Join
        ElloTextFieldView.styleAsEmailField(emailField)
        ElloTextFieldView.styleAsUsernameField(usernameField)
        ElloTextFieldView.styleAsPasswordField(passwordField)
        emailField.placeholder = InterfaceString.Editorials.EmailPlaceholder
        usernameField.placeholder = InterfaceString.Editorials.UsernamePlaceholder
        passwordField.placeholder = InterfaceString.Editorials.PasswordPlaceholder
        submitButton.setTitle(InterfaceString.Editorials.Submit, for: .normal)
    }

    override func arrange() {
        super.arrange()

        contentView.addSubview(joinLabel)
        contentView.addSubview(emailField)
        contentView.addSubview(usernameField)
        contentView.addSubview(passwordField)
        contentView.addSubview(submitButton)

        joinLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(Size.smallTopMargin)
            make.leading.equalTo(contentView).inset(Size.defaultMargin)
            make.trailing.lessThanOrEqualTo(contentView).inset(Size.defaultMargin).priority(Priority.required)
        }

        let fields = [emailField, usernameField, passwordField]
        fields.eachPair { prevField, field in
            field.snp.makeConstraints { make in
                make.leading.trailing.equalTo(contentView).inset(Size.defaultMargin)
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
            make.height.equalTo(fields.last!)
            make.top.equalTo(fields.last!.snp.bottom).offset(Size.textFieldMargin)
            make.bottom.equalTo(contentView).offset(-Size.defaultMargin)
            make.leading.trailing.equalTo(contentView).inset(Size.defaultMargin)
        }
    }
}
