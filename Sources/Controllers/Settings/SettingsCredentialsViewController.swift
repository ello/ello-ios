////
///  SettingsCredentialsViewController.swift
//

class SettingsCredentialsViewController: BaseElloViewController {
    private var _mockScreen: SettingsCredentialsScreenProtocol?
    var screen: SettingsCredentialsScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return fetchScreen(_mockScreen) }
    }

    var keyboardWillShowObserver: NotificationObserver?
    var keyboardDidHideObserver: NotificationObserver?
    var keyboardWillHideObserver: NotificationObserver?

    init(currentUser: User) {
        super.init(nibName: nil, bundle: nil)

        self.currentUser = currentUser
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let screen = SettingsCredentialsScreen()
        screen.delegate = self
        view = screen
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let currentUser = currentUser,
            let profile = currentUser.profile
        {
            screen.username = currentUser.username
            screen.email = profile.email
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        keyboardWillShowObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillShow, block: self.keyboardWillShow)
        keyboardDidHideObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardDidHide, block: self.keyboardDidHide)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        keyboardWillShowObserver?.removeObserver()
        keyboardWillShowObserver = nil
        keyboardDidHideObserver?.removeObserver()
        keyboardDidHideObserver = nil
        keyboardWillHideObserver?.removeObserver()
        keyboardWillHideObserver = nil
    }

    override func goingBackNow(proceed: @escaping Block) {
        let profileUpdates = pendingChanges()
        guard profileUpdates.count > 0 else {
            proceed()
            return
        }

        saveAndExit(profileUpdates) { proceed() }
    }

    override func backButtonTapped() {
        if let responder = view.firstResponder {
            _ = responder.resignFirstResponder()
        }

        let profileUpdates = pendingChanges()
        guard profileUpdates.count > 0 else {
            super.backButtonTapped()
            return
        }

        saveAndExit(profileUpdates) { super.backButtonTapped() }
    }

    override func closeButtonTapped() {
        if pendingChanges().count > 0 {
            let alertController = AlertViewController(message: InterfaceString.Settings.AbortChanges)

            let okCancelAction = AlertAction(style: .okCancel) { _ in
                super.backButtonTapped()
            }
            alertController.addAction(okCancelAction)

            self.present(alertController, animated: true, completion: nil)
        }
        else {
            super.backButtonTapped()
        }
    }

    private func pendingChanges() -> [Profile.Property: Any] {
        var profileUpdates: [Profile.Property: Any] = [:]
        guard let currentUser = currentUser, let profile = currentUser.profile else { return profileUpdates }

        if !(currentUser.username =?= screen.username) {
            profileUpdates[.username] = screen.username ?? ""
        }

        if !(profile.email =?= screen.email) {
            profileUpdates[.email] = screen.email ?? ""
        }

        if !screen.password.isEmpty {
            profileUpdates[.password] = screen.password ?? ""
        }

        return profileUpdates
    }

    private func saveAndExit(_ _profileUpdates: [Profile.Property: Any], onSuccess: @escaping Block) {
        guard
            let oldPassword = screen.oldPassword,
            !oldPassword.isEmpty
        else {
            screen.showError(InterfaceString.Settings.OldPasswordRequired)
            return
        }

        screen.showError(nil)

        var profileUpdates = _profileUpdates
        profileUpdates[.currentPassword] = oldPassword

        view.isUserInteractionEnabled = false
        ElloHUD.showLoadingHudInView(self.view)

        ProfileService().updateUserProfile(profileUpdates)
            .ensure {
                ElloHUD.hideLoadingHudInView(self.view)
            }
            .done { user in
                self.appViewController?.currentUser = user
                onSuccess()
            }
            .catch { error in
                if let error = (error as NSError).elloError,
                    let messages = error.messages
                {
                    let errorMessage = messages.joined(separator: "\n")
                    self.screen.showError(errorMessage)
                }
                else {
                    self.screen.showError(InterfaceString.UnknownError)
                }

                self.view.isUserInteractionEnabled = true
            }
    }
}

extension SettingsCredentialsViewController {
    func keyboardWillShow(_ keyboard: Keyboard) {
        screen.keyboardUpdated(keyboard)
    }

    func keyboardDidHide(_ keyboard: Keyboard) {
        screen.keyboardUpdated(keyboard)
    }
}

extension SettingsCredentialsViewController: SettingsCredentialsScreenDelegate {
}
