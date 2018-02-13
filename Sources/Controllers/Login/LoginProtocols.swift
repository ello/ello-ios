////
///  LoginProtocols.swift
//

protocol LoginScreenDelegate: class {
    func backAction()
    func forgotPasswordAction()
    func onePasswordAction(_ sender: UIView)
    func validate(username: String, password: String)
    func submit(username: String, password: String)
}

protocol LoginScreenProtocol: class {
    var blackBarIsVisible: Bool { get set }
    var username: String { get set }
    var isUsernameValid: Bool? { get set }
    var password: String { get set }
    var isPasswordValid: Bool? { get set }
    var isOnePasswordAvailable: Bool { get set }
    func loadingHUD(visible: Bool)
    func showError(_ text: String)
    func hideError()
    func resignFirstResponder() -> Bool
}
