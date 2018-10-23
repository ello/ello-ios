////
///  StreamCreateCommentCell.swift
//

import FLAnimatedImage
import SnapKit


class StreamCreateCommentCell: CollectionViewCell {
    static let reuseIdentifier = "StreamCreateCommentCell"

    struct Size {
        static let Margins = UIEdgeInsets(top: 12, left: 15, bottom: 12, right: 15)
        static let AvatarRightMargin: CGFloat = 10
        static let ButtonLabelMargin: CGFloat = 30
        static let ReplyButtonSize: CGFloat = 50
        static let AvatarSize: CGFloat = 30
        static let WatchSize: CGFloat = 40
        static let WatchMargin: CGFloat = 14
        static let ReplyAllRightMargin: CGFloat = 5
    }

    let avatarView = FLAnimatedImageView()
    let createCommentBackground = CreateCommentBackgroundView()
    var watchButtonHiddenConstraint: Constraint!
    var replyAllButtonVisibleConstraint = ConstraintGroup()
    var replyAllButtonHiddenConstraint: Constraint!
    let createCommentLabel = UILabel()
    let replyAllButton = UIButton()
    let watchButton = UIButton()

    var isWatching = false {
        didSet {
            watchButton.setImage(.watch, imageStyle: isWatching ? .green : .normal, for: .normal)
        }
    }
    var avatarURL: URL? {
        willSet(value) {
            if let avatarURL = value {
                avatarView.pin_setImage(from: avatarURL)
            }
            else {
                avatarView.pin_cancelImageDownload()
                avatarView.image = nil
            }
        }
    }
    var watchVisibility: InteractionVisibility = .hidden {
        didSet {
            watchButton.isHidden = (watchVisibility != .enabled)
            updateCreateButtonConstraints()
        }
    }
    var replyAllVisibility: InteractionVisibility = .hidden {
        didSet {
            replyAllButton.isHidden = (replyAllVisibility != .enabled)
            updateCreateButtonConstraints()
        }
    }

    override func style() {
        contentView.backgroundColor = .white
        avatarView.backgroundColor = .black
        avatarView.clipsToBounds = true
        replyAllButton.setImage(.replyAll, imageStyle: .normal, for: .normal)
        replyAllButton.setImage(.replyAll, imageStyle: .selected, for: .highlighted)
        watchButton.setImage(.watch, imageStyle: .normal, for: .normal)
        watchButton.contentMode = .center
        createCommentLabel.font = .defaultFont()
        createCommentLabel.textColor = .white
        createCommentLabel.textAlignment = .left
    }

    override func setText() {
        createCommentLabel.text = InterfaceString.Post.CreateComment
    }

    override func bindActions() {
        replyAllButton.addTarget(self, action: #selector(replyAllTapped), for: .touchUpInside)
        watchButton.addTarget(self, action: #selector(watchTapped), for: .touchUpInside)
    }

    override func arrange() {
        contentView.addSubview(replyAllButton)
        contentView.addSubview(avatarView)
        contentView.addSubview(createCommentBackground)
        contentView.addSubview(watchButton)
        createCommentBackground.addSubview(createCommentLabel)

        avatarView.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(Size.Margins.left)
            make.centerY.equalTo(contentView)
            make.width.height.equalTo(Size.AvatarSize)
        }

        replyAllButton.snp.makeConstraints { make in
            make.trailing.equalTo(contentView).inset(Size.ReplyAllRightMargin)
            make.centerY.equalTo(contentView)
            make.width.height.equalTo(Size.ReplyButtonSize)
        }
        replyAllButton.snp.prepareConstraints { make in
            replyAllButtonVisibleConstraint.append(make.leading.equalTo(createCommentBackground.snp.trailing).constraint)
        }

        watchButton.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentView)
            make.trailing.equalTo(contentView).inset(Size.WatchMargin)
            make.width.equalTo(Size.WatchSize)
        }

        createCommentBackground.snp.makeConstraints { make in
            make.leading.equalTo(avatarView.snp.trailing).offset(Size.AvatarRightMargin)
            make.centerY.equalTo(contentView)
            make.height.equalTo(contentView).offset(-Size.Margins.tops)
        }
        createCommentBackground.snp.prepareConstraints { make in
            watchButtonHiddenConstraint = make.trailing.equalTo(contentView).inset(Size.Margins.right).constraint
            replyAllButtonVisibleConstraint.append(make.trailing.equalTo(replyAllButton.snp.leading).constraint)
            replyAllButtonHiddenConstraint = make.trailing.equalTo(watchButton.snp.leading).offset(-Size.WatchMargin).constraint
        }

        createCommentLabel.snp.makeConstraints { make in
            make.top.bottom.trailing.equalTo(createCommentBackground)
            make.leading.equalTo(createCommentBackground).offset(Size.ButtonLabelMargin)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.pin_cancelImageDownload()
        isWatching = false
        watchButtonHiddenConstraint.deactivate()
        replyAllButtonVisibleConstraint.deactivate()
        replyAllButtonHiddenConstraint.deactivate()
    }

    private func updateCreateButtonConstraints() {
        let bothHidden = replyAllButton.isHidden && watchButton.isHidden
        let onlyReplyHidden = replyAllButton.isHidden && watchButton.isVisible
        let noneHidden = replyAllButton.isVisible && watchButton.isVisible
        watchButtonHiddenConstraint.set(isActivated: bothHidden)
        replyAllButtonHiddenConstraint.set(isActivated: onlyReplyHidden)
        replyAllButtonVisibleConstraint.set(isActivated: noneHidden)

        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarView.setNeedsLayout()
        avatarView.layoutIfNeeded()
        avatarView.layer.cornerRadius = avatarView.frame.width / CGFloat(2)

        // if this doesn't fix the "stretched create comment" bug, please remove
        createCommentBackground.setNeedsDisplay()
    }

    @objc
    func replyAllTapped() {
        let responder: PostbarController? = findResponder()
        responder?.replyToAllButtonTapped(cell: self)
    }

    @objc
    func watchTapped() {
        let responder: PostbarController? = findResponder()
        responder?.watchPostTapped(!isWatching, cell: self)
    }

}
