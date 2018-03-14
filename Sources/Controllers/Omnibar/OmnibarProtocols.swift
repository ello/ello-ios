////
///  OmnibarProtocols.swift
//

protocol OmnibarScreenDelegate: class {
    func cancelTapped()
    func chooseCommunityTapped()
    func clearCommunityTapped()
    func omnibarPushController(_ controller: UIViewController)
    func omnibarPresentController(_ controller: UIViewController)
    func omnibarDismissController()
    func submitted(regions: [OmnibarRegion], buyButtonURL: URL?)
}

protocol OmnibarScreenProtocol: class {
    var delegate: OmnibarScreenDelegate? { get set }
    var isComment: Bool { get set }
    var isArtistInviteSubmission: Bool { get set }
    var buyButtonURL: URL? { get set }
    var title: String { get set }
    var submitTitle: String { get set }
    var regions: [OmnibarRegion] { get set }
    var canGoBack: Bool { get set }
    var isEditing: Bool { get set }
    var isInteractionEnabled: Bool { get set }
    var chosenCategory: Category? { get set }
    func resetAfterSuccessfulPost()
    func reportError(_ title: String, error: NSError)
    func reportError(_ title: String, errorMessage: String)
    func keyboardWillShow()
    func keyboardWillHide()
    func startEditing()
    func stopEditing()
    func updateButtons()
}
