////
///  CommentHeaderCell.swift
//

import SnapKit


class CommentHeaderCell: CollectionViewCell {
    static let reuseIdentifier = "CommentHeaderCell"
    struct Size {
        static let height: CGFloat = 60
        static let margins: CGFloat = 15
        static let avatarRightSpace: CGFloat = 15
        static let buttonWidth: CGFloat = 40
        static let spaceCorrection: CGFloat = 4
    }

    private var isOpen = false
    private var bottomContainerWidth: CGFloat {
        return bottomControlsContainer.frame.width - Size.spaceCorrection
    }

    private var foregroundWidthConstraint: Constraint!
    private var foregroundHeightConstraint: Constraint!
    private var replyButtonWidthConstraint: Constraint!
    private var spacerWidthConstraint: Constraint!
    private var cellOpenObserver: NotificationObserver?

    private let scrollView = UIScrollView()
    private let avatarButton = AvatarButton()
    private let usernameButton = StyledButton(style: .clearGray)

    private let topControlsContainer = Container()
    private let foregroundBackground = UIView()
    private let replyButton = UIButton()
    private let timestampLabel = StyledLabel(style: .gray)
    private let bottomContentView = UIView()
    private let chevronButton = StreamFooterButton()

    private let bottomControlsContainer = UIStackView()
    private let flagButton = UIButton()
    private let editButton = UIButton()
    private let deleteButton = UIButton()

    struct Config {
        var author: User?
        var timestamp: String = ""
        var canEdit = false
        var canDelete = false
        var canReplyAndFlag = false
    }

    var config = Config() { didSet { updateConfig() } }

    override func prepareForReuse() {
        super.prepareForReuse()
        close()
    }

    override func style() {
        contentView.backgroundColor = .white
        foregroundBackground.isOpaque = true
        foregroundBackground.backgroundColor = .white
        usernameButton.contentHorizontalAlignment = .left

        replyButton.setImages(.reply)
        chevronButton.setImages(.forwardChevron)
        toggleChevron(isOpen: false)
        flagButton.setImages(.flag)
        editButton.setImages(.pencil)
        deleteButton.setImages(.xBox)

        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.scrollsToTop = false

        for container in [bottomControlsContainer] {
            container.axis = .horizontal
            container.distribution = .fillEqually
            container.alignment = .fill
            container.spacing = 0
        }
    }

    override func bindActions() {
        scrollView.delegate = self

        avatarButton.addTarget(self, action: #selector(userTapped), for: .touchUpInside)
        usernameButton.addTarget(self, action: #selector(userTapped), for: .touchUpInside)
        replyButton.addTarget(self, action: #selector(replyButtonTapped), for: .touchUpInside)
        chevronButton.addTarget(self, action: #selector(chevronButtonTapped), for: .touchUpInside)

        flagButton.addTarget(self, action: #selector(flagButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)

        let longPressGesture = UILongPressGestureRecognizer()
        longPressGesture.addTarget(self, action: #selector(longPressed(_:)))
        contentView.addGestureRecognizer(longPressGesture)

        cellOpenObserver = NotificationObserver(notification: streamHeaderCellDidOpenNotification) {
            [weak self] cell in
            guard let `self` = self, cell != self, self.isOpen else { return }

            nextTick {
                elloAnimate {
                    self.close()
                }
            }
        }
    }

    override func arrange() {
        contentView.addSubview(scrollView)

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }

        scrollView.addSubview(bottomControlsContainer)
        scrollView.addSubview(foregroundBackground)
        scrollView.addSubview(avatarButton)
        scrollView.addSubview(usernameButton)
        scrollView.addSubview(topControlsContainer)
        let topContainerSpacer = Spacer()
        scrollView.addSubview(topContainerSpacer)

        foregroundBackground.snp.makeConstraints { make in
            make.leading.top.bottom.equalTo(scrollView).priority(Priority.required)
            foregroundWidthConstraint =
                make.width.equalTo(frame.size.width).priority(Priority.required).constraint
            foregroundHeightConstraint =
                make.height.equalTo(frame.size.height).priority(Priority.required).constraint
        }

        avatarButton.snp.makeConstraints { make in
            make.leading.equalTo(foregroundBackground).offset(Size.margins)
            make.centerY.equalTo(foregroundBackground)
            make.size.equalTo(AvatarButton.Size.smallSize)
        }

        usernameButton.snp.makeConstraints { make in
            make.leading.equalTo(avatarButton.snp.trailing).offset(Size.avatarRightSpace)
            make.top.bottom.equalTo(foregroundBackground).priority(Priority.required)
        }

        topControlsContainer.snp.makeConstraints { make in
            make.trailing.equalTo(foregroundBackground)
            make.top.bottom.equalTo(foregroundBackground).priority(Priority.required)
        }

        topControlsContainer.addSubview(replyButton)
        topControlsContainer.addSubview(timestampLabel)
        topControlsContainer.addSubview(chevronButton)

        replyButton.snp.makeConstraints { make in
            replyButtonWidthConstraint = make.width.equalTo(0).constraint
            make.width.equalTo(Size.buttonWidth)
        }

        chevronButton.snp.makeConstraints { make in
            make.width.equalTo(Size.buttonWidth)
        }

        [replyButton, timestampLabel, chevronButton].eachPair { prevButton, button, isLast in
            button.snp.makeConstraints { make in
                make.top.bottom.equalTo(topControlsContainer)

                if let prevButton = prevButton {
                    make.leading.equalTo(prevButton.snp.trailing)
                }
                else {
                    make.leading.equalTo(topControlsContainer)
                }

                if isLast {
                    make.trailing.equalTo(topControlsContainer)
                }
            }
        }

        topContainerSpacer.snp.makeConstraints { make in
            make.leading.equalTo(topControlsContainer.snp.trailing)
            make.trailing.equalTo(scrollView)
            make.height.equalTo(0)
            spacerWidthConstraint = make.width.equalTo(0).priority(Priority.required).constraint
        }

        bottomControlsContainer.snp.makeConstraints { make in
            make.top.bottom.trailing.equalTo(contentView)
        }

        bottomControlsContainer.addArrangedSubview(flagButton)
        bottomControlsContainer.addArrangedSubview(editButton)
        bottomControlsContainer.addArrangedSubview(deleteButton)

        flagButton.snp.makeConstraints { make in
            make.width.equalTo(Size.buttonWidth)
        }

        editButton.snp.makeConstraints { make in
            make.width.equalTo(Size.buttonWidth)
        }

        deleteButton.snp.makeConstraints { make in
            make.width.equalTo(Size.buttonWidth)
        }
    }

    override func layoutSubviews() {
        foregroundWidthConstraint.update(offset: contentView.frame.size.width)
        foregroundHeightConstraint.update(offset: contentView.frame.size.height)
        spacerWidthConstraint.update(offset: bottomContainerWidth)

        super.layoutSubviews()

        let topControlsContainerWidth = topControlsContainer.frame.minX - usernameButton.frame.minX
        let scrollViewWidth = scrollView.frame.width - usernameButton.frame.minX
        usernameButton.frame.size.width = min(topControlsContainerWidth, scrollViewWidth)
    }

    func updateConfig() {
        avatarButton.setUserAvatarURL(config.author?.avatarURL())
        usernameButton.title = config.author?.atName
        if config.canReplyAndFlag {
            replyButtonWidthConstraint.update(offset: Size.buttonWidth)
            replyButton.isVisible = true
        }
        else {
            replyButtonWidthConstraint.update(offset: 0)
            replyButton.isHidden = true
        }
        timestampLabel.text = config.timestamp

        flagButton.isVisible = config.canReplyAndFlag
        editButton.isVisible = config.canEdit
        deleteButton.isVisible = config.canDelete

        setNeedsLayout()
    }

    func close() {
        isOpen = false
        toggleChevron(isOpen: false)
        scrollView.contentOffset = .zero
    }

}

extension CommentHeaderCell {

    @objc
    func userTapped() {
        let responder: UserResponder? = findResponder()
        responder?.userTappedAuthor(cell: self)
    }

    @objc
    func flagButtonTapped() {
        let responder: PostbarController? = findResponder()
        responder?.flagCommentButtonTapped(cell: self)
    }

    @objc
    func replyButtonTapped() {
        let responder: PostbarController? = findResponder()
        responder?.replyToCommentButtonTapped(cell: self)
    }

    @objc
    func deleteButtonTapped() {
        let responder: PostbarController? = findResponder()
        responder?.deleteCommentButtonTapped(cell: self)
    }

    @objc
    func editButtonTapped() {
        let responder: PostbarController? = findResponder()
        responder?.editCommentButtonTapped(cell: self)
    }

    @objc
    func chevronButtonTapped() {
        isOpen = !isOpen
        let contentOffset = isOpen ? CGPoint(x: bottomContainerWidth, y: 0) : .zero
        elloAnimate {
            self.scrollView.contentOffset = contentOffset
            self.toggleChevron(isOpen: self.isOpen)
        }

        if isOpen {
            postNotification(streamHeaderCellDidOpenNotification, value: self)
        }
    }

    @IBAction func longPressed(_ gesture: UIGestureRecognizer) {
        guard gesture.state == .began else { return }

        let responder: StreamEditingResponder? = findResponder()
        responder?.cellLongPressed(cell: self)
    }
}

extension CommentHeaderCell {
    private func toggleChevron(isOpen: Bool) {
        if isOpen {
            rotateChevron(angle: 0)
        }
        else {
            rotateChevron(angle: .pi)
        }
    }

    private func rotateChevron(angle: CGFloat) {
        var normalized = angle
        if angle < -CGFloat.pi {
            normalized = -CGFloat.pi
        }
        else if angle > CGFloat.pi {
            normalized = CGFloat.pi
        }

        chevronButton.transform = CGAffineTransform(rotationAngle: normalized)
    }
}

extension CommentHeaderCell: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x < 0 {
            scrollView.contentOffset = .zero
        }

        let angle: CGFloat?
        if scrollView.contentOffset.x >= bottomContainerWidth {
            if !isOpen {
                angle = 0
                // close any other open comment cells
                postNotification(streamHeaderCellDidOpenNotification, value: self)
                isOpen = true
                Tracker.shared.commentBarVisibilityChanged(true)
            }
            else {
                angle = nil
            }
        }
        else {
            angle = -CGFloat.pi + CGFloat.pi * scrollView.contentOffset.x / bottomContainerWidth
        }

        if let angle = angle {
            rotateChevron(angle: angle)
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if !isOpen {
            postNotification(streamHeaderCellDidOpenNotification, value: self)
        }
    }

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        if velocity.x > 0 {
            targetContentOffset.pointee.x = bottomContainerWidth
            isOpen = true
        }
        else {
            targetContentOffset.pointee.x = 0
            isOpen = false
        }

        elloAnimate {
            self.toggleChevron(isOpen: self.isOpen)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.toggleChevron(isOpen: self.isOpen)
    }

}
