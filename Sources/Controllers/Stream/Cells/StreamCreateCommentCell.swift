////
///  StreamCreateCommentCell.swift
//

import FLAnimatedImage
import SnapKit


class StreamCreateCommentCell: UICollectionViewCell {
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
    var replyAllButtonVisibleConstraint: Constraint!
    var replyAllButtonHiddenConstraint: Constraint!
    let createCommentLabel = UILabel()
    let replyAllButton = UIButton()
    let watchButton = UIButton()

    var watching = false {
        didSet {
            watchButton.setImage(.watch, imageStyle: watching ? .green : .normal, for: .normal)
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

    override init(frame: CGRect) {
        super.init(frame: frame)

        style()
        bindActions()
        arrange()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        style()
        bindActions()
        arrange()
    }

    fileprivate func style() {
        contentView.backgroundColor = .white
        avatarView.backgroundColor = .black
        avatarView.clipsToBounds = true
        replyAllButton.setImage(.replyAll, imageStyle: .normal, for: .normal)
        replyAllButton.setImage(.replyAll, imageStyle: .selected, for: .highlighted)
        watchButton.setImage(.watch, imageStyle: .normal, for: .normal)
        watchButton.contentMode = .center
        createCommentLabel.text = InterfaceString.Post.CreateComment
        createCommentLabel.font = .defaultFont()
        createCommentLabel.textColor = .white
        createCommentLabel.textAlignment = .left
    }

    fileprivate func bindActions() {
        replyAllButton.addTarget(self, action: #selector(replyAllTapped), for: .touchUpInside)
        watchButton.addTarget(self, action: #selector(watchTapped), for: .touchUpInside)
    }

    fileprivate func arrange() {
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
            make.leading.equalTo(createCommentBackground.snp.trailing)
            make.trailing.equalTo(contentView).inset(Size.ReplyAllRightMargin)
            make.centerY.equalTo(contentView)
            make.width.height.equalTo(Size.ReplyButtonSize)
        }

        watchButton.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentView)
            make.trailing.equalTo(contentView).inset(Size.WatchMargin)
            make.width.equalTo(Size.WatchSize)
        }

        createCommentBackground.snp.makeConstraints { make in
            make.leading.equalTo(avatarView.snp.trailing).offset(Size.AvatarRightMargin)
            make.centerY.equalTo(contentView)
            make.height.equalTo(contentView).offset(-Size.Margins.top - Size.Margins.bottom)
            watchButtonHiddenConstraint = make.trailing.equalTo(contentView).inset(Size.Margins.right).constraint
            replyAllButtonVisibleConstraint = make.trailing.equalTo(replyAllButton.snp.leading).constraint
            replyAllButtonHiddenConstraint = make.trailing.equalTo(watchButton.snp.leading).offset(-Size.WatchMargin).constraint
        }
        watchButtonHiddenConstraint.deactivate()
        replyAllButtonVisibleConstraint.deactivate()
        replyAllButtonHiddenConstraint.deactivate()

        createCommentLabel.snp.makeConstraints { make in
            make.top.bottom.trailing.equalTo(createCommentBackground)
            make.leading.equalTo(createCommentBackground).offset(Size.ButtonLabelMargin)
        }

        // if this doesn't fix the "stretched create comment" bug, please remove
        setNeedsLayout()
        layoutIfNeeded()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.pin_cancelImageDownload()
        watching = false
        watchButtonHiddenConstraint.deactivate()
        replyAllButtonVisibleConstraint.deactivate()
        replyAllButtonHiddenConstraint.deactivate()
    }

    fileprivate func updateCreateButtonConstraints() {
        if replyAllButton.isHidden && watchButton.isHidden {
            watchButtonHiddenConstraint.activate()
            replyAllButtonVisibleConstraint.deactivate()
            replyAllButtonHiddenConstraint.deactivate()
        }
        else if replyAllButton.isHidden {
            watchButtonHiddenConstraint.deactivate()
            replyAllButtonVisibleConstraint.deactivate()
            replyAllButtonHiddenConstraint.activate()
        }
        else {
            watchButtonHiddenConstraint.deactivate()
            replyAllButtonVisibleConstraint.activate()
            replyAllButtonHiddenConstraint.deactivate()
        }
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

    func replyAllTapped() {
        let responder: PostbarResponder? = findResponder()
        responder?.replyToAllButtonTapped(self)
    }

    func watchTapped() {
        let responder: PostbarResponder? = findResponder()
        responder?.watchPostTapped(!watching, cell: self)
    }

}
