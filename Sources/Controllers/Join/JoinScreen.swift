////
///  JoinScreen.swift
//

import SnapKit


class JoinScreen: CredentialsScreen {
    struct Size {
        static let promptTopMargin: CGFloat = 50
        static let promptInset: CGFloat = 20
        static let fieldsTopMargin: CGFloat = 55
        static let fieldsErrorMargin: CGFloat = 15
        static let fieldsInnerMargin: CGFloat = 30
        static let termsFontSize: CGFloat = 11
        static let termsBottomInset: CGFloat = 5
    }

    weak var delegate: JoinScreenDelegate?

    var prompt: String? {
        get { promptLabel.text }
        set { promptLabel.text = newValue }
    }
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
        get { emailField.text?.trimmingCharacters(in: CharacterSet.whitespaces) ?? "" }
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
        get { usernameField.text?.trimmingCharacters(in: CharacterSet.whitespaces) ?? "" }
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
        get { passwordField.text ?? "" }
        set { passwordField.text = newValue }
    }
    var isTermsChecked: Bool {
        get { termsToggle.isOn }
        set { termsToggle.isOn = newValue }
    }
    var isOnePasswordAvailable = false {
        didSet { passwordField.hasOnePassword = isOnePasswordAvailable }
    }
    var nonceRequestFailed: Bool? {
        didSet {
            nonceErrorLabel.isVisible = nonceRequestFailed == true
        }
    }

    var isScreenReady: Bool = false {
        didSet { updateContinueButton() }
    }

    private let promptLabel = StyledLabel(style: .smallWhite)
    private let nonceErrorLabel = StyledLabel(style: .error)

    private let emailField = ClearTextField()
    private let activateEmailButton = UIButton()
    private let emailErrorLabel = StyledLabel(style: .smallWhite)
    private var emailMarginConstraint: Constraint!

    private let usernameField = ClearTextField()
    private let activateUsernameButton = UIButton()
    private let usernameErrorLabel = StyledLabel(style: .smallWhite)
    private var usernameMarginConstraint: Constraint!

    private let passwordField = ClearTextField()
    private let activatePasswordButton = UIButton()
    private let passwordErrorLabel = StyledLabel(style: .smallWhite)
    private var passwordMarginConstraint: Constraint!

    private var termsToggle = UISwitch()
    private var termsLabel = ElloTextView()
    private let termsErrorLabel = StyledLabel(style: .smallWhite)
    private var termsMarginConstraint: Constraint!

    private let usernameSuggestionsLabel = StyledLabel(style: .smallWhite)
    private var usernameSuggestionsMarginConstraint: Constraint!

    override func setText() {
        titleLabel.text = InterfaceString.Startup.SignUp
        continueButton.title = InterfaceString.Join.Discover
        emailField.placeholder = InterfaceString.Join.EmailPlaceholder
        usernameField.placeholder = InterfaceString.Join.UsernamePlaceholder
        passwordField.placeholder = InterfaceString.Join.PasswordPlaceholder
        nonceErrorLabel.text = InterfaceString.Join.FetchNonceError
        termsLabel.attributedText = InterfaceString.Join.Terms(
            textAttrs: NSAttributedString.defaultAttrs([
                .foregroundColor: UIColor.greyA,
                .font: UIFont.defaultFont(Size.termsFontSize),
            ])
        )
    }

    override func bindActions() {
        super.bindActions()

        continueButton.addTarget(self, action: #selector(submitAction), for: .touchUpInside)
        passwordField.onePasswordButton.addTarget(
            self,
            action: #selector(onePasswordAction(_:)),
            for: .touchUpInside
        )
        activateEmailButton.addTarget(self, action: #selector(activateEmail), for: .touchUpInside)
        activateUsernameButton.addTarget(
            self,
            action: #selector(activateUsername),
            for: .touchUpInside
        )
        activatePasswordButton.addTarget(
            self,
            action: #selector(activatePassword),
            for: .touchUpInside
        )
        emailField.delegate = self
        usernameField.delegate = self
        passwordField.delegate = self
        termsLabel.textViewDelegate = self
    }

    override func setup() {
        continueButton.isEnabled = false
        nonceErrorLabel.isVisible = false
    }

    override func style() {
        super.style()

        ElloTextFieldView.styleAsEmailField(emailField)
        ElloTextFieldView.styleAsUsernameField(usernameField)
        ElloTextFieldView.styleAsPasswordField(passwordField)
        passwordField.returnKeyType = .join
        passwordField.hasOnePassword = isOnePasswordAvailable

        promptLabel.isMultiline = true
        usernameSuggestionsLabel.isMultiline = true
        nonceErrorLabel.isMultiline = true
        termsLabel.backgroundColor = .clear

        continueBackground.backgroundColor = .white
    }

    override func arrange() {
        super.arrange()

        scrollView.addSubview(nonceErrorLabel)
        scrollView.addSubview(promptLabel)
        scrollView.addSubview(activateEmailButton)
        scrollView.addSubview(emailField)
        scrollView.addSubview(emailErrorLabel)
        scrollView.addSubview(activateUsernameButton)
        scrollView.addSubview(usernameField)
        scrollView.addSubview(usernameErrorLabel)
        scrollView.addSubview(usernameSuggestionsLabel)
        scrollView.addSubview(activatePasswordButton)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(passwordErrorLabel)
        scrollView.addSubview(termsToggle)
        scrollView.addSubview(termsLabel)
        scrollView.addSubview(termsErrorLabel)

        nonceErrorLabel.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(CredentialsScreen.Size.inset)
            make.leading.trailing.equalTo(scrollView).inset(CredentialsScreen.Size.inset)
        }

        promptLabel.snp.makeConstraints { make in
            make.top.equalTo(scrollView).offset(Size.promptTopMargin)
            make.leading.trailing.equalTo(scrollView).inset(Size.promptInset)
        }

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
            emailMarginConstraint =
                make.top.equalTo(emailField.snp.bottom).offset(Size.fieldsErrorMargin).priority(
                    Priority.required
                ).constraint
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
            usernameMarginConstraint =
                make.top.equalTo(usernameField.snp.bottom).offset(Size.fieldsErrorMargin).priority(
                    Priority.required
                ).constraint
            make.top.equalTo(usernameField.snp.bottom).priority(Priority.medium)
            make.leading.trailing.equalTo(scrollView).inset(CredentialsScreen.Size.inset)
        }
        usernameMarginConstraint.deactivate()

        usernameSuggestionsLabel.snp.makeConstraints { make in
            usernameSuggestionsMarginConstraint =
                make.top.equalTo(usernameErrorLabel.snp.bottom).offset(Size.fieldsErrorMargin)
                .priority(Priority.required).constraint
            make.top.equalTo(usernameErrorLabel.snp.bottom).priority(Priority.medium)
            make.leading.trailing.equalTo(scrollView).inset(CredentialsScreen.Size.inset)
        }
        usernameSuggestionsMarginConstraint.deactivate()

        activatePasswordButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(scrollView)
            make.centerY.equalTo(passwordField)
            make.height.equalTo(passwordField).offset(Size.fieldsInnerMargin)
        }
        passwordField.snp.makeConstraints { make in
            make.top.equalTo(usernameSuggestionsLabel.snp.bottom).offset(Size.fieldsInnerMargin)
            make.leading.trailing.equalTo(scrollView).inset(CredentialsScreen.Size.inset)
        }
        passwordErrorLabel.snp.makeConstraints { make in
            passwordMarginConstraint =
                make.top.equalTo(passwordField.snp.bottom).offset(Size.fieldsErrorMargin).priority(
                    Priority.required
                ).constraint
            make.top.equalTo(passwordField.snp.bottom).priority(Priority.medium)
            make.leading.trailing.equalTo(scrollView).inset(CredentialsScreen.Size.inset)
            make.bottom.lessThanOrEqualTo(scrollView).inset(Size.inset)
        }
        passwordMarginConstraint.deactivate()

        termsToggle.snp.makeConstraints { make in
            make.leading.equalTo(passwordField)
            make.top.equalTo(passwordErrorLabel.snp.bottom).offset(Size.fieldsInnerMargin)
        }
        termsLabel.snp.makeConstraints { make in
            make.leading.equalTo(termsToggle.snp.trailing).offset(Size.inset)
            make.centerY.equalTo(termsToggle)
        }

        termsErrorLabel.snp.makeConstraints { make in
            termsMarginConstraint =
                make.top.equalTo(termsToggle.snp.bottom).offset(Size.fieldsErrorMargin).priority(
                    Priority.required
                ).constraint
            make.top.equalTo(termsToggle.snp.bottom).priority(Priority.medium)
            make.leading.trailing.equalTo(scrollView).inset(CredentialsScreen.Size.inset)
            make.bottom.lessThanOrEqualTo(scrollView).inset(Size.inset)
        }
        termsMarginConstraint.deactivate()
    }

    override func resignFirstResponder() -> Bool {
        _ = emailField.resignFirstResponder()
        _ = usernameField.resignFirstResponder()
        _ = passwordField.resignFirstResponder()
        return super.resignFirstResponder()
    }

    override func backAction() {
        delegate?.backAction()
    }
}

extension JoinScreen {
    func allFieldsValid() -> Bool {
        guard
            let isEmailValid = isEmailValid,
            let isUsernameValid = isUsernameValid,
            let isPasswordValid = isPasswordValid
        else {
            return false
        }

        return isEmailValid && isUsernameValid && isPasswordValid && isTermsChecked
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
    func onePasswordAction(_ sender: UIView) {
        delegate?.onePasswordAction(sender)
    }
}

extension JoinScreen: UITextFieldDelegate {

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
        let usernameAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.defaultFont(12),
            .underlineStyle: NSUnderlineStyle.single.rawValue,
        ]
        let plainAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.defaultFont(12),
        ]
        let suggestions: NSAttributedString = usernames.reduce(
            NSAttributedString(string: "", attributes: plainAttrs)
        ) { attrdString, username in
            let usernameAttrd = NSAttributedString(string: username, attributes: usernameAttrs)
            if attrdString.string.isEmpty {
                return usernameAttrd
            }
            return attrdString + NSAttributedString(string: ", ", attributes: plainAttrs)
                + usernameAttrd
        }
        let msg = NSAttributedString(
            string: InterfaceString.Join.UsernameSuggestionPrefix,
            attributes: plainAttrs
        ) + suggestions
        showUsernameSuggestions(msg)
    }

    func showUsernameSuggestions(_ attrd: NSAttributedString) {
        usernameSuggestionsLabel.attributedText = attrd

        elloAnimate {
            self.usernameSuggestionsMarginConstraint.activate()
            self.usernameSuggestionsLabel.alpha = 1.0
            self.layoutIfNeeded()
        }
    }

    func hideUsernameSuggestions() {
        elloAnimate {
            self.usernameSuggestionsMarginConstraint.deactivate()
            self.usernameSuggestionsLabel.alpha = 0.0
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

    func showTermsError(_ text: String) {
        termsErrorLabel.text = text

        elloAnimate {
            self.termsMarginConstraint.activate()
            self.termsErrorLabel.alpha = 1.0
            self.layoutIfNeeded()
        }
    }

    func hideTermsError() {
        elloAnimate {
            self.termsMarginConstraint.deactivate()
            self.termsErrorLabel.alpha = 0.0
            self.layoutIfNeeded()
        }
    }

    func showError(_ text: String) {
        showPasswordError(text)
    }

    func updateContinueButton() {
        continueButton.isEnabled = true
    }
}

extension JoinScreen: ElloTextViewDelegate {
    func textViewTappedDefault() {
        termsToggle.setOn(!termsToggle.isOn, animated: true)
    }

    func textViewTapped(_ link: String, object: ElloAttributedObject) {
        guard case let .attributedURL(title, url) = object else { return }
        delegate?.urlAction(title: title, url: url)
    }
}
