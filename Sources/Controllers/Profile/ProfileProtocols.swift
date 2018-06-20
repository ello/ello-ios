////
///  ProfileProtocols.swift
//

protocol ProfileScreenDelegate: class {
    func mentionTapped()
    func hireTapped()
    func editTapped()
    func inviteTapped()
    func collaborateTapped()
    func roleAdminTapped()
}

protocol ProfileScreenProtocol: StreamableScreenProtocol {
    func disableButtons()
    func enableButtons()
    func showNavBars(animated: Bool)
    func hideNavBars(_ offset: CGPoint, isCurrentUser: Bool)
    func configureButtonsForNonCurrentUser(isHireable: Bool, isCollaborateable: Bool)
    func configureButtonsForCurrentUser()
    func resetCoverImage()
    func updateHeaderHeightConstraints(max: CGFloat, scrollAdjusted: CGFloat)
    func updateRelationshipControl(user: User)
    func updateRelationshipPriority(_ relationshipPriority: RelationshipPriority)
    var topInsetView: UIView { get }
    var coverImage: UIImage? { get set }
    var coverImageURL: URL? { get set }
    var hasBackButton: Bool { get set }
    var hasRoleAdminButton: Bool { get set }
}
