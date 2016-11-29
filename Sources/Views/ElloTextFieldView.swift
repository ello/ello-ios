////
///  ElloTextFieldView.swift
//

import Foundation

private let ElloTextFieldViewHeight: CGFloat = 89.0

public class ElloTextFieldView: UIView {
    public weak var label: ElloToggleLabel!
    @IBOutlet public weak var textField: ElloTextField!
    public weak var errorLabel: ElloErrorLabel!
    public weak var messageLabel: ElloLabel!

    @IBOutlet private var errorLabelHeight: NSLayoutConstraint!
    @IBOutlet private var messageLabelHeight: NSLayoutConstraint!
    @IBOutlet private weak var errorLabelSeparationSpacing: NSLayoutConstraint!

    public var textFieldDidChange: (String -> Void)?
    public var firstResponderDidChange: (Bool -> Void)? {
        get { return textField.firstResponderDidChange }
        set { textField.firstResponderDidChange = newValue }
    }

    var height: CGFloat {
        var height = ElloTextFieldViewHeight
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

    public var hasError: Bool { return !(errorLabel.text?.isEmpty ?? true) }
    public var hasMessage: Bool { return !(messageLabel.text?.isEmpty ?? true) }
    var errorHeight: CGFloat {
        if hasError {
            return errorLabel.sizeThatFits(CGSize(width: errorLabel.frame.width, height: 0)).height
        }
        else {
            return 0
        }
    }
    var messageHeight: CGFloat {
        if hasMessage {
            return messageLabel.sizeThatFits(CGSize(width: messageLabel.frame.width, height: 0)).height
        }
        else {
            return 0
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        let view: UIView = loadFromNib()
        view.frame = bounds
        view.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        addSubview(view)
        textField.addTarget(self, action: #selector(valueChanged), forControlEvents: .EditingChanged)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let view: UIView = loadFromNib()
        view.frame = bounds
        view.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        addSubview(view)
        textField.addTarget(self, action: #selector(valueChanged), forControlEvents: .EditingChanged)
    }

    override public func updateConstraints() {
        updateErrorConstraints()
        super.updateConstraints()
    }

    func setState(state: ValidationState) {
        textField.validationState = state
    }

    func valueChanged() {
        setNeedsUpdateConstraints()
        if let textFieldDidChange = textFieldDidChange, text = textField.text {
            textFieldDidChange(text)
        }
    }

    func setErrorMessage(message: String) {
        errorLabel.setLabelText(message)
        setNeedsUpdateConstraints()
        self.invalidateIntrinsicContentSize()
    }

    func setMessage(message: String) {
        messageLabel.setLabelText(message)
        messageLabel.textColor = UIColor.blackColor()
        setNeedsUpdateConstraints()
        self.invalidateIntrinsicContentSize()
    }

    override public func layoutIfNeeded() {
        super.layoutIfNeeded()
        self.label.layoutIfNeeded()
        self.textField.layoutIfNeeded()
        self.messageLabel.layoutIfNeeded()
        self.errorLabel.layoutIfNeeded()
    }

    override public func intrinsicContentSize() -> CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: height)
    }

    private func updateErrorConstraints() {
        errorLabelSeparationSpacing.active = errorHeight > 0 && messageHeight > 0
        errorLabelHeight.constant = errorHeight
        messageLabelHeight.constant = messageHeight
    }

    func clearState() {
        textField.validationState = .None
        setErrorMessage("")
        setMessage("")
    }

    override public func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }

    override public func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }

}


public extension ElloTextFieldView {
    private class func styleCommonField(textField: UITextField) {
        textField.text = ""
        textField.autocapitalizationType = .None
        textField.autocorrectionType = .No
        textField.spellCheckingType = .No
        textField.enablesReturnKeyAutomatically = true
        textField.keyboardAppearance = .Dark
    }

    class func styleAsUsername(usernameView: ElloTextFieldView) {
        usernameView.label.setLabelText(InterfaceString.Join.Username)
        styleAsUsernameField(usernameView.textField)
    }
    class func styleAsUsernameField(textField: UITextField) {
        styleCommonField(textField)
        textField.returnKeyType = .Next
        textField.keyboardType = .ASCIICapable
    }

    class func styleAsEmail(emailView: ElloTextFieldView) {
        emailView.label.setLabelText(InterfaceString.Join.Email)
        styleAsEmailField(emailView.textField)
    }
    class func styleAsEmailField(textField: UITextField) {
        styleCommonField(textField)
        textField.returnKeyType = .Next
        textField.keyboardType = .EmailAddress
    }

    class func styleAsPassword(passwordView: ElloTextFieldView) {
        passwordView.label.setLabelText(InterfaceString.Join.Password)
        styleAsPasswordField(passwordView.textField)
    }
    class func styleAsPasswordField(textField: UITextField) {
        styleCommonField(textField)
        textField.returnKeyType = .Go
        textField.keyboardType = .Default
        textField.secureTextEntry = true
    }

}
