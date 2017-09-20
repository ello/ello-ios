////
///  ProfileScreen.swift
//

import SnapKit
import FLAnimatedImage


class ProfileScreen: StreamableScreen, ProfileScreenProtocol {
    struct Size {
        static let whiteTopOffset: CGFloat = 338
        static let profileButtonsContainerViewHeight: CGFloat = 64
        static let profileButtonsContainerTallHeight: CGFloat = 88
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

    var coverImage: UIImage? {
        get { return coverImageView.image }
        set { coverImageView.image = newValue }
    }

    var coverImageURL: URL? {
        get { return nil }
        set { coverImageView.pin_setImage(from: newValue) { _ in } }
    }

    var topInsetView: UIView {
        return profileButtonsEffect
    }

    // for testing
    let relationshipControl = RelationshipControl()
    let collaborateButton = StyledButton(style: .blackPill)
    let hireButton = StyledButton(style: .blackPill)
    let mentionButton = StyledButton(style: .blackPill)
    let inviteButton = StyledButton(style: .blackPill)
    let editButton = StyledButton(style: .blackPill)

    fileprivate let whiteSolidView = UIView()
    fileprivate let loaderView = InterpolatedLoadingView()
    fileprivate let coverImageView = FLAnimatedImageView()
    fileprivate let ghostLeftButton = StyledButton(style: .blackPill)
    fileprivate let ghostRightButton = StyledButton(style: .blackPill)
    fileprivate let profileButtonsEffect = UIVisualEffectView()
    fileprivate var profileButtonsContainer: UIView { return profileButtonsEffect.contentView }

    // constraints
    fileprivate var whiteSolidTop: Constraint!
    fileprivate var coverImageHeight: Constraint!
    fileprivate var profileButtonsContainerTopConstraint: Constraint!
    fileprivate var profileButtonsContainerHeightConstraint: Constraint!
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
            profileButtonsContainerHeightConstraint = make.height.equalTo(Size.profileButtonsContainerViewHeight).constraint
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
        relationshipControl.usage = .profileView
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
        relationshipControl.isEnabled = enabled
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
            let effectsTop = self.navigationBar.frame.height
            let effectsHeight = Size.profileButtonsContainerViewHeight

            self.updateNavBars(effectsTop: effectsTop, effectsHeight: effectsHeight)

        }
    }

    func hideNavBars(_ offset: CGPoint, isCurrentUser: Bool) {
        animate {
            let effectsTop: CGFloat
            let effectsHeight: CGFloat
            if isCurrentUser {
                effectsTop = -self.profileButtonsEffect.frame.height
                effectsHeight = Size.profileButtonsContainerViewHeight
            }
            else {
                effectsTop = 0
                effectsHeight = AppSetup.shared.isIphoneX ? Size.profileButtonsContainerTallHeight : Size.profileButtonsContainerViewHeight
            }

            self.updateNavBars(effectsTop: effectsTop, effectsHeight: effectsHeight)
        }
    }

    fileprivate func updateNavBars(effectsTop: CGFloat, effectsHeight: CGFloat) {
        let buttonTop = effectsHeight - Size.buttonMargin - mentionButton.frame.size.height

        profileButtonsContainerTopConstraint.update(offset: effectsTop)
        profileButtonsEffect.frame.origin.y = effectsTop
        profileButtonsContainerHeightConstraint.update(offset: effectsHeight)
        profileButtonsEffect.frame.size.height = effectsHeight

        [relationshipControl, collaborateButton, hireButton, mentionButton, inviteButton, editButton].forEach { button in
            button.frame.origin.y = buttonTop
        }
    }
}
