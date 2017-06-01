////
///  EditorialPostCell.swift
//

class EditorialPostCell: EditorialTitledCell {
    fileprivate let buttonsContainer = UIView()
    fileprivate let postControlsStack = UIStackView()
    fileprivate let lovesButton = UIButton()
    fileprivate let commentButton = UIButton()
    fileprivate let repostButton = UIButton()
    fileprivate let shareButton = UIButton()

    override func style() {
        super.style()

        lovesButton.setImage(.heartOutline, imageStyle: .white, for: .normal)
        lovesButton.setImage(.heart, imageStyle: .white, for: .selected)
        commentButton.setImage(.commentsOutline, imageStyle: .white, for: .normal)
        repostButton.setImage(.repost, imageStyle: .white, for: .normal)
        shareButton.setImage(.share, imageStyle: .white, for: .normal)

        postControlsStack.axis = .horizontal
        postControlsStack.distribution = .fillEqually
        postControlsStack.alignment = .fill
        postControlsStack.spacing = Size.buttonsMargin
    }

    override func bindActions() {
        super.bindActions()
        lovesButton.addTarget(self, action: #selector(lovesTapped), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(commentTapped), for: .touchUpInside)
        repostButton.addTarget(self, action: #selector(repostTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
    }

    override func updateConfig() {
        super.updateConfig()

        repostButton.isHidden = !(config.post?.author?.hasRepostingEnabled ?? false)
        commentButton.isHidden = !(config.post?.author?.hasCommentingEnabled ?? false)
        lovesButton.isHidden = !(config.post?.author?.hasLovesEnabled ?? false)

        let loved = config.post?.loved ?? false
        lovesButton.isEnabled = true
        lovesButton.isSelected = loved
    }

    override func arrange() {
        super.arrange()

        editorialContentView.addSubview(buttonsContainer)
        buttonsContainer.addSubview(postControlsStack)
        postControlsStack.addArrangedSubview(lovesButton)
        postControlsStack.addArrangedSubview(commentButton)
        postControlsStack.addArrangedSubview(repostButton)
        buttonsContainer.addSubview(shareButton)

        buttonsContainer.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalTo(editorialContentView).inset(Size.defaultMargin)
        }

        postControlsStack.snp.makeConstraints { make in
            make.leading.top.bottom.equalTo(buttonsContainer)
        }

        shareButton.snp.makeConstraints { make in
            make.trailing.top.bottom.equalTo(buttonsContainer)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(editorialContentView).inset(Size.defaultMargin)
            make.trailing.lessThanOrEqualTo(editorialContentView).inset(Size.defaultMargin).priority(Priority.required)
            make.bottom.equalTo(buttonsContainer.snp.top).offset(-Size.subtitleButtonMargin)
        }
    }
}

extension EditorialPostCell {
    @objc
    func lovesTapped() {
        guard let post = config.post else { return }

        let responder: EditorialToolsResponder? = findResponder()
        responder?.lovesTapped(post: post, cell: self)
    }

    @objc
    func commentTapped() {
        guard let post = config.post else { return }

        let responder: EditorialToolsResponder? = findResponder()
        responder?.commentTapped(post: post, cell: self)
    }

    @objc
    func repostTapped() {
        guard let post = config.post else { return }

        let responder: EditorialToolsResponder? = findResponder()
        responder?.repostTapped(post: post, cell: self)
    }

    @objc
    func shareTapped() {
        guard let post = config.post else { return }

        let responder: EditorialToolsResponder? = findResponder()
        responder?.shareTapped(post: post, cell: self)
    }
}

extension EditorialPostCell: LoveableCell {
    func toggleLoveControl(enabled: Bool) {
        lovesButton.isEnabled = enabled
    }

    func toggleLoveState(loved: Bool) {
        lovesButton.isSelected = loved
    }
}
