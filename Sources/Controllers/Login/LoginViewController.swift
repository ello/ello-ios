////
///  LoginViewController.swift
//

import Alamofire
import OnePasswordExtension

class LoginViewController: BaseElloViewController, HasAppController {
    var mockScreen: LoginScreenProtocol?
    var screen: LoginScreenProtocol { return mockScreen ?? (self.view as! LoginScreenProtocol) }

    var parentAppController: AppViewController?

    override func loadView() {
        let screen = LoginScreen()
        screen.delegate = self
        screen.onePasswordAvailable = OnePasswordExtension.shared().isAppExtensionAvailable()
        self.view = screen
    }

    fileprivate func loadCurrentUser() {
        parentAppController?.loadCurrentUser() { error in
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

        let browser = ElloWebBrowserViewController()
        let nav = ElloWebBrowserViewController.navigationControllerWithBrowser(browser)
        let url = "\(ElloURI.baseURL)/forgot-password"
        Tracker.shared.webViewAppeared(url)
        browser.loadURLString(url)
        browser.tintColor = UIColor.greyA()

        browser.showsURLInNavigationBar = false
        browser.showsPageTitleInNavigationBar = false
        browser.title = InterfaceString.Login.ForgotPassword
        browser.toolbarHidden = true

        present(nav, animated: true, completion: nil)
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
            screen.usernameValid = true
        }
        else {
            screen.usernameValid = nil
        }

        if Validator.isValidPassword(password) {
            screen.passwordValid = true
        }
        else {
            screen.passwordValid = nil
        }
    }

    func submit(username: String, password: String) {
        Tracker.shared.tappedLogin()

        _ = screen.resignFirstResponder()

        if Validator.hasValidLoginCredentials(username: username, password: password) {
            Tracker.shared.loginValid()
            screen.hideError()
            screen.loadingHUD(visible: true)

            CredentialsAuthService().authenticate(email: username,
                password: password,
                success: {
                    Tracker.shared.loginSuccessful()
                    self.loadCurrentUser()
                },
                failure: { (error, statusCode) in
                    Tracker.shared.loginFailed()
                    self.screen.loadingHUD(visible: false)
                    let errorTitle = error.elloErrorMessage ?? InterfaceString.UnknownError
                    self.screen.showError(errorTitle)
                }
            )
        }
        else {
            Tracker.shared.loginInvalid()
            if let errorTitle = Validator.invalidLoginCredentialsReason(username: username, password: password) {
                screen.showError(errorTitle)
            }
        }
    }
}
