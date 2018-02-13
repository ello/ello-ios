////
///  JoinProtocols.swift
//

protocol JoinScreenDelegate: class {
    func backAction()
    func validate(email: String, username: String, password: String)
    func onePasswordAction(_ sender: UIView)
    func submit(email: String, username: String, password: String)
    func termsAction()
}

protocol JoinScreenProtocol: class {
    var blackBarIsVisible: Bool { get set }
    var prompt: String? { get set }
    var email: String { get set }
    var isEmailValid: Bool? { get set }
    var username: String { get set }
    var isUsernameValid: Bool? { get set }
    var password: String { get set }
    var isPasswordValid: Bool? { get set }
    var isOnePasswordAvailable: Bool { get set }

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
