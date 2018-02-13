////
///  ForgotPasswordProtocols.swift
//


protocol ForgotPasswordEmailScreenDelegate: class {
    func backAction()
    func validate(email: String)
    func submit(email: String)
}

protocol ForgotPasswordEmailScreenProtocol: class {
    var isEmailValid: Bool? { get set }
    func showEmailError(_ text: String)
    func hideEmailError()
    func loadingHUD(visible: Bool)
    func resignFirstResponder() -> Bool
    func showSubmitMessage()
}


protocol ForgotPasswordResetScreenDelegate: class {
    func backAction()
    func validate(password: String)
    func submit(password: String)
}
protocol ForgotPasswordResetScreenProtocol: class {
    var isPasswordValid: Bool? { get set }
    func showFailureMessage()
    func showPasswordError(_ text: String)
    func hidePasswordError()
    func loadingHUD(visible: Bool)
    func resignFirstResponder() -> Bool
}
