////
///  JoinProtocols.swift
//

protocol JoinScreenDelegate: class {
    func backAction()
    func validate(email: String, username: String, password: String)
    func onePasswordAction(_ sender: UIView)
    func submit(email: String, username: String, password: String)
    func urlAction(title: String, url: URL)
}

protocol JoinScreenProtocol: class {
    var prompt: String? { get set }
    var email: String { get set }
    var isEmailValid: Bool? { get set }
    var username: String { get set }
    var isUsernameValid: Bool? { get set }
    var password: String { get set }
    var isPasswordValid: Bool? { get set }
    var isTermsChecked: Bool { get set }
    var isOnePasswordAvailable: Bool { get set }
    var nonceRequestFailed: Bool? { get set }
    var isScreenReady: Bool { get set }

    func loadingHUD(visible: Bool)

    func showUsernameSuggestions(_ usernames: [String])
    func hideUsernameSuggestions()
    func showUsernameError(_ text: String)
    func hideUsernameError()
    func showEmailError(_ text: String)
    func hideEmailError()
    func showPasswordError(_ text: String)
    func hidePasswordError()
    func showTermsError(_ text: String)
    func hideTermsError()
    func showError(_ text: String)

    func resignFirstResponder() -> Bool
}
