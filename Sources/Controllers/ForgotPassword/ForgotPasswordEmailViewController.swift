////
///  ForgotPasswordEmailViewController.swift
//

class ForgotPasswordEmailViewController: BaseElloViewController {
    private var _mockScreen: ForgotPasswordEmailScreenProtocol?
    var screen: ForgotPasswordEmailScreenProtocol {
        set(screen) { _mockScreen = screen}
        get { return _mockScreen ?? (self.view as! ForgotPasswordEmailScreen) }
    }

    override func loadView() {
        let screen = ForgotPasswordEmailScreen()
        screen.delegate = self
        self.view = screen
    }
}

extension ForgotPasswordEmailViewController: ForgotPasswordEmailDelegate {
    func submit(email: String) {
        Tracker.shared.tappedRequestPassword()

        _ = screen.resignFirstResponder()

        if Validator.isValidEmail(email) {
            screen.hideEmailError()
            screen.loadingHUD(visible: true)
            Tracker.shared.requestPasswordValid()

            UserService().requestPasswordReset(email: email)
                .thenFinally { _ in
                    self.screen.loadingHUD(visible: false)
                    self.screen.showSubmitMessage()
                }
                .catch { error in
                    self.screen.loadingHUD(visible: false)
                    let errorTitle = (error as NSError).elloErrorMessage ?? InterfaceString.UnknownError
                    self.screen.showEmailError(errorTitle)
                }
        }
        else {
            if let msg = Validator.invalidSignUpEmailReason(email) {
                screen.showEmailError(msg)
            }
            else {
                screen.hideEmailError()
            }
        }
    }

    func backAction() {
        _ = navigationController?.popViewController(animated: true)
    }

    func validate(email: String) {
        if Validator.invalidSignUpEmailReason(email) == nil {
            screen.emailValid = true
        }
        else {
            screen.emailValid = nil
        }
    }
}
