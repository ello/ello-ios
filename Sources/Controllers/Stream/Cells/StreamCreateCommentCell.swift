////
///  StreamCreateCommentCell.swift
//

import FLAnimatedImage

public class StreamCreateCommentCell: UICollectionViewCell {
    static let reuseIdentifier = "StreamCreateCommentCell"

    public struct Size {
        public static let Margins = UIEdgeInsets(top: 12, left: 15, bottom: 12, right: 15)
        public static let AvatarButtonMargin: CGFloat = 6
        public static let ButtonLabelMargin: CGFloat = 30
        public static let ImageHeight: CGFloat = 30
    }

    weak var delegate: PostbarDelegate?
    let avatarView = FLAnimatedImageView()
    let createCommentBackground = CreateCommentBackgroundView()
    let createCommentLabel = UILabel()
    let replyAllButton = UIButton()

    var avatarURL: NSURL? {
        willSet(value) {
            if let avatarURL = value {
                avatarView.pin_setImageFromURL(avatarURL)
            }
            else {
                avatarView.pin_cancelImageDownload()
                avatarView.image = nil
            }
        }
    }

    var replyAllVisibility: InteractionVisibility = .Hidden {
        didSet {
            replyAllButton.hidden = (replyAllVisibility != .Enabled)
            setNeedsLayout()
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)

        setupViews()
    }

    private func setupViews() {
        self.contentView.backgroundColor = UIColor.whiteColor()
        self.contentView.addSubview(replyAllButton)
        self.contentView.addSubview(avatarView)
        self.contentView.addSubview(createCommentBackground)
        createCommentBackground.addSubview(createCommentLabel)

        replyAllButton.setImage(.ReplyAll, imageStyle: .Normal, forState: .Normal)
        replyAllButton.setImage(.ReplyAll, imageStyle: .Selected, forState: .Highlighted)
        replyAllButton.addTarget(self, action: #selector(replyAllTapped), forControlEvents: .TouchUpInside)

        avatarView.backgroundColor = UIColor.blackColor()
        avatarView.clipsToBounds = true

        // the size of this frame is not important, it's just used to "seed" the
        // autoresizingMask calculations
        createCommentBackground.frame = CGRect(x: 0, y: 0, width: 100, height: StreamCellType.CreateComment.oneColumnHeight)

        createCommentLabel.frame = createCommentBackground.bounds.inset(top: 0, left: Size.ButtonLabelMargin, bottom: 0, right: 0)
        createCommentLabel.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        createCommentLabel.text = "Comment..."
        createCommentLabel.font = UIFont.defaultFont()
        createCommentLabel.textColor = UIColor.whiteColor()
        createCommentLabel.textAlignment = .Left

        // if this doesn't fix the "stretched create comment" bug, please remove
        setNeedsLayout()
        layoutIfNeeded()
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        avatarView.pin_cancelImageDownload()
    }

    override public func layoutSubviews() {
        let imageY = (self.frame.height - Size.ImageHeight) / CGFloat(2)
        avatarView.frame = CGRect(x: Size.Margins.left, y: imageY, width: Size.ImageHeight, height: Size.ImageHeight)
        avatarView.layer.cornerRadius = Size.ImageHeight / CGFloat(2)

        let createBackgroundLeft = avatarView.frame.maxX + Size.AvatarButtonMargin
        let createBackgroundWidth = self.frame.width - createBackgroundLeft - Size.Margins.right
        createCommentBackground.frame = CGRect(x: createBackgroundLeft, y: Size.Margins.top, width: createBackgroundWidth, height: self.frame.height - Size.Margins.top - Size.Margins.bottom)
        // if this doesn't fix the "stretched create comment" bug, please remove
        createCommentBackground.setNeedsDisplay()

        if replyAllVisibility == .Enabled {
            let btnWidth = createCommentBackground.frame.width
            createCommentBackground.frame.size.width -= btnWidth
            replyAllButton.frame = createCommentBackground.frame.fromRight().growRight(btnWidth)
        }
    }

    func replyAllTapped() {
        guard let indexPath = indexPath else { return }
        delegate?.replyToAllButtonTapped(indexPath)
    }

}
