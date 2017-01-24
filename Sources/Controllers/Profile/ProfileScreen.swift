////
///  ProfileScreen.swift
//

import SnapKit


class ProfileScreen: StreamableScreen, ProfileScreenProtocol {

    struct Size {
        static let whiteTopOffset: CGFloat = 338
        static let profileButtonsContainerViewHeight: CGFloat = 64
        static let navBarHeight: CGFloat = 64
        static let buttonMargin: CGFloat = 15
        static let innerButtonMargin: CGFloat = 5
        static let buttonHeight: CGFloat = 30
        static let buttonWidth: CGFloat = 70
        static let mentionButtonWidth: CGFloat = 100
        static let relationshipButtonMaxWidth: CGFloat = 283
        static let relationshipControlLeadingMargin: CGFloat = 5
        static let editButtonMargin: CGFloat = 10
    }

    weak var relationshipDelegate: RelationshipDelegate? {
        get { return self.relationshipControl.relationshipDelegate }
        set { self.relationshipControl.relationshipDelegate = newValue }
    }

    var coverImage: UIImage? {
        get { return coverImageView.image }
        set { coverImageView.image = newValue }
    }

    var coverImageURL: URL? {
        get { return nil }
        set { coverImageView.pin_setImage(from: newValue) { result in } }
    }

    // views
    let whiteSolidView = UIView()
    let loaderView = InterpolatedLoadingView()
    var topInsetView: UIView { return profileButtonsEffect }
    let coverImageView = FLAnimatedImageView()
    let relationshipControl = RelationshipControl()
    let mentionButton = StyledButton(style: .BlackPill)
    let collaborateButton = StyledButton(style: .BlackPill)
    let hireButton = StyledButton(style: .BlackPill)
    fileprivate let editButton = StyledButton(style: .BlackPill)
    fileprivate let inviteButton = StyledButton(style: .BlackPill)
    fileprivate let ghostLeftButton = StyledButton(style: .BlackPill)
    fileprivate let ghostRightButton = StyledButton(style: .BlackPill)
    fileprivate let profileButtonsEffect = UIVisualEffectView()
    fileprivate var profileButtonsContainer: UIView { return profileButtonsEffect.contentView }

    // constraints
    fileprivate var whiteSolidTop: Constraint!
    fileprivate var coverImageHeight: Constraint!
    fileprivate var profileButtonsContainerTopConstraint: Constraint!
    fileprivate var hireLeftConstraint: Constraint!
    fileprivate var hireRightConstraint: Constraint!
    fileprivate var relationshipMentionConstraint: Constraint!
    fileprivate var relationshipCollabConstraint: Constraint!
    fileprivate var relationshipHireConstraint: Constraint!

    weak var delegate: ProfileScreenDelegate?

    override func arrange() {
        super.arrange()
        addSubview(loaderView)
        addSubview(coverImageView)
        addSubview(whiteSolidView)
        addSubview(streamContainer)
        addSubview(profileButtonsEffect)
        addSubview(navigationBar)

        // relationship controls sub views
        profileButtonsContainer.addSubview(mentionButton)
        profileButtonsContainer.addSubview(collaborateButton)
        profileButtonsContainer.addSubview(hireButton)
        profileButtonsContainer.addSubview(inviteButton)
        profileButtonsContainer.addSubview(relationshipControl)
        profileButtonsContainer.addSubview(editButton)
        profileButtonsContainer.addSubview(ghostLeftButton)
        profileButtonsContainer.addSubview(ghostRightButton)

        loaderView.snp.makeConstraints { make in
            make.edges.equalTo(coverImageView)
        }

        coverImageView.snp.makeConstraints { make in
            coverImageHeight = make.height.equalTo(Size.whiteTopOffset).constraint
            make.width.equalTo(coverImageView.snp.height).multipliedBy(ProfileHeaderCellSizeCalculator.ratio)
            make.top.equalTo(streamContainer.snp.top)
            make.centerX.equalTo(self)
        }

        whiteSolidView.snp.makeConstraints { make in
            whiteSolidTop = make.top.equalTo(self).offset(Size.whiteTopOffset).constraint
            make.leading.trailing.bottom.equalTo(self)
        }

        profileButtonsEffect.snp.makeConstraints { make in
            profileButtonsContainerTopConstraint = make.top.equalTo(self).constraint
            make.centerX.equalTo(self)
            make.width.equalTo(self)
            make.height.equalTo(Size.profileButtonsContainerViewHeight)
        }

        mentionButton.snp.makeConstraints { make in
            make.leading.equalTo(profileButtonsContainer).offset(Size.buttonMargin)
            make.width.equalTo(Size.mentionButtonWidth).priority(Priority.required)
            make.height.equalTo(Size.buttonHeight)
            make.bottom.equalTo(profileButtonsContainer).offset(-Size.buttonMargin)
        }

        collaborateButton.snp.makeConstraints { make in
            make.height.equalTo(Size.buttonHeight)
            make.leading.equalTo(mentionButton.snp.leading)
            make.top.equalTo(mentionButton)
            make.width.equalTo(Size.buttonWidth).priority(Priority.required)
        }

        hireButton.snp.makeConstraints { make in
            make.height.equalTo(Size.buttonHeight)
            hireLeftConstraint = make.leading.equalTo(mentionButton.snp.leading).constraint
            hireRightConstraint = make.leading.equalTo(collaborateButton.snp.trailing).offset(Size.innerButtonMargin).constraint
            make.top.equalTo(mentionButton)
            make.width.equalTo(Size.buttonWidth).priority(Priority.required)
        }
        hireLeftConstraint.deactivate()
        hireRightConstraint.deactivate()

        inviteButton.snp.makeConstraints { make in
            make.leading.equalTo(profileButtonsContainer).offset(Size.buttonMargin)
            make.width.equalTo(Size.mentionButtonWidth).priority(Priority.medium)
            make.width.greaterThanOrEqualTo(Size.mentionButtonWidth)
            make.height.equalTo(Size.buttonHeight)
            make.bottom.equalTo(profileButtonsContainer).offset(-Size.buttonMargin)
        }

        relationshipControl.snp.makeConstraints { make in
            make.height.equalTo(Size.buttonHeight)
            make.width.lessThanOrEqualTo(Size.relationshipButtonMaxWidth).priority(Priority.required)
            relationshipMentionConstraint = make.leading.equalTo(mentionButton.snp.trailing).offset(Size.relationshipControlLeadingMargin).priority(Priority.medium).constraint
            relationshipCollabConstraint = make.leading.equalTo(collaborateButton.snp.trailing).offset(Size.relationshipControlLeadingMargin).priority(Priority.medium).constraint
            relationshipHireConstraint = make.leading.equalTo(hireButton.snp.trailing).offset(Size.relationshipControlLeadingMargin).priority(Priority.medium).constraint
            make.bottom.equalTo(profileButtonsContainer).offset(-Size.buttonMargin)
            make.trailing.equalTo(profileButtonsContainer).offset(-Size.buttonMargin).priority(Priority.required)
        }
        relationshipMentionConstraint.deactivate()
        relationshipCollabConstraint.deactivate()
        relationshipHireConstraint.deactivate()

        editButton.snp.makeConstraints { make in
            make.height.equalTo(Size.buttonHeight)
            make.width.lessThanOrEqualTo(Size.relationshipButtonMaxWidth)
            make.leading.equalTo(inviteButton.snp.trailing).offset(Size.editButtonMargin)
            make.trailing.equalTo(profileButtonsContainer).offset(-Size.editButtonMargin)
            make.bottom.equalTo(-Size.buttonMargin)
        }

        ghostLeftButton.snp.makeConstraints { make in
            make.leading.equalTo(profileButtonsContainer).offset(Size.buttonMargin)
            make.width.equalTo(Size.mentionButtonWidth).priority(Priority.required)
            make.height.equalTo(Size.buttonHeight)
            make.bottom.equalTo(profileButtonsContainer).offset(-Size.buttonMargin)
        }

        ghostRightButton.snp.makeConstraints { make in
            make.height.equalTo(Size.buttonHeight)
            make.width.lessThanOrEqualTo(Size.relationshipButtonMaxWidth)
            make.leading.equalTo(ghostLeftButton.snp.trailing).offset(Size.editButtonMargin)
            make.trailing.equalTo(profileButtonsContainer).offset(-Size.editButtonMargin)
            make.bottom.equalTo(-Size.buttonMargin)
        }
    }

    override func setText() {
        collaborateButton.setTitle(InterfaceString.Profile.Collaborate, for: .normal)
        hireButton.setTitle(InterfaceString.Profile.Hire, for: .normal)
        inviteButton.setTitle(InterfaceString.Profile.Invite, for: .normal)
        editButton.setTitle(InterfaceString.Profile.EditProfile, for: .normal)
        mentionButton.setTitle(InterfaceString.Profile.Mention, for: .normal)
    }

    override func style() {
        whiteSolidView.backgroundColor = .white
        relationshipControl.style = .profileView
        profileButtonsEffect.effect = UIBlurEffect(style: .light)
        coverImageView.contentMode = .scaleAspectFill

        collaborateButton.isHidden = true
        hireButton.isHidden = true
        mentionButton.isHidden = true
        relationshipControl.isHidden = true
        editButton.isHidden = true
        inviteButton.isHidden = true
        ghostLeftButton.isHidden = false
        ghostRightButton.isHidden = false
        ghostLeftButton.isEnabled = false
        ghostRightButton.isEnabled = false
    }

    override func bindActions() {
        mentionButton.addTarget(self, action: #selector(mentionTapped(_:)), for: .touchUpInside)
        collaborateButton.addTarget(self, action: #selector(collaborateTapped(_:)), for: .touchUpInside)
        hireButton.addTarget(self, action: #selector(hireTapped(_:)), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editTapped(_:)), for: .touchUpInside)
        inviteButton.addTarget(self, action: #selector(inviteTapped(_:)), for: .touchUpInside)
    }

    func mentionTapped(_ button: UIButton) {
        delegate?.mentionTapped()
    }

    func hireTapped(_ button: UIButton) {
        delegate?.hireTapped()
    }

    func editTapped(_ button: UIButton) {
        delegate?.editTapped()
    }

    func inviteTapped(_ button: UIButton) {
        delegate?.inviteTapped()
    }

    func collaborateTapped(_ button: UIButton) {
        delegate?.collaborateTapped()
    }

    func enableButtons() {
        setButtonsEnabled(true)
    }

    func disableButtons() {
        setButtonsEnabled(false)
    }

    func configureButtonsForNonCurrentUser(isHireable: Bool, isCollaborateable: Bool) {
        if isHireable && isCollaborateable {
            hireLeftConstraint.deactivate()
            hireRightConstraint.activate()
        }
        else if isHireable {
            hireLeftConstraint.activate()
            hireRightConstraint.deactivate()
        }
        else if isCollaborateable {
            hireLeftConstraint.activate()
            hireRightConstraint.deactivate()
        }

        if isHireable {
            relationshipCollabConstraint.deactivate()
            relationshipHireConstraint.activate()
            relationshipMentionConstraint.deactivate()
        }
        else if isCollaborateable {
            relationshipCollabConstraint.activate()
            relationshipHireConstraint.deactivate()
            relationshipMentionConstraint.deactivate()
        }
        else {
            relationshipHireConstraint.deactivate()
            relationshipCollabConstraint.deactivate()
            relationshipMentionConstraint.activate()
        }

        collaborateButton.isHidden = !isCollaborateable
        hireButton.isHidden = !isHireable
        mentionButton.isHidden = isHireable || isCollaborateable
        relationshipControl.isHidden = false
        editButton.isHidden = true
        inviteButton.isHidden = true
        ghostLeftButton.isHidden = true
        ghostRightButton.isHidden = true
    }

    func configureButtonsForCurrentUser() {
        collaborateButton.isHidden = true
        hireButton.isHidden = true
        mentionButton.isHidden = true
        relationshipControl.isHidden = true
        editButton.isHidden = false
        inviteButton.isHidden = false
        ghostLeftButton.isHidden = true
        ghostRightButton.isHidden = true
    }

    fileprivate func setButtonsEnabled(_ enabled: Bool) {
        collaborateButton.isEnabled = enabled
        hireButton.isEnabled = enabled
        mentionButton.isEnabled = enabled
        editButton.isEnabled = enabled
        inviteButton.isEnabled = enabled
        relationshipControl.enabled = enabled
    }

    func updateRelationshipControl(user: User) {
        relationshipControl.userId = user.id
        relationshipControl.userAtName = user.atName
        relationshipControl.relationshipPriority = user.relationshipPriority
    }

    func updateRelationshipPriority(_ relationshipPriority: RelationshipPriority) {
        relationshipControl.relationshipPriority = relationshipPriority
    }

    func updateHeaderHeightConstraints(max maxHeaderHeight: CGFloat, scrollAdjusted scrollAdjustedHeight: CGFloat) {
        coverImageHeight.update(offset: maxHeaderHeight)
        whiteSolidTop.update(offset: max(scrollAdjustedHeight, 0))
    }

    func resetCoverImage() {
        coverImageView.pin_cancelImageDownload()
        coverImageView.image = nil
    }

    func showNavBars() {
        animate {
            let height = self.navigationBar.frame.height
            self.profileButtonsContainerTopConstraint.update(offset: height)
            self.profileButtonsEffect.frame.origin.y = height
        }
    }

    func hideNavBars(_ offset: CGPoint, isCurrentUser: Bool) {
        animate {
            let height: CGFloat
            if isCurrentUser {
                height = -self.profileButtonsEffect.frame.height
            }
            else {
                height = 0
            }

            self.profileButtonsContainerTopConstraint.update(offset: height)
            self.profileButtonsEffect.frame.origin.y = height
        }
    }
}
