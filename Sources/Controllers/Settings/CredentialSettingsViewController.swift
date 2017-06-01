////
///  CredentialSettingsViewController.swift
//

private let CredentialSettingsSubmitViewHeight: CGFloat = 128

@objc
protocol CredentialSettingsResponder: class {
    func credentialSettingsUserChanged(_ user: User)
    func credentialSettingsDidUpdate()
}

private enum CredentialSettingsRow: Int {
    case username
    case email
    case password
    case submit
    case unknown
}

class CredentialSettingsViewController: UITableViewController {
    weak var usernameView: ElloTextFieldView!
    weak var emailView: ElloTextFieldView!
    weak var passwordView: ElloTextFieldView!
    @IBOutlet weak var currentPasswordField: ElloTextField!
    weak var errorLabel: StyledLabel!
    @IBOutlet weak var saveButton: StyledButton!

    var currentUser: User? {
        didSet {
            if isViewLoaded {
                setupViews()
            }
        }
    }

    var validationCancel: BasicBlock?

    var isUpdatable: Bool {
        return currentUser?.username != usernameView.textField.text
            || currentUser?.profile?.email != emailView.textField.text
            || passwordView.textField.text?.isEmpty == false
    }

    var height: CGFloat {
        let cellHeights = usernameView.height + emailView.height + passwordView.height
        return cellHeights + (isUpdatable ? submitViewHeight : 0)
    }

    fileprivate var password: String { return passwordView.textField.text ?? "" }
    fileprivate var currentPassword: String { return currentPasswordField.text ?? "" }
    fileprivate var username: String { return usernameView.textField.text ?? "" }
    fileprivate var email: String { return emailView.textField.text ?? "" }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    fileprivate func setupViews() {
        ElloTextFieldView.styleAsUsername(usernameView)
        usernameView.textField.keyboardAppearance = .dark
        usernameView.textField.text = currentUser?.username
        usernameView.textFieldDidChange = self.usernameChanged

        ElloTextFieldView.styleAsEmail(emailView)
        emailView.textField.keyboardAppearance = .dark
        emailView.textField.text = currentUser?.profile?.email
        emailView.textFieldDidChange = self.emailChanged

        ElloTextFieldView.styleAsPassword(passwordView)
        passwordView.textField.keyboardAppearance = .dark
        passwordView.textFieldDidChange = self.passwordChanged

        currentPasswordField.keyboardAppearance = .dark
        currentPasswordField.addTarget(self, action: #selector(CredentialSettingsViewController.currentPasswordChanged), for: .editingChanged)

        tableView.scrollsToTop = false
    }

    fileprivate func emailChanged(_ text: String) {
        self.emailView.setState(.loading)
        self.emailView.setErrorMessage("")
        self.updateView()

        self.validationCancel?()
        self.validationCancel = cancelableDelay(0.5) { [unowned self] in
            if text.isEmpty {
                self.emailView.setState(.error)
                self.updateView()
            } else if text == self.currentUser?.profile?.email {
                self.emailView.setState(.none)
                self.updateView()
            } else if Validator.isValidEmail(text) {
                AvailabilityService().emailAvailability(text, success: { availability in
                    if text != self.emailView.textField.text { return }
                    let state: ValidationState = availability.isEmailAvailable ? .ok : .error

                    if !availability.isEmailAvailable {
                        let msg = InterfaceString.Validator.EmailInvalid
                        self.emailView.setErrorMessage(msg)
                    }
                    self.emailView.setState(state)
                    self.updateView()
                }, failure: { _, _ in
                    self.emailView.setState(.none)
                    self.updateView()
                })
            } else {
                self.emailView.setState(.error)
                let msg = InterfaceString.Validator.EmailInvalid
                self.emailView.setErrorMessage(msg)
                self.updateView()
            }
        }
    }

    fileprivate func usernameChanged(_ text: String) {
        self.usernameView.setState(.loading)
        self.usernameView.setErrorMessage("")
        self.usernameView.setMessage("")
        self.updateView()

        self.validationCancel?()
        self.validationCancel = cancelableDelay(0.5) { [unowned self] in
            if text.isEmpty {
                self.usernameView.setState(.error)
                self.updateView()
            } else if text == self.currentUser?.username {
                self.usernameView.setState(.none)
                self.updateView()
            } else {
                AvailabilityService().usernameAvailability(text, success: { availability in
                    if text != self.usernameView.textField.text { return }
                    let state: ValidationState = availability.isUsernameAvailable ? .ok : .error

                    if !availability.isUsernameAvailable {
                        let msg = InterfaceString.Join.UsernameUnavailable
                        self.usernameView.setErrorMessage(msg)
                        if !availability.usernameSuggestions.isEmpty {
                            let suggestions = availability.usernameSuggestions.joined(separator: ", ")
                            let msg = String(format: InterfaceString.Join.UsernameSuggestionPrefix, suggestions)
                            self.usernameView.setMessage(msg)
                        }
                    }
                    self.usernameView.setState(state)
                    self.updateView()
                }, failure: { _, _ in
                    self.usernameView.setState(.none)
                    self.updateView()
                })
            }
        }
    }

    fileprivate func passwordChanged(_ text: String) {
        self.passwordView.setErrorMessage("")

        if text.isEmpty {
            self.passwordView.setState(.none)
        } else if Validator.isValidPassword(text) {
            self.passwordView.setState(.ok)
        } else {
            self.passwordView.setState(.error)
            let msg = InterfaceString.Validator.PasswordInvalid
            self.passwordView.setErrorMessage(msg)
        }

        self.updateView()
    }

    fileprivate func updateView() {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        valueChanged()
    }

    func valueChanged() {
        let responder: CredentialSettingsResponder? = findResponder()
        responder?.credentialSettingsDidUpdate()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch CredentialSettingsRow(rawValue: indexPath.row) ?? .unknown {
        case .username: return usernameView.height
        case .email: return emailView.height
        case .password: return passwordView.height
        case .submit: return submitViewHeight
        case .unknown: return 0
        }
    }

    fileprivate var submitViewHeight: CGFloat {
        let height = CredentialSettingsSubmitViewHeight
        return height + (errorLabel.text?.isEmpty == false ? errorLabel.frame.height + 8 : 0)
    }

    func currentPasswordChanged() {
        saveButton.isEnabled = Validator.isValidPassword(currentPassword)
    }

    @IBAction func saveButtonTapped() {
        var content: [String: Any] = [
            "username": username,
            "email": email,
            "current_password": currentPassword
        ]

        if !currentPassword.isEmpty {
            content["password"] = password
            content["password_confirmation"] = password
        }

        ProfileService().updateUserProfile(content, success: { [weak self] user in
            guard let `self` = self else { return }
            let responder = self.target(forAction: #selector(CredentialSettingsResponder.credentialSettingsUserChanged(_:)), withSender: self) as? CredentialSettingsResponder
            responder?.credentialSettingsUserChanged(user)
            self.resetViews()
        }, failure: { [weak self] error, _ in
            guard let `self` = self else { return }
            self.currentPasswordField.text = ""
            self.passwordView.textField.text = ""

            if let err = error.userInfo[NSLocalizedFailureReasonErrorKey] as? ElloNetworkError {
                self.handleError(err)
            }
        })
    }

    fileprivate func resetViews() {
        currentPasswordField.text = ""
        passwordView.textField.text = ""
        errorLabel.text = ""
        usernameView.clearState()
        emailView.clearState()
        passwordView.clearState()
        currentPasswordChanged()
        updateView()
    }

    fileprivate func handleError(_ error: ElloNetworkError) {
        if let message = error.attrs?["password"] {
            passwordView.setErrorMessage(message.first ?? "")
        }

        if let message = error.attrs?["email"] {
            emailView.setErrorMessage(message.first ?? "")
        }

        if let message = error.attrs?["username"] {
            usernameView.setErrorMessage(message.first ?? "")
        }

        errorLabel.text = error.messages?.first
        errorLabel.sizeToFit()

        updateView()
    }
}

extension CredentialSettingsViewController {
    class func instantiateFromStoryboard() -> CredentialSettingsViewController {
        return UIStoryboard(name: "Settings", bundle: Bundle(for: AppDelegate.self)).instantiateViewController(withIdentifier: "CredentialSettingsViewController") as! CredentialSettingsViewController
    }
}

extension CredentialSettingsViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        tableView.setContentOffset(.zero, animated: false)
    }
}
