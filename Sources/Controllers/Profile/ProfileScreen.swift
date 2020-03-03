////
///  ProfileScreen.swift
//

import SnapKit
import PINRemoteImage


class ProfileScreen: StreamableScreen, ProfileScreenProtocol {
    struct Size {
        static let whiteTopOffset: CGFloat = 338
        static let profileButtonsContainerViewHeight: CGFloat = 60
        static let profileButtonsContainerTallHeight: CGFloat = 84
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

    var hasRoleAdminButton: Bool = false {
        didSet { updateRoleAdminButton() }
    }

    var hasBackButton: Bool = false {
        didSet { updateBackButton() }
    }

    var showBackButton: Bool = false {
        didSet { updateBackButton() }
    }

    // 'internal' visibitility for testing
    let relationshipControl = RelationshipControl()
    let roleAdminButton = UIButton()
    let collaborateButton = StyledButton(style: .blackPill)
    let hireButton = StyledButton(style: .blackPill)
    let mentionButton = StyledButton(style: .blackPill)
    let inviteButton = StyledButton(style: .blackPill)
    let editButton = StyledButton(style: .blackPill)

    private let whiteSolidView = UIView()
    private let loaderView = InterpolatedLoadingView()
    private let coverImageView = PINAnimatedImageView()
    private let ghostLeftButton = StyledButton(style: .blackPill)
    private let ghostRightButton = StyledButton(style: .blackPill)
    private let profileButtonsEffect = UIVisualEffectView()
    private var profileButtonsContainer: UIView { return profileButtonsEffect.contentView }
    private let profileButtonsLeadingGuide = UILayoutGuide()
    private let persistentBackButton = PersistentBackButton()

    // constraints
    private var whiteSolidTop: Constraint!
    private var coverImageHeight: Constraint!
    private var roleAdminVisibleConstraint: Constraint!
    private var roleAdminHiddenConstraint: Constraint!
    private var profileButtonsContainerTopConstraint: Constraint!
    private var profileButtonsContainerHeightConstraint: Constraint!
    private var hireLeftConstraint: Constraint!
    private var hireRightConstraint: Constraint!
    private var relationshipHireConstraint: Constraint!
    private var relationshipCollabConstraint: Constraint!
    private var relationshipMentionConstraint: Constraint!
    private var showBackButtonConstraint: Constraint!
    private var hideBackButtonConstraint: Constraint!

    weak var delegate: ProfileScreenDelegate?

    override func layoutSubviews() {
        super.layoutSubviews()
        roleAdminButton.layer.cornerRadius = roleAdminButton.frame.size.height / 2
    }

    override func setup() {
        persistentBackButton.alpha = 0

        roleAdminButton.isHidden = true
        collaborateButton.isHidden = true
        hireButton.isHidden = true
        mentionButton.isHidden = true
        relationshipControl.isHidden = true
        editButton.isHidden = true
        inviteButton.isHidden = true
        ghostLeftButton.isVisible = true
        ghostRightButton.isVisible = true
        ghostLeftButton.isEnabled = false
        ghostRightButton.isEnabled = false
    }

    override func setText() {
        collaborateButton.title = InterfaceString.Profile.Collaborate
        hireButton.title = InterfaceString.Profile.Hire
        inviteButton.title = InterfaceString.Profile.Invite
        editButton.title = InterfaceString.Profile.EditProfile
        mentionButton.title = InterfaceString.Profile.Mention
    }

    override func style() {
        whiteSolidView.backgroundColor = .white
        relationshipControl.usage = .profileView
        profileButtonsEffect.effect = UIBlurEffect(style: .light)
        coverImageView.contentMode = .scaleAspectFill

        roleAdminButton.setImage(.roleAdmin, imageStyle: .white, for: .normal)
        roleAdminButton.setImage(.roleAdmin, imageStyle: .normal, for: .selected)
        roleAdminButton.backgroundColor = .black
        roleAdminButton.layer.masksToBounds = true
    }

    override func bindActions() {
        mentionButton.addTarget(self, action: #selector(mentionTapped(_:)), for: .touchUpInside)
        collaborateButton.addTarget(
            self,
            action: #selector(collaborateTapped(_:)),
            for: .touchUpInside
        )
        roleAdminButton.addTarget(self, action: #selector(roleAdminTapped(_:)), for: .touchUpInside)
        hireButton.addTarget(self, action: #selector(hireTapped(_:)), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editTapped(_:)), for: .touchUpInside)
        inviteButton.addTarget(self, action: #selector(inviteTapped(_:)), for: .touchUpInside)
        persistentBackButton.addTarget(
            navigationBar,
            action: #selector(ElloNavigationBar.backButtonTapped),
            for: .touchUpInside
        )
    }

    override func arrange() {
        super.arrange()
        addSubview(loaderView)
        addSubview(coverImageView)
        addSubview(whiteSolidView)
        addSubview(streamContainer)
        addSubview(profileButtonsEffect)
        addSubview(navigationBar)

        // relationship controls sub views
        profileButtonsContainer.addLayoutGuide(profileButtonsLeadingGuide)
        profileButtonsContainer.addSubview(mentionButton)
        profileButtonsContainer.addSubview(roleAdminButton)
        profileButtonsContainer.addSubview(collaborateButton)
        profileButtonsContainer.addSubview(hireButton)
        profileButtonsContainer.addSubview(inviteButton)
        profileButtonsContainer.addSubview(relationshipControl)
        profileButtonsContainer.addSubview(editButton)
        profileButtonsContainer.addSubview(ghostLeftButton)
        profileButtonsContainer.addSubview(ghostRightButton)
        profileButtonsContainer.addSubview(persistentBackButton)

        loaderView.snp.makeConstraints { make in
            make.edges.equalTo(coverImageView)
        }

        coverImageView.snp.makeConstraints { make in
            coverImageHeight = make.height.equalTo(Size.whiteTopOffset).constraint
            make.width.equalTo(coverImageView.snp.height).multipliedBy(
                ProfileHeaderAvatarCell.Size.ratio
            )
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
            profileButtonsContainerHeightConstraint =
                make.height.equalTo(Size.profileButtonsContainerViewHeight).constraint
        }

        profileButtonsLeadingGuide.snp.makeConstraints { make in
            showBackButtonConstraint =
                make.leading.trailing.equalTo(persistentBackButton.snp.trailing).offset(
                    Size.buttonMargin
                ).constraint
            hideBackButtonConstraint =
                make.leading.trailing.equalTo(profileButtonsContainer.snp.leading).offset(
                    Size.buttonMargin
                ).constraint
        }
        showBackButtonConstraint.deactivate()

        persistentBackButton.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
        persistentBackButton.snp.makeConstraints { make in
            make.leading.equalTo(profileButtonsContainer).offset(Size.buttonMargin)
            make.bottom.equalTo(profileButtonsContainer).offset(-Size.buttonMargin)
        }

        roleAdminButton.snp.makeConstraints { make in
            make.leading.equalTo(profileButtonsLeadingGuide.snp.trailing)
            make.width.height.equalTo(Size.buttonHeight)
            make.top.equalTo(mentionButton)
        }

        let buttonLeadingGuide = UILayoutGuide()
        addLayoutGuide(buttonLeadingGuide)

        buttonLeadingGuide.snp.makeConstraints { make in
            roleAdminHiddenConstraint =
                make.leading.equalTo(profileButtonsLeadingGuide.snp.trailing).constraint
            roleAdminVisibleConstraint =
                make.leading.equalTo(roleAdminButton.snp.trailing).offset(Size.buttonMargin)
                .constraint
        }
        roleAdminHiddenConstraint.deactivate()

        mentionButton.snp.makeConstraints { make in
            make.leading.equalTo(buttonLeadingGuide)
            make.width.equalTo(Size.mentionButtonWidth).priority(Priority.required)
            make.height.equalTo(Size.buttonHeight)
            make.bottom.equalTo(profileButtonsContainer).offset(-Size.buttonMargin)
        }

        collaborateButton.snp.makeConstraints { make in
            make.height.equalTo(Size.buttonHeight)
            make.top.equalTo(mentionButton)
            make.leading.equalTo(buttonLeadingGuide)
            make.width.equalTo(Size.buttonWidth).priority(Priority.required)
        }
        roleAdminVisibleConstraint.deactivate()

        hireButton.snp.makeConstraints { make in
            make.height.equalTo(Size.buttonHeight)
            hireLeftConstraint = make.leading.equalTo(buttonLeadingGuide).constraint
            hireRightConstraint =
                make.leading.equalTo(collaborateButton.snp.trailing).offset(Size.innerButtonMargin)
                .constraint
            make.top.equalTo(mentionButton)
            make.width.equalTo(Size.buttonWidth).priority(Priority.required)
        }
        hireLeftConstraint.deactivate()
        hireRightConstraint.deactivate()

        inviteButton.snp.makeConstraints { make in
            make.leading.equalTo(buttonLeadingGuide)
            make.width.equalTo(Size.mentionButtonWidth).priority(Priority.medium)
            make.width.greaterThanOrEqualTo(Size.mentionButtonWidth)
            make.height.equalTo(Size.buttonHeight)
            make.bottom.equalTo(profileButtonsContainer).offset(-Size.buttonMargin)
        }

        relationshipControl.snp.makeConstraints { make in
            make.height.equalTo(Size.buttonHeight)
            make.width.lessThanOrEqualTo(Size.relationshipButtonMaxWidth).priority(
                Priority.required
            )
            relationshipHireConstraint =
                make.leading.equalTo(hireButton.snp.trailing).offset(
                    Size.relationshipControlLeadingMargin
                ).priority(Priority.medium).constraint
            relationshipCollabConstraint =
                make.leading.equalTo(collaborateButton.snp.trailing).offset(
                    Size.relationshipControlLeadingMargin
                ).priority(Priority.medium).constraint
            relationshipMentionConstraint =
                make.leading.equalTo(mentionButton.snp.trailing).offset(
                    Size.relationshipControlLeadingMargin
                ).priority(Priority.medium).constraint
            make.bottom.equalTo(profileButtonsContainer).offset(-Size.buttonMargin)
            make.trailing.equalTo(profileButtonsContainer).offset(-Size.buttonMargin).priority(
                Priority.required
            )
        }
        relationshipHireConstraint.deactivate()
        relationshipCollabConstraint.deactivate()
        relationshipMentionConstraint.deactivate()

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

    @objc
    func mentionTapped(_ button: UIButton) {
        delegate?.mentionTapped()
    }

    @objc
    func hireTapped(_ button: UIButton) {
        delegate?.hireTapped()
    }

    @objc
    func editTapped(_ button: UIButton) {
        delegate?.editTapped()
    }

    @objc
    func inviteTapped(_ button: UIButton) {
        delegate?.inviteTapped()
    }

    @objc
    func collaborateTapped(_ button: UIButton) {
        delegate?.collaborateTapped()
    }

    @objc
    func roleAdminTapped(_ button: UIButton) {
        delegate?.roleAdminTapped()
    }

    func enableButtons() {
        setButtonsEnabled(true)
    }

    func disableButtons() {
        setButtonsEnabled(false)
    }

    func configureButtonsForNonCurrentUser(isHireable: Bool, isCollaborateable: Bool) {
        let showBoth = isHireable && isCollaborateable
        let showOne = !showBoth && (isHireable || isCollaborateable)
        hireLeftConstraint.set(isActivated: showOne)
        hireRightConstraint.set(isActivated: showBoth)

        relationshipHireConstraint.set(isActivated: isHireable)
        relationshipCollabConstraint.set(isActivated: !isHireable && isCollaborateable)
        relationshipMentionConstraint.set(isActivated: !(isHireable || isCollaborateable))

        collaborateButton.isVisible = isCollaborateable
        hireButton.isVisible = isHireable
        mentionButton.isHidden = isHireable || isCollaborateable

        relationshipControl.isVisible = true
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
        editButton.isVisible = true
        inviteButton.isVisible = true
        ghostLeftButton.isHidden = true
        ghostRightButton.isHidden = true
    }

    private func setButtonsEnabled(_ enabled: Bool) {
        roleAdminButton.isEnabled = enabled
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

    func updateHeaderHeightConstraints(
        max maxHeaderHeight: CGFloat,
        scrollAdjusted scrollAdjustedHeight: CGFloat
    ) {
        coverImageHeight.update(offset: maxHeaderHeight)
        whiteSolidTop.update(offset: max(scrollAdjustedHeight, 0))
    }

    func resetCoverImage() {
        coverImageView.pin_cancelImageDownload()
        coverImageView.image = nil
    }

    override func showNavBars(animated: Bool) {
        elloAnimate(animated: animated) {
            let effectsTop = self.navigationBar.frame.height
            let effectsHeight = Size.profileButtonsContainerViewHeight

            self.updateNavBars(effectsTop: effectsTop, effectsHeight: effectsHeight)
            self.showBackButton = false
            super.showNavBars(animated: false)
        }
    }

    func hideNavBars(_ offset: CGPoint, isCurrentUser: Bool) {
        elloAnimate {
            let effectsTop: CGFloat
            let effectsHeight: CGFloat
            if isCurrentUser {
                effectsTop = -self.profileButtonsEffect.frame.height
                effectsHeight = Size.profileButtonsContainerViewHeight
            }
            else {
                effectsTop = 0
                effectsHeight = Globals.isIphoneX
                    ? Size.profileButtonsContainerTallHeight
                    : Size.profileButtonsContainerViewHeight
            }

            self.updateNavBars(effectsTop: effectsTop, effectsHeight: effectsHeight)
            self.showBackButton = true
            super.hideNavBars(animated: false)
        }
    }

    private func updateNavBars(effectsTop: CGFloat, effectsHeight: CGFloat) {
        let buttonTop = effectsHeight - Size.buttonMargin - mentionButton.frame.size.height

        profileButtonsContainerTopConstraint.update(offset: effectsTop)
        profileButtonsEffect.frame.origin.y = effectsTop
        profileButtonsContainerHeightConstraint.update(offset: effectsHeight)
        profileButtonsEffect.frame.size.height = effectsHeight

        [
            relationshipControl, roleAdminButton, collaborateButton, hireButton, mentionButton,
            inviteButton, editButton
        ].forEach { button in
            button.frame.origin.y = buttonTop
        }
    }
}

extension ProfileScreen: ArrangeNavBackButton {
    func arrangeNavBackButton(_ button: UIButton) {
    }

    private func updateRoleAdminButton() {
        roleAdminButton.isVisible = hasRoleAdminButton
        roleAdminVisibleConstraint.set(isActivated: hasRoleAdminButton)
        roleAdminHiddenConstraint.set(isActivated: !hasRoleAdminButton)
    }

    private func updateBackButton() {
        let showButton = hasBackButton && showBackButton
        showBackButtonConstraint.set(isActivated: showButton)
        hideBackButtonConstraint.set(isActivated: !showButton)
        persistentBackButton.alpha = showButton ? 1 : 0
        profileButtonsEffect.layoutIfNeeded()
    }
}
