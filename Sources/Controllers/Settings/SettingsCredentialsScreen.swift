////
///  SettingsCredentialsScreen.swift
//

import SnapKit


class SettingsCredentialsScreen: NavBarScreen, SettingsCredentialsScreenProtocol {
    struct Size {
        static let defaultMargin: CGFloat = 15
        static let credentialsDescriptionHeight: CGFloat = 100
    }

    weak var delegate: SettingsCredentialsScreenDelegate?

    var username: String? {
        get { return usernameField.textField.text }
        set { usernameField.textField.text = newValue }
    }
    var email: String? {
        get { return emailField.textField.text }
        set { emailField.textField.text = newValue }
    }
    var password: String? {
        get { return passwordField.textField.text }
        set { passwordField.textField.text = newValue }
    }
    var oldPassword: String? {
        get { return oldPasswordField.textField.text }
        set { oldPasswordField.textField.text = newValue }
    }

    private var navigationInsets: UIEdgeInsets = .zero { didSet { updateInsets() }}
    private var bottomInset: CGFloat = 0 { didSet { updateInsets() }}

    private var widthConstraint: Constraint!
    private let scrollView = UIScrollView()
    private let credentialsDescription = StyledLabel(style: .lightGray)
    private let oldPasswordField = ElloTextFieldView()
    private let usernameField = ElloTextFieldView()
    private let emailField = ElloTextFieldView()
    private let passwordField = ElloTextFieldView()

    override func style() {
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }

        ElloTextFieldView.styleAsPassword(oldPasswordField, returnKey: .next)
        ElloTextFieldView.styleAsUsername(usernameField)
        ElloTextFieldView.styleAsEmail(emailField)
        ElloTextFieldView.styleAsPassword(passwordField)

        navigationBar.leftItems = [.back]
        navigationBar.rightItems = [.close]
        credentialsDescription.isMultiline = true
    }

    override func setText() {
        navigationBar.title = InterfaceString.Settings.EditCredentials
        credentialsDescription.text = InterfaceString.Settings.CredentialsSettings
        oldPasswordField.title = InterfaceString.Settings.OldPassword
    }

    override func arrange() {
        arrange(contentView: scrollView)

        scrollView.addSubview(credentialsDescription)
        scrollView.addSubview(oldPasswordField)
        scrollView.addSubview(usernameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }

        credentialsDescription.snp.makeConstraints { make in
            make.top.equalTo(scrollView)
            make.leading.trailing.equalTo(scrollView).inset(Size.defaultMargin)
            make.height.equalTo(Size.credentialsDescriptionHeight)
        }

        let fields: [UIView] = [
            oldPasswordField,
            usernameField,
            emailField,
            passwordField,
        ]

        fields.eachPair { prevField, field, isLast in
            field.snp.makeConstraints { make in
                make.leading.trailing.equalTo(scrollView)

                if let prevField = prevField {
                    make.top.equalTo(prevField.snp.bottom)
                }
                else {
                    make.top.equalTo(credentialsDescription.snp.bottom)
                }

                if isLast {
                    make.bottom.equalTo(scrollView)
                    widthConstraint = make.width.equalTo(frame.width).priority(Priority.required).constraint
                }
            }
        }

        navigationInsets.top = ElloNavigationBar.Size.height
        navigationInsets.bottom = ElloTabBar.Size.height
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        widthConstraint.update(offset: frame.width)
    }

    private func updateInsets() {
        var insets = navigationInsets
        insets.bottom = max(navigationInsets.bottom, bottomInset)
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
    }

    func keyboardUpdated(_ keyboard: Keyboard) {
        bottomInset = keyboard.keyboardBottomInset(inView: self)
    }

    func showError(_ error: String?) {
        if let error = error {
            credentialsDescription.style = .error
            credentialsDescription.text = error
        }
        else {
            credentialsDescription.style = .lightGray
            credentialsDescription.text = InterfaceString.Settings.CredentialsSettings
        }
    }
}
