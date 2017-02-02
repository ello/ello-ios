////
///  NotificationCell.swift
//

import FLAnimatedImage
import TimeAgoInWords


@objc
protocol NotificationResponder: class {
    func userTapped(_ user: User)
    func commentTapped(_ comment: ElloComment)
    func postTapped(_ post: Post)
}


class NotificationCell: UICollectionViewCell, UIWebViewDelegate {
    static let reuseIdentifier = "NotificationCell"

    struct Size {
        static let BuyButtonSize: CGFloat = 15
        static let BuyButtonMargin: CGFloat = 5
        static let ButtonHeight: CGFloat = 30
        static let ButtonMargin: CGFloat = 15
        static let WebHeightCorrection: CGFloat = -10
        static let SideMargins: CGFloat = 15
        static let AvatarSize: CGFloat = 30
        static let ImageWidth: CGFloat = 87
        static let InnerMargin: CGFloat = 10
        static let MessageMargin: CGFloat = 0
        static let CreatedAtHeight: CGFloat = 12
        // height of created at and margin from title / notification text
        static let CreatedAtFixedHeight = CreatedAtHeight + InnerMargin

        static func messageHtmlWidth(forCellWidth cellWidth: CGFloat, hasImage: Bool) -> CGFloat {
            let messageLeftMargin: CGFloat = SideMargins + AvatarSize + InnerMargin
            var messageRightMargin: CGFloat = SideMargins
            if hasImage {
                messageRightMargin += InnerMargin + ImageWidth
            }
            return cellWidth - messageLeftMargin - messageRightMargin
        }

        static func imageHeight(imageRegion: ImageRegion?) -> CGFloat {
            if let imageRegion = imageRegion {
                let aspectRatio = StreamImageCellSizeCalculator.aspectRatioForImageRegion(imageRegion)
                return ceil(ImageWidth / aspectRatio)
            }
            else {
                return 0
            }
        }
    }

    typealias WebContentReady = (_ webView: UIWebView) -> Void

    weak var webLinkDelegate: WebLinkDelegate?
    weak var userDelegate: UserDelegate?
    var webContentReady: WebContentReady?
    var onHeightMismatch: OnHeightMismatch?

    let avatarButton = AvatarButton()
    let buyButtonImage = UIImageView()
    let replyButton = StyledButton(style: .BlackPillOutline)
    let relationshipControl = RelationshipControl()
    let titleTextView = ElloTextView()
    let createdAtLabel = UILabel()
    let messageWebView = UIWebView()
    let notificationImageView = FLAnimatedImageView()
    let separator = UIView()
    var aspectRatio: CGFloat = 4/3

    var canReplyToComment: Bool {
        set {
            replyButton.isHidden = !newValue
            setNeedsLayout()
        }
        get { return !replyButton.isHidden }
    }
    var canBackFollow: Bool {
        set {
            relationshipControl.isHidden = !newValue
            setNeedsLayout()
        }
        get { return !relationshipControl.isHidden }
    }
    var buyButtonVisible: Bool {
        get { return !buyButtonImage.isHidden }
        set { buyButtonImage.isHidden = !newValue }
    }

    fileprivate var messageVisible = false
    fileprivate var _messageHtml = ""
    var messageHeight: CGFloat = 0
    var messageHtml: String? {
        get { return _messageHtml }
        set {
            if let value = newValue {
                messageVisible = true
                if value != _messageHtml {
                    messageWebView.isHidden = true
                }
                else {
                    messageWebView.isHidden = false
                }
                messageWebView.loadHTMLString(StreamTextCellHTML.postHTML(value), baseURL: URL(string: "/"))
                _messageHtml = value
            }
            else {
                messageWebView.isHidden = true
                messageVisible = false
            }
        }
    }

    var imageURL: URL? {
        didSet {
            self.notificationImageView.pin_setImage(from: imageURL) { result in
                let success = result?.image != nil || result?.animatedImage != nil
                let isAnimated = result?.animatedImage != nil
                if success {
                    let imageSize = isAnimated ? result?.animatedImage.size : result?.image.size
                    self.aspectRatio = (imageSize?.width)! / (imageSize?.height)!
                    let currentRatio = self.notificationImageView.frame.width / self.notificationImageView.frame.height
                    if currentRatio != self.aspectRatio {
                        self.setNeedsLayout()
                    }
                }
            }
            self.setNeedsLayout()
        }
    }

    var title: NSAttributedString? {
        didSet {
            titleTextView.attributedText = title
        }
    }

    var createdAt: Date? {
        didSet {
            if let date = createdAt {
                createdAtLabel.text = date.timeAgoInWords()
            }
            else {
                createdAtLabel.text = ""
            }
        }
    }

    var user: User? {
        didSet {
            setUser(user)
        }
    }
    var post: Post?
    var comment: ElloComment?

    override init(frame: CGRect) {
        super.init(frame: frame)

        avatarButton.addTarget(self, action: #selector(avatarTapped), for: .touchUpInside)
        titleTextView.textViewDelegate = self

        buyButtonImage.isHidden = true
        buyButtonImage.image = InterfaceImage.buyButton.normalImage
        buyButtonImage.frame.size = CGSize(width: Size.BuyButtonSize, height: Size.BuyButtonSize)
        buyButtonImage.backgroundColor = .greenD1()
        buyButtonImage.layer.cornerRadius = Size.BuyButtonSize / 2

        replyButton.isHidden = true
        replyButton.setTitle(InterfaceString.Notifications.Reply, for: .normal)
        replyButton.setImage(InterfaceImage.reply.selectedImage, for: .normal)
        replyButton.contentEdgeInsets.left = 10
        replyButton.contentEdgeInsets.right = 10
        replyButton.imageEdgeInsets.right = 5

        replyButton.addTarget(self, action: #selector(replyTapped), for: .touchUpInside)

        relationshipControl.isHidden = true
        relationshipControl.showStarButton = false

        notificationImageView.contentMode = .scaleAspectFit
        messageWebView.isOpaque = false
        messageWebView.backgroundColor = .clear
        messageWebView.scrollView.isScrollEnabled = false
        messageWebView.delegate = self

        createdAtLabel.textColor = UIColor.greyA()
        createdAtLabel.font = UIFont.defaultFont(12)
        createdAtLabel.text = ""

        separator.backgroundColor = .greyE5()

        for view in [avatarButton, titleTextView, messageWebView,
                     notificationImageView, buyButtonImage, createdAtLabel,
                     replyButton, relationshipControl, separator] {
            self.contentView.addSubview(view)
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func onWebContentReady(_ handler: WebContentReady?) {
        webContentReady = handler
    }

    fileprivate func setUser(_ user: User?) {
        avatarButton.setUserAvatarURL(user?.avatarURL())

        if let user = user {
            relationshipControl.userId = user.id
            relationshipControl.userAtName = user.atName
            relationshipControl.relationshipPriority = user.relationshipPriority
        }
        else {
            relationshipControl.userId = ""
            relationshipControl.userAtName = ""
            relationshipControl.relationshipPriority = .none
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let outerFrame = contentView.bounds.inset(all: Size.SideMargins)
        let titleWidth = Size.messageHtmlWidth(forCellWidth: self.frame.width, hasImage: imageURL != nil)
        separator.frame = contentView.bounds.fromBottom().grow(up: 1)

        avatarButton.frame = outerFrame.with(size: CGSize(width: Size.AvatarSize, height: Size.AvatarSize))

        if imageURL == nil {
            notificationImageView.frame = .zero
        }
        else {
            notificationImageView.frame = outerFrame.fromRight()
                .grow(left: Size.ImageWidth)
                .with(height: Size.ImageWidth / aspectRatio)
            buyButtonImage.frame.origin = CGPoint(
                x: notificationImageView.frame.maxX - Size.BuyButtonSize - Size.BuyButtonMargin,
                y: notificationImageView.frame.minY + Size.BuyButtonMargin
                )
        }

        titleTextView.frame = avatarButton.frame.fromRight()
            .shift(right: Size.InnerMargin)
            .with(width: titleWidth)

        let tvSize = titleTextView.sizeThatFits(CGSize(width: titleWidth, height: .greatestFiniteMagnitude))
        titleTextView.frame.size.height = ceil(tvSize.height)

        var createdAtY = titleTextView.frame.maxY + Size.InnerMargin

        if messageVisible {
            createdAtY += messageHeight + Size.MessageMargin
            messageWebView.frame = titleTextView.frame.fromBottom()
                .with(width: titleWidth)
                .shift(down: Size.InnerMargin)
                .with(height: messageHeight)
        }

        createdAtLabel.frame = CGRect(
            x: avatarButton.frame.maxX + Size.InnerMargin,
            y: createdAtY,
            width: titleWidth,
            height: Size.CreatedAtHeight
            )

        let replyButtonWidth = replyButton.intrinsicContentSize.width
        replyButton.frame = CGRect(
            x: createdAtLabel.frame.x,
            y: createdAtY + Size.CreatedAtHeight + Size.InnerMargin,
            width: replyButtonWidth,
            height: Size.ButtonHeight
            )
        let relationshipControlWidth = relationshipControl.intrinsicContentSize.width
        relationshipControl.frame = replyButton.frame.with(width: relationshipControlWidth)

        let bottomControl: UIView
        if !replyButton.isHidden {
            bottomControl = replyButton
        }
        else if !relationshipControl.isHidden {
            bottomControl = relationshipControl
        }
        else {
            bottomControl = createdAtLabel
        }

        let actualHeight = ceil(max(notificationImageView.frame.maxY, bottomControl.frame.maxY)) + Size.SideMargins
        // don't update the height if
        // - imageURL is set, but hasn't finished loading, OR
        // - messageHTML is set, but hasn't finished loading
        if actualHeight != frame.size.height && (imageURL == nil || notificationImageView.image != nil) && (!messageVisible || !messageWebView.isHidden) {
            self.onHeightMismatch?(actualHeight)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        messageWebView.stopLoading()
        messageWebView.isHidden = true
        avatarButton.pin_cancelImageDownload()
        avatarButton.setImage(nil, for: .normal)
        notificationImageView.pin_cancelImageDownload()
        notificationImageView.image = nil
        aspectRatio = 4/3
        canReplyToComment = false
        canBackFollow = false
        imageURL = nil
        buyButtonImage.isHidden = true
    }

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let scheme = request.url?.scheme, scheme == "default"
        {
            userDelegate?.userTappedText(cell: self)
            return false
        }
        else {
            return ElloWebViewHelper.handle(request: request, webLinkDelegate: webLinkDelegate)
        }
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        if messageVisible {
            messageWebView.isHidden = !messageVisible
        }
        webContentReady?(webView)
        if let height = webView.windowContentSize()?.height {
            messageHeight = height
        }
        else {
            messageHeight = 0
        }
        setNeedsLayout()
    }
}

extension NotificationCell: ElloTextViewDelegate {
    func textViewTapped(_ link: String, object: ElloAttributedObject) {
        switch object {
        case let .attributedPost(post):
            let responder = target(forAction: #selector(NotificationResponder.postTapped(_:)), withSender: self) as? NotificationResponder
            responder?.postTapped(post)
        case let .attributedComment(comment):
            let responder = target(forAction: #selector(NotificationResponder.commentTapped(_:)), withSender: self) as? NotificationResponder
            responder?.commentTapped(comment)
        case let .attributedUser(user):
            let responder = target(forAction: #selector(NotificationResponder.userTapped(_:)), withSender: self) as? NotificationResponder
            responder?.userTapped(user)
        default: break
        }
    }

    func textViewTappedDefault() {
        userDelegate?.userTappedText(cell: self)
    }
}

extension NotificationCell {

    func replyTapped() {
        if let post = post {
            let responder = target(forAction: #selector(NotificationResponder.postTapped(_:)), withSender: self) as? NotificationResponder
            responder?.postTapped(post)
        }
        else if let comment = comment {
            let responder = target(forAction: #selector(NotificationResponder.commentTapped(_:)), withSender: self) as? NotificationResponder
            responder?.commentTapped(comment)
        }
    }

    func avatarTapped() {
        userDelegate?.userTappedAuthor(cell: self)
    }

}
