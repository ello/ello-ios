////
///  EditorialPostCell.swift
//

class EditorialPostCell: EditorialTitledCell {
    fileprivate let buttonsContainer = UIView()
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
        lovesButton.isEnabled = config.post != nil
        commentButton.isEnabled = config.post != nil
        repostButton.isEnabled = config.post != nil
        shareButton.isEnabled = config.post != nil

        let loved = config.post?.loved ?? false
        lovesButton.isSelected = loved
    }

    override func arrange() {
        super.arrange()

        editorialContentView.addSubview(buttonsContainer)
        buttonsContainer.addSubview(lovesButton)
        buttonsContainer.addSubview(commentButton)
        buttonsContainer.addSubview(repostButton)
        buttonsContainer.addSubview(shareButton)

        buttonsContainer.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalTo(editorialContentView).inset(Size.defaultMargin)
        }

        let buttons = [lovesButton, commentButton, repostButton]
        buttons.eachPair { prevButton, button in
            button.snp.makeConstraints { make in
                make.top.bottom.equalTo(buttonsContainer)
            }

            if let prevButton = prevButton {
                button.snp.makeConstraints { make in
                    make.leading.equalTo(prevButton.snp.trailing).offset(Size.buttonsMargin)
                }
            }
            else {
            button.snp.makeConstraints { make in
                make.leading.equalTo(buttonsContainer)
            }
            }
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

        let responder = target(forAction: #selector(EditorialResponder.lovesTapped(post:cell:)), withSender: self) as? EditorialResponder
        responder?.lovesTapped(post: post, cell: self)
    }

    @objc
    func commentTapped() {
        guard let post = config.post else { return }

        let responder = target(forAction: #selector(EditorialResponder.commentTapped(post:cell:)), withSender: self) as? EditorialResponder
        responder?.commentTapped(post: post, cell: self)
    }

    @objc
    func repostTapped() {
        guard let post = config.post else { return }

        let responder = target(forAction: #selector(EditorialResponder.repostTapped(post:cell:)), withSender: self) as? EditorialResponder
        responder?.repostTapped(post: post, cell: self)
    }

    @objc
    func shareTapped() {
        guard let post = config.post else { return }

        let responder = target(forAction: #selector(EditorialResponder.shareTapped(post:cell:)), withSender: self) as? EditorialResponder
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
