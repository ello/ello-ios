////
///  ElloTextFieldView.swift
//

import SnapKit


class ElloTextFieldView: View {
    struct Size {
        static let margins = UIEdgeInsets(tops: 8, sides: 15)
        static let verticalSpacing: CGFloat = 8
        static let height: CGFloat = 89
    }

    var title: String? {
        get { return label.text }
        set { label.text = newValue }
    }
    var text: String? {
        get { return textField.text }
        set { textField.text = newValue }
    }

    let textField = ElloTextField()
    let label = StyledLabel(style: .lightGray)

    private let errorLabel = StyledLabel(style: .error)
    private let messageLabel = StyledLabel(style: .black)
    private var errorLabelHeight: Constraint!
    private var messageLabelHeight: Constraint!
    private var errorLabelSeparationSpacing: Constraint!

    var textFieldDidChange: ((String) -> Void)?
    var firstResponderDidChange: BoolBlock? {
        get { return textField.firstResponderDidChange }
        set { textField.firstResponderDidChange = newValue }
    }

    var height: CGFloat {
        var height = Size.height
        if hasError {
            height += errorHeight
            if hasMessage {
                height += 20
            }
            else {
                height += 8
            }
        }
        if hasMessage {
            height += messageHeight + 8
        }
        return height
    }

    private var hasError: Bool { return !(errorLabel.text?.isEmpty ?? true) }
    private var hasMessage: Bool { return !(messageLabel.text?.isEmpty ?? true) }

    private var errorHeight: CGFloat {
        if hasError {
            return errorLabel.sizeThatFits(CGSize(width: errorLabel.frame.width, height: 0)).height
        }
        else {
            return 0
        }
    }
    private var messageHeight: CGFloat {
        if hasMessage {
            return messageLabel.sizeThatFits(CGSize(width: messageLabel.frame.width, height: 0)).height
        }
        else {
            return 0
        }
    }

    override func style() {
        textField.keyboardAppearance = .dark
    }

    override func arrange() {
        addSubview(label)
        addSubview(textField)
        addSubview(errorLabel)
        addSubview(messageLabel)

        label.snp.makeConstraints { make in
            make.leading.top.equalTo(self).inset(Size.margins)
        }

        textField.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(Size.verticalSpacing)
            make.leading.trailing.equalTo(self).inset(Size.margins)
        }

        errorLabel.snp.makeConstraints { make in
            errorLabelHeight = make.height.equalTo(0).constraint

            make.top.equalTo(textField.snp.bottom).offset(Size.verticalSpacing)
            make.leading.equalTo(self).inset(Size.margins)
        }

        messageLabel.snp.makeConstraints { make in
            messageLabelHeight = make.height.equalTo(0).constraint
            errorLabelSeparationSpacing = make.top.equalTo(errorLabel.snp.bottom).offset(Size.verticalSpacing).constraint
            make.leading.bottom.equalTo(self).inset(Size.margins)
        }

        textField.addTarget(self, action: #selector(valueChanged), for: .editingChanged)
    }

    override func updateConstraints() {
        updateErrorConstraints()
        super.updateConstraints()
    }

    func setState(_ state: ValidationState) {
        textField.validationState = state
    }

    @objc
    func valueChanged() {
        setNeedsUpdateConstraints()
        if let textFieldDidChange = textFieldDidChange, let text = textField.text {
            textFieldDidChange(text)
        }
    }

    func setErrorMessage(_ message: String) {
        errorLabel.text = message
        setNeedsUpdateConstraints()
        self.invalidateIntrinsicContentSize()
    }

    func setMessage(_ message: String) {
        messageLabel.text = message
        messageLabel.textColor = UIColor.black
        setNeedsUpdateConstraints()
        self.invalidateIntrinsicContentSize()
    }

    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        self.label.layoutIfNeeded()
        self.textField.layoutIfNeeded()
        self.messageLabel.layoutIfNeeded()
        self.errorLabel.layoutIfNeeded()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: height)
    }

    private func updateErrorConstraints() {
        if errorHeight > 0 && messageHeight > 0 {
            errorLabelSeparationSpacing.activate()
        }
        else {
            errorLabelSeparationSpacing.deactivate()
        }
        errorLabelHeight.update(offset: errorHeight)
        messageLabelHeight.update(offset: messageHeight)
    }

    func clearState() {
        textField.validationState = .none
        setErrorMessage("")
        setMessage("")
    }

    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }

}


extension ElloTextFieldView {
    private class func styleCommonField(_ textField: UITextField) {
        textField.text = ""
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.enablesReturnKeyAutomatically = true
        textField.keyboardAppearance = .dark
    }

    class func styleAsUsername(_ usernameView: ElloTextFieldView) {
        usernameView.label.text = InterfaceString.Join.Username
        styleAsUsernameField(usernameView.textField)
    }
    class func styleAsUsernameField(_ textField: UITextField) {
        styleCommonField(textField)
        textField.returnKeyType = .next
        textField.keyboardType = .asciiCapable
    }

    class func styleAsEmail(_ emailView: ElloTextFieldView) {
        emailView.label.text = InterfaceString.Join.Email
        styleAsEmailField(emailView.textField)
    }
    class func styleAsEmailField(_ textField: UITextField) {
        styleCommonField(textField)
        textField.returnKeyType = .next
        textField.keyboardType = .emailAddress
    }

    class func styleAsPassword(_ passwordView: ElloTextFieldView) {
        passwordView.label.text = InterfaceString.Join.Password
        styleAsPasswordField(passwordView.textField)
    }
    class func styleAsPasswordField(_ textField: UITextField) {
        styleCommonField(textField)
        textField.returnKeyType = .go
        textField.keyboardType = .default
        textField.isSecureTextEntry = true
    }

}
