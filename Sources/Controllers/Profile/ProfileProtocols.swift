////
///  ProfileProtocols.swift
//

protocol ProfileViewProtocol: class {}

protocol ProfileScreenProtocol: StreamableScreenProtocol {
    func disableButtons()
    func enableButtons()
    func showNavBars()
    func hideNavBars(_ offset: CGPoint, isCurrentUser: Bool)
    func configureButtonsForNonCurrentUser(isHireable: Bool, isCollaborateable: Bool)
    func configureButtonsForCurrentUser()
    func resetCoverImage()
    func updateHeaderHeightConstraints(max: CGFloat, scrollAdjusted: CGFloat)
    func updateRelationshipControl(user: User)
    func updateRelationshipPriority(_ relationshipPriority: RelationshipPriority)
    var relationshipDelegate: RelationshipDelegate? { get set }
    var topInsetView: UIView { get }
    var coverImage: UIImage? { get set }
    var coverImageURL: URL? { get set }
}

protocol ProfileScreenDelegate: class {
    func mentionTapped()
    func hireTapped()
    func editTapped()
    func inviteTapped()
    func collaborateTapped()
}
