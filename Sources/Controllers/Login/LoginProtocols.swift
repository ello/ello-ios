////
///  LoginProtocols.swift
//

protocol LoginDelegate: class {
    func backAction()
    func forgotPasswordAction()
    func onePasswordAction(_ sender: UIView)
    func validate(username: String, password: String)
    func submit(username: String, password: String)
}

protocol LoginScreenProtocol: class {
    var username: String { get set }
    var usernameValid: Bool? { get set }
    var password: String { get set }
    var passwordValid: Bool? { get set }
    var onePasswordAvailable: Bool { get set }
    func loadingHUD(visible: Bool)
    func showError(_ text: String)
    func hideError()
    func resignFirstResponder() -> Bool
}
