////
///  JoinProtocols.swift
//

protocol JoinDelegate: class {
    func backAction()
    func validate(email: String, username: String, password: String)
    func onePasswordAction(_ sender: UIView)
    func submit(email: String, username: String, password: String)
    func termsAction()
}

protocol JoinScreenProtocol: class {
    var email: String { get set }
    var emailValid: Bool? { get set }
    var username: String { get set }
    var usernameValid: Bool? { get set }
    var password: String { get set }
    var passwordValid: Bool? { get set }
    var onePasswordAvailable: Bool { get set }

    func loadingHUD(visible: Bool)

    func showMessage(_ text: String)
    func showUsernameSuggestions(_ usernames: [String])
    func hideMessage()
    func showUsernameError(_ text: String)
    func hideUsernameError()
    func showEmailError(_ text: String)
    func hideEmailError()
    func showPasswordError(_ text: String)
    func hidePasswordError()
    func showError(_ text: String)

    func resignFirstResponder() -> Bool
}
