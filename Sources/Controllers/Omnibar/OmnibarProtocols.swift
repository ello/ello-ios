////
///  OmnibarProtocols.swift
//

protocol OmnibarScreenDelegate: class {
    func omnibarCancel()
    func omnibarPushController(_ controller: UIViewController)
    func omnibarPresentController(_ controller: UIViewController)
    func omnibarDismissController()
    func omnibarSubmitted(_ regions: [OmnibarRegion], buyButtonURL: URL?)
}

protocol OmnibarScreenProtocol: class {
    var delegate: OmnibarScreenDelegate? { get set }
    var isComment: Bool { get set }
    var buyButtonURL: URL? { get set }
    var title: String { get set }
    var submitTitle: String { get set }
    var regions: [OmnibarRegion] { get set }
    var avatarURL: URL? { get set }
    var avatarImage: UIImage? { get set }
    var currentUser: User? { get set }
    var canGoBack: Bool { get set }
    var isEditing: Bool { get set }
    var interactionEnabled: Bool { get set }
    func resetAfterSuccessfulPost()
    func reportError(_ title: String, error: NSError)
    func reportError(_ title: String, errorMessage: String)
    func keyboardWillShow()
    func keyboardWillHide()
    func startEditing()
    func stopEditing()
    func updateButtons()
}
