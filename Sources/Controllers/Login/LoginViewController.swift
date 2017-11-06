////
///  LoginViewController.swift
//

import Alamofire
import OnePasswordExtension

class LoginViewController: BaseElloViewController {
    private var _mockScreen: LoginScreenProtocol?
    var screen: LoginScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return _mockScreen ?? (self.view as! LoginScreen) }
    }

    override func loadView() {
        let screen = LoginScreen()
        screen.delegate = self
        screen.isOnePasswordAvailable = OnePasswordExtension.shared().isAppExtensionAvailable()
        self.view = screen
    }

    private func loadCurrentUser() {
        appViewController?.loadCurrentUser()
            .catch { error in
                self.screen.loadingHUD(visible: false)
                let errorTitle = error.elloErrorMessage ?? InterfaceString.Login.LoadUserError
                self.screen.showError(errorTitle)
            }
    }

}

extension LoginViewController: LoginDelegate {
    func backAction() {
        _ = navigationController?.popViewController(animated: true)
    }

    func forgotPasswordAction() {
        Tracker.shared.tappedForgotPassword()

        let vc = ForgotPasswordEmailViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    func onePasswordAction(_ sender: UIView) {
        OnePasswordExtension.shared().findLogin(
            forURLString: ElloURI.baseURL,
            for: self,
            sender: sender) { loginDict, error in
                guard let loginDict = loginDict else { return }

                if let username = loginDict[AppExtensionUsernameKey] as? String {
                    self.screen.username = username
                }

                if let password = loginDict[AppExtensionPasswordKey] as? String {
                    self.screen.password = password
                }

                if !self.screen.username.isEmpty && !self.screen.password.isEmpty {
                    self.submit(username: self.screen.username, password: self.screen.password)
                }
            }
    }

    func validate(username: String, password: String) {
        if Validator.isValidEmail(username) || Validator.isValidUsername(username) {
            screen.isUsernameValid = true
        }
        else {
            screen.isUsernameValid = nil
        }

        if Validator.isValidPassword(password) {
            screen.isPasswordValid = true
        }
        else {
            screen.isPasswordValid = nil
        }
    }

    func submit(username: String, password: String) {
        Tracker.shared.tappedLogin()

        _ = screen.resignFirstResponder()

        if Validator.hasValidLoginCredentials(username: username, password: password) {
            Tracker.shared.loginValid()
            screen.hideError()
            screen.loadingHUD(visible: true)

            CredentialsAuthService().authenticate(email: username, password: password)
                .then { _ -> Void in
                    Tracker.shared.loginSuccessful()
                    self.loadCurrentUser()
                }
                .catch { error in
                    Tracker.shared.loginFailed()
                    self.screen.loadingHUD(visible: false)
                    let errorTitle = error.elloErrorMessage ?? InterfaceString.UnknownError
                    self.screen.showError(errorTitle)
                }
        }
        else {
            Tracker.shared.loginInvalid()
            if let errorTitle = Validator.invalidLoginCredentialsReason(username: username, password: password) {
                screen.showError(errorTitle)
            }
        }
    }
}
