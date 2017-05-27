////
///  JoinViewController.swift
//

import OnePasswordExtension

class JoinViewController: BaseElloViewController {
    private var _mockScreen: JoinScreenProtocol?
    var screen: JoinScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return _mockScreen ?? (self.view as! JoinScreen) }
    }

    var invitationCode: String?

    convenience init(email: String, username: String, password: String) {
        self.init(nibName: nil, bundle: nil)
        screen.email = email
        screen.username = username
        screen.password = password
        submit(email: email, username: username, password: password)
    }

    override func loadView() {
        let screen = JoinScreen()
        screen.delegate = self
        screen.onePasswordAvailable = OnePasswordExtension.shared().isAppExtensionAvailable()
        self.view = screen
    }

    fileprivate func showOnboardingScreen(_ user: User) {
        appViewController?.showOnboardingScreen(user)
    }

    fileprivate func showLoginScreen(_ email: String, _ password: String) {
        appViewController?.showLoginScreen()
    }
}

extension JoinViewController: JoinDelegate {
    func backAction() {
        _ = navigationController?.popViewController(animated: true)
    }

    func validate(email: String, username: String, password: String) {
        if Validator.invalidSignUpEmailReason(email) == nil {
            screen.emailValid = true
        }
        else {
            screen.emailValid = nil
        }

        if Validator.invalidSignUpUsernameReason(username) == nil {
            screen.usernameValid = true
        }
        else {
            screen.usernameValid = nil
        }

        if Validator.invalidSignUpPasswordReason(password) == nil {
            screen.passwordValid = true
        }
        else {
            screen.passwordValid = nil
        }
    }

    func submit(email: String, username: String, password: String) {
        Tracker.shared.tappedJoin()

        screen.hideMessage()
        _ = screen.resignFirstResponder()

        if Validator.hasValidSignUpCredentials(email: email, username: username, password: password) {
            screen.hideEmailError()
            screen.hideUsernameError()
            screen.hidePasswordError()
            screen.loadingHUD(visible: true)

            var joinSuccessful = true
            let joinAborted: () -> Void = {
                self.screen.loadingHUD(visible: false)
            }
            let joinContinue = after(2) {
                guard joinSuccessful else {
                    joinAborted()
                    return
                }

                Tracker.shared.joinValid()

                UserService().join(
                    email: email,
                    username: username,
                    password: password,
                    invitationCode: self.invitationCode
                    )
                    .thenFinally { user in
                        let authService = CredentialsAuthService()
                        authService.authenticate(email: email,
                            password: password,
                            success: {
                                Tracker.shared.joinSuccessful()
                                self.showOnboardingScreen(user)
                            },
                            failure: { _, _ in
                                Tracker.shared.joinFailed()
                                self.showLoginScreen(email, password)
                            })
                    }
                    .catch { error in
                        let errorTitle = (error as NSError).elloErrorMessage ?? InterfaceString.UnknownError
                        self.screen.showError(errorTitle)
                        joinAborted()
                    }
            }

            self.emailAvailability(email) { successful in
                joinSuccessful = joinSuccessful && successful
                joinContinue()
            }

            self.usernameAvailability(username) { successful in
                joinSuccessful = joinSuccessful && successful
                joinContinue()
            }
        }
        else {
            Tracker.shared.joinInvalid()
            if let msg = Validator.invalidSignUpEmailReason(email) {
                screen.showEmailError(msg)
            }
            else {
                screen.hideEmailError()
            }

            if let msg = Validator.invalidSignUpUsernameReason(username) {
                screen.showUsernameError(msg)
            }
            else {
                screen.hideUsernameError()
            }

            if let msg = Validator.invalidSignUpPasswordReason(password) {
                screen.showPasswordError(msg)
            }
            else {
                screen.hidePasswordError()
            }
        }
    }

    func termsAction() {
        let nav = ElloWebBrowserViewController.navigationControllerWithWebBrowser()
        let browser = nav.rootWebBrowser()
        let url = "\(ElloURI.baseURL)/wtf/post/terms-of-use"
        Tracker.shared.webViewAppeared(url)
        browser?.loadURLString(url)
        browser?.tintColor = UIColor.greyA()
        browser?.showsURLInNavigationBar = false
        browser?.showsPageTitleInNavigationBar = false
        browser?.title = InterfaceString.WebBrowser.TermsAndConditions

        present(nav, animated: true, completion: nil)
    }

    func onePasswordAction(_ sender: UIView) {
        OnePasswordExtension.shared().storeLogin(
            forURLString: ElloURI.baseURL,
            loginDetails: [
                AppExtensionTitleKey: InterfaceString.Ello,
            ], passwordGenerationOptions: [
                AppExtensionGeneratedPasswordMinLengthKey: 8,
            ],
            for: self,
            sender: sender) { loginDict, error in
                guard let loginDict = loginDict else { return }

                if let username = loginDict[AppExtensionUsernameKey] as? String {
                    self.screen.username = username
                }

                if let password = loginDict[AppExtensionPasswordKey] as? String {
                    self.screen.password = password
                }

                self.validate(email: self.screen.email, username: self.screen.username, password: self.screen.password)
            }
    }
}

// MARK: Text field validation
extension JoinViewController {

    fileprivate func emailAvailability(_ text: String, completion: @escaping (Bool) -> Void) {
        AvailabilityService().emailAvailability(text, success: { availability in
            if text != self.screen.email {
                completion(false)
                return
            }

            if !availability.isEmailAvailable {
                self.screen.showEmailError(InterfaceString.Validator.EmailInvalid)
                completion(false)
            }
            else {
                completion(true)
            }
        }, failure: { error, _ in
            let errorTitle = error.elloErrorMessage ?? InterfaceString.UnknownError
            self.screen.showEmailError(errorTitle)
            completion(false)
        })
    }

    fileprivate func usernameAvailability(_ text: String, completion: @escaping (Bool) -> Void) {
        AvailabilityService().usernameAvailability(text, success: { availability in
            if text != self.screen.username {
                completion(false)
                return
            }

            if !availability.isUsernameAvailable {
                self.screen.showUsernameError(InterfaceString.Join.UsernameUnavailable)

                if !availability.usernameSuggestions.isEmpty {
                    self.screen.showUsernameSuggestions(availability.usernameSuggestions)
                }
                completion(false)
            }
            else {
                self.screen.hideMessage()
                completion(true)
            }
        }, failure: { error, _ in
            let errorTitle = error.elloErrorMessage ?? InterfaceString.UnknownError
            self.screen.showUsernameError(errorTitle)
            self.screen.hideMessage()
            completion(false)
        })
    }

}
