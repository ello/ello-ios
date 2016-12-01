////
///  CategoryHeaderCell.swift
//

import SnapKit
import FLAnimatedImage
import PINRemoteImage


public class CategoryHeaderCell: UICollectionViewCell {
    static let reuseIdentifier = "CategoryHeaderCell"

    public enum Style {
        case Category
        case Page
    }

    public struct Config {
        var style: Style
        var title: String
        var tracking: String
        var body: String?
        var imageURL: NSURL?
        var user: User?
        var isSponsored: Bool?
        var callToAction: String?
        var callToActionURL: NSURL?

        public init(style: Style) {
            self.style = style
            self.title = ""
            self.tracking = ""
        }
    }

    public struct Size {
        static let defaultMargin: CGFloat = 15
        static let topMargin: CGFloat = 25
        static let bodyMargin: CGFloat = 24
        static let stackedMargin: CGFloat = 6
        static let lineTopMargin: CGFloat = 4
        static let lineHeight: CGFloat = 2
        static let lineInset: CGFloat = 0
        static let avatarMargin: CGFloat = 10
        static let avatarSize: CGFloat = 30
        static let minBodyHeight: CGFloat = 30
        static let circleBottomInset: CGFloat = 10
        static let failImageWidth: CGFloat = 140
        static let failImageHeight: CGFloat = 160
    }

    public weak var webLinkDelegate: WebLinkDelegate?
    public weak var userDelegate: UserDelegate?

    let imageView = FLAnimatedImageView()
    let imageOverlay = UIView()
    let titleLabel = UILabel()
    let titleUnderlineView = UIView()
    let bodyLabel = UILabel()
    let callToActionButton = UIButton()
    let postedByButton = UIButton()
    let postedByAvatar = AvatarButton()

    var titleCenteredConstraint: Constraint!
    var titleLeftConstraint: Constraint!
    var postedByButtonAlignedConstraint: Constraint!
    var postedByButtonStackedConstraint: Constraint!

    let circle = PulsingCircle()
    let failImage = UIImageView()
    let failBackgroundView = UIView()
    var failWidthConstraint: Constraint!
    var failHeightConstraint: Constraint!

    private var imageSize: CGSize?
    private var aspectRatio: CGFloat? {
        guard let imageSize = imageSize else { return nil }
        return imageSize.width / imageSize.height
    }

    private var callToActionURL: NSURL?

    var calculatedHeight: CGFloat? {
        guard let aspectRatio = aspectRatio else {
            return nil
        }
        return frame.width / aspectRatio
    }

    public var config: Config = Config(style: .Category) {
        didSet {
            titleLabel.attributedText = config.attributedTitle
            bodyLabel.attributedText = config.attributedBody
            setImageURL(config.imageURL)
            postedByAvatar.setUserAvatarURL(config.user?.avatarURL())
            postedByButton.setAttributedTitle(config.attributedPostedBy, forState: .Normal)
            callToActionURL = config.callToActionURL
            callToActionButton.setAttributedTitle(config.attributedCallToAction, forState: .Normal)

            if config.style == .Category {
                titleUnderlineView.hidden = false
                titleCenteredConstraint.updatePriorityHigh()
                titleLeftConstraint.updatePriorityLow()
            }
            else {
                titleUnderlineView.hidden = true
                titleCenteredConstraint.updatePriorityLow()
                titleLeftConstraint.updatePriorityHigh()
            }
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)

        style()
        bindActions()
        arrange()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        if callToActionButton.frame.intersects(postedByButton.frame) {
            // frames need to stack vertically
            postedByButtonAlignedConstraint.updatePriorityLow()
            postedByButtonStackedConstraint.updatePriorityHigh()
            setNeedsLayout()
        }
        else if callToActionButton.frame.maxX < postedByButton.frame.minX && callToActionButton.frame.maxY < postedByButton.frame.minY {
            // frames should be restored to horizontal arrangement
            postedByButtonAlignedConstraint.updatePriorityHigh()
            postedByButtonStackedConstraint.updatePriorityLow()
            setNeedsLayout()
        }
    }

    public func setImageURL(url: NSURL?) {
        guard let url = url else {
            imageView.image = nil
            return
        }

        imageView.image = nil
        imageView.alpha = 0
        circle.pulse()
        failImage.hidden = true
        failImage.alpha = 0
        imageView.backgroundColor = .whiteColor()
        loadImage(url)
    }

    public func setImage(image: UIImage) {
        imageView.pin_cancelImageDownload()
        imageView.image = image
        imageView.alpha = 1
        failImage.hidden = true
        failImage.alpha = 0
        imageView.backgroundColor = .whiteColor()
    }


    public override func prepareForReuse() {
        super.prepareForReuse()
        let config = Config(style: .Category)
        self.config = config
        webLinkDelegate = nil
        userDelegate = nil
    }

    public func postedByTapped() {
        Tracker.sharedTracker.categoryHeaderPostedBy(config.tracking)
        userDelegate?.userTappedAuthor(self)
    }

    public func callToActionTapped() {
        guard let url = callToActionURL else { return }
        Tracker.sharedTracker.categoryHeaderCallToAction(config.tracking)
        let request = NSURLRequest(URL: url)
        ElloWebViewHelper.handleRequest(request, webLinkDelegate: webLinkDelegate)
    }
}

private extension CategoryHeaderCell {

    func style() {
        titleLabel.numberOfLines = 0
        titleUnderlineView.backgroundColor = .whiteColor()
        bodyLabel.numberOfLines = 0
        imageView.clipsToBounds = true
        imageView.contentMode = .ScaleAspectFill
        imageOverlay.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        callToActionButton.titleLabel?.numberOfLines = 0
        failBackgroundView.backgroundColor = .whiteColor()
    }

    func bindActions() {
        callToActionButton.addTarget(self, action: #selector(callToActionTapped), forControlEvents: .TouchUpInside)
        postedByButton.addTarget(self, action: #selector(postedByTapped), forControlEvents: .TouchUpInside)
        postedByAvatar.addTarget(self, action: #selector(postedByTapped), forControlEvents: .TouchUpInside)
    }

    func arrange() {
        contentView.addSubview(circle)
        contentView.addSubview(failBackgroundView)
        contentView.addSubview(failImage)

        contentView.addSubview(imageView)
        contentView.addSubview(imageOverlay)
        contentView.addSubview(titleLabel)
        contentView.addSubview(titleUnderlineView)
        contentView.addSubview(bodyLabel)
        contentView.addSubview(callToActionButton)
        contentView.addSubview(postedByButton)
        contentView.addSubview(postedByAvatar)

        circle.snp_makeConstraints { make in
            make.edges.equalTo(contentView)
        }

        failBackgroundView.snp_makeConstraints { make in
            make.edges.equalTo(contentView)
        }

        failImage.snp_makeConstraints { make in
            make.center.equalTo(contentView)
            failWidthConstraint = make.leading.equalTo(Size.failImageWidth).constraint
            failHeightConstraint = make.leading.equalTo(Size.failImageHeight).constraint
        }

        imageView.snp_makeConstraints { make in
            make.edges.equalTo(contentView)
        }

        imageOverlay.snp_makeConstraints { make in
            make.edges.equalTo(contentView)
        }

        titleLabel.snp_makeConstraints { make in
            titleCenteredConstraint = make.centerX.equalTo(contentView).priorityHigh().constraint
            titleLeftConstraint = make.leading.equalTo(contentView).inset(Size.defaultMargin).priorityLow().constraint
            make.leading.greaterThanOrEqualTo(contentView).inset(Size.defaultMargin)
            make.trailing.lessThanOrEqualTo(contentView).inset(Size.defaultMargin)
            make.top.equalTo(contentView).offset(Size.topMargin)
        }

        titleUnderlineView.snp_makeConstraints { make in
            make.leading.trailing.equalTo(titleLabel).inset(Size.lineInset)
            make.top.equalTo(titleLabel.snp_bottom).offset(Size.lineTopMargin)
            make.height.equalTo(Size.lineHeight)
        }

        bodyLabel.snp_makeConstraints { make in
            make.top.equalTo(titleLabel.snp_bottom).offset(Size.bodyMargin)
            make.leading.trailing.equalTo(contentView).inset(Size.defaultMargin)
        }

        callToActionButton.snp_makeConstraints { make in
            make.leading.equalTo(contentView).inset(Size.defaultMargin)
            make.trailing.lessThanOrEqualTo(contentView).inset(Size.defaultMargin)
        }

        postedByButton.snp_makeConstraints { make in
            make.trailing.equalTo(postedByAvatar.snp_leading).offset(-Size.avatarMargin)
            make.centerY.equalTo(postedByAvatar).offset(3)
            postedByButtonAlignedConstraint = make.top.equalTo(callToActionButton).priorityHigh().constraint
            postedByButtonStackedConstraint = make.top.equalTo(callToActionButton.snp_bottom).offset(Size.stackedMargin).priorityLow().constraint
        }

        postedByAvatar.snp_makeConstraints { make in
            make.width.height.equalTo(Size.avatarSize)
            make.trailing.equalTo(contentView).inset(Size.avatarMargin)
            make.bottom.equalTo(contentView).inset(Size.avatarMargin)
        }

    }

    func loadImage(url: NSURL) {
        guard url.scheme?.isEmpty == false else {
            if let urlWithScheme = NSURL(string: "https:\(url.absoluteString)") {
                loadImage(urlWithScheme)
            }
            return
        }
        self.imageView.pin_setImageFromURL(url) { result in
            let success = result.image != nil || result.animatedImage != nil
            let isAnimated = result.animatedImage != nil
            if success {
                let imageSize = isAnimated ? result.animatedImage.size : result.image.size
                self.imageSize = imageSize

                if result.resultType != .MemoryCache {
                    self.imageView.alpha = 0
                    UIView.animateWithDuration(0.3,
                                               delay:0.0,
                                               options:UIViewAnimationOptions.CurveLinear,
                                               animations: {
                                                self.imageView.alpha = 1.0
                        }, completion: { _ in
                            self.circle.stopPulse()
                    })
                }
                else {
                    self.imageView.alpha = 1.0
                    self.circle.stopPulse()
                }

                self.layoutIfNeeded()
            }
            else {
                self.imageLoadFailed()
            }
        }
    }

    func imageLoadFailed() {
        failImage.hidden = false
        failBackgroundView.hidden = false
        circle.stopPulse()
        imageSize = nil
        UIView.animateWithDuration(0.15) {
            self.failImage.alpha = 1.0
            self.imageView.backgroundColor = UIColor.greyF1()
            self.failBackgroundView.backgroundColor = UIColor.greyF1()
            self.imageView.alpha = 1.0
            self.failBackgroundView.alpha = 1.0
        }
    }
}

extension CategoryHeaderCell.Config {

    var attributedTitle: NSAttributedString {
        switch style {
        case .Category: return NSAttributedString(title, color: .whiteColor(), font: .defaultFont(16), alignment: .Center)
        case .Page: return NSAttributedString(title, color: .whiteColor(), font: .defaultFont(18))
        }
    }

    var attributedBody: NSAttributedString? {
        guard let body = body else { return nil }

        switch style {
        case .Category: return NSAttributedString(body, color: .whiteColor())
        case .Page: return NSAttributedString(body, color: .whiteColor(), font: .defaultFont(16))
        }
    }

    var attributedPostedBy: NSAttributedString? {
        guard let user = user else { return nil }

        let prefix = isSponsored == true ? InterfaceString.Category.SponsoredBy : InterfaceString.Category.PostedBy
        let title = NSAttributedString(prefix, color: .whiteColor()) + NSAttributedString(user.atName, color: .whiteColor(), underlineStyle: .StyleSingle)
        return title
    }

    var attributedCallToAction: NSAttributedString? {
        guard let callToAction = callToAction else { return nil }

        return NSAttributedString(callToAction, color: .whiteColor(), underlineStyle: .StyleSingle)
   }
}

extension CategoryHeaderCell.Config {

    init(category: Category) {
        self.init(style: .Category)
        title = category.name
        body = category.body
        tracking = category.slug
        isSponsored = category.isSponsored
        callToAction = category.ctaCaption
        callToActionURL = category.ctaURL

        if let promotional = category.randomPromotional {
            imageURL = promotional.image?.xhdpi?.url
            user = promotional.user
        }
    }

    init(pagePromotional: PagePromotional) {
        self.init(style: .Page)

        title = pagePromotional.header
        body = pagePromotional.subheader
        tracking = "general"
        imageURL = pagePromotional.tileURL
        user = pagePromotional.user
        callToAction = pagePromotional.ctaCaption
        callToActionURL = pagePromotional.ctaURL
    }
}
