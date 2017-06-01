////
///  CategoryHeaderCell.swift
//

import SnapKit
import FLAnimatedImage
import PINRemoteImage


class CategoryHeaderCell: UICollectionViewCell {
    static let reuseIdentifier = "CategoryHeaderCell"

    enum Style {
        case category
        case page
    }

    struct Config {
        var style: Style
        var title: String
        var tracking: String
        var body: String?
        var imageURL: URL?
        var user: User?
        var isSponsored: Bool?
        var callToAction: String?
        var callToActionURL: URL?

        init(style: Style) {
            self.style = style
            self.title = ""
            self.tracking = ""
        }
    }

    struct Size {
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

    fileprivate var imageSize: CGSize?
    fileprivate var aspectRatio: CGFloat? {
        guard let imageSize = imageSize else { return nil }
        return imageSize.width / imageSize.height
    }

    fileprivate var callToActionURL: URL?

    var config: Config = Config(style: .category) {
        didSet {
            titleLabel.attributedText = config.attributedTitle
            bodyLabel.attributedText = config.attributedBody
            setImageURL(config.imageURL)
            postedByAvatar.setUserAvatarURL(config.user?.avatarURL())
            postedByButton.setAttributedTitle(config.attributedPostedBy, for: .normal)
            callToActionURL = config.callToActionURL
            callToActionButton.setAttributedTitle(config.attributedCallToAction, for: .normal)

            if config.style == .category {
                titleUnderlineView.isHidden = false
                titleCenteredConstraint.update(priority: Priority.high)
                titleLeftConstraint.update(priority: Priority.low)
            }
            else {
                titleUnderlineView.isHidden = true
                titleCenteredConstraint.update(priority: Priority.low)
                titleLeftConstraint.update(priority: Priority.high)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        style()
        bindActions()
        arrange()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if callToActionButton.frame.intersects(postedByButton.frame) {
            // frames need to stack vertically
            postedByButtonAlignedConstraint.update(priority: Priority.low)
            postedByButtonStackedConstraint.update(priority: Priority.high)
            setNeedsLayout()
        }
        else if callToActionButton.frame.maxX < postedByButton.frame.minX && callToActionButton.frame.maxY < postedByButton.frame.minY {
            // frames should be restored to horizontal arrangement
            postedByButtonAlignedConstraint.update(priority: Priority.high)
            postedByButtonStackedConstraint.update(priority: Priority.low)
            setNeedsLayout()
        }
    }

    func setImageURL(_ url: URL?) {
        guard let url = url else {
            imageView.pin_cancelImageDownload()
            imageView.image = nil
            return
        }

        imageView.image = nil
        imageView.alpha = 0
        circle.pulse()
        failImage.isHidden = true
        failImage.alpha = 0
        imageView.backgroundColor = .white
        loadImage(url)
    }

    func setImage(_ image: UIImage) {
        imageView.pin_cancelImageDownload()
        imageView.image = image
        imageView.alpha = 1
        failImage.isHidden = true
        failImage.alpha = 0
        imageView.backgroundColor = .white
    }


    override func prepareForReuse() {
        super.prepareForReuse()
        let config = Config(style: .category)
        self.config = config
    }

    func postedByTapped() {
        Tracker.shared.categoryHeaderPostedBy(config.tracking)

        let responder: UserResponder? = findResponder()
        responder?.userTappedAuthor(cell: self)
    }

    func callToActionTapped() {
        guard let url = callToActionURL else { return }
        Tracker.shared.categoryHeaderCallToAction(config.tracking)
        let request = URLRequest(url: url)
        ElloWebViewHelper.handle(request: request, origin: self)
    }
}

private extension CategoryHeaderCell {

    func style() {
        titleLabel.numberOfLines = 0
        titleUnderlineView.backgroundColor = .white
        bodyLabel.numberOfLines = 0
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        callToActionButton.titleLabel?.numberOfLines = 0
        failBackgroundView.backgroundColor = .white
    }

    func bindActions() {
        callToActionButton.addTarget(self, action: #selector(callToActionTapped), for: .touchUpInside)
        postedByButton.addTarget(self, action: #selector(postedByTapped), for: .touchUpInside)
        postedByAvatar.addTarget(self, action: #selector(postedByTapped), for: .touchUpInside)
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

        circle.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }

        failBackgroundView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }

        failImage.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }

        imageView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }

        imageOverlay.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }

        titleLabel.snp.makeConstraints { make in
            titleCenteredConstraint = make.centerX.equalTo(contentView).priority(Priority.high).constraint
            titleLeftConstraint = make.leading.equalTo(contentView).inset(Size.defaultMargin).priority(Priority.low).constraint
            make.leading.greaterThanOrEqualTo(contentView).inset(Size.defaultMargin)
            make.trailing.lessThanOrEqualTo(contentView).inset(Size.defaultMargin)
            make.top.equalTo(contentView).offset(Size.topMargin)
        }

        titleUnderlineView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(titleLabel).inset(Size.lineInset)
            make.top.equalTo(titleLabel.snp.bottom).offset(Size.lineTopMargin)
            make.height.equalTo(Size.lineHeight)
        }

        bodyLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Size.bodyMargin)
            make.leading.trailing.equalTo(contentView).inset(Size.defaultMargin)
        }

        callToActionButton.snp.makeConstraints { make in
            make.leading.equalTo(contentView).inset(Size.defaultMargin)
            make.trailing.lessThanOrEqualTo(contentView).inset(Size.defaultMargin)
        }

        postedByButton.snp.makeConstraints { make in
            make.trailing.equalTo(postedByAvatar.snp.leading).offset(-Size.avatarMargin)
            make.centerY.equalTo(postedByAvatar).offset(3)
            postedByButtonAlignedConstraint = make.top.equalTo(callToActionButton).priority(Priority.high).constraint
            postedByButtonStackedConstraint = make.top.equalTo(callToActionButton.snp.bottom).offset(Size.stackedMargin).priority(Priority.low).constraint
        }

        postedByAvatar.snp.makeConstraints { make in
            make.width.height.equalTo(Size.avatarSize)
            make.trailing.equalTo(contentView).inset(Size.avatarMargin)
            make.bottom.equalTo(contentView).inset(Size.avatarMargin)
        }

    }

    func loadImage(_ url: URL) {
        guard url.scheme?.isEmpty == false else {
            if let urlWithScheme = URL(string: "https:\(url.absoluteString)") {
                loadImage(urlWithScheme)
            }
            return
        }

        imageView.pin_setImage(from: url) { [weak self] result in
            guard let `self` = self else { return }

            guard result.hasImage else {
                self.imageLoadFailed()
                return
            }

            self.imageSize = result.imageSize

            if result.resultType != .memoryCache {
                self.imageView.alpha = 0
                UIView.animate(
                    withDuration: 0.3,
                    delay:0.0,
                    options:UIViewAnimationOptions.curveLinear,
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
    }

    func imageLoadFailed() {
        failImage.isHidden = false
        failBackgroundView.isHidden = false
        circle.stopPulse()
        imageSize = nil
        UIView.animate(withDuration: 0.15, animations: {
            self.failImage.alpha = 1.0
            self.imageView.backgroundColor = UIColor.greyF1()
            self.failBackgroundView.backgroundColor = UIColor.greyF1()
            self.imageView.alpha = 1.0
            self.failBackgroundView.alpha = 1.0
        })
    }
}

extension CategoryHeaderCell.Config {

    var attributedTitle: NSAttributedString {
        switch style {
        case .category: return NSAttributedString(title, color: .white, font: .defaultFont(16), alignment: .center)
        case .page: return NSAttributedString(title, color: .white, font: .defaultFont(18))
        }
    }

    var attributedBody: NSAttributedString? {
        guard let body = body else { return nil }

        switch style {
        case .category: return NSAttributedString(body, color: .white)
        case .page: return NSAttributedString(body, color: .white, font: .defaultFont(16))
        }
    }

    var attributedPostedBy: NSAttributedString? {
        guard let user = user else { return nil }

        let prefix = isSponsored == true ? InterfaceString.Category.SponsoredBy : InterfaceString.Category.PostedBy
        let title = NSAttributedString(prefix, color: .white) + NSAttributedString(user.atName, color: .white, underlineStyle: .styleSingle)
        return title
    }

    var attributedCallToAction: NSAttributedString? {
        guard let callToAction = callToAction else { return nil }

        return NSAttributedString(callToAction, color: .white, underlineStyle: .styleSingle)
   }
}

extension CategoryHeaderCell.Config {

    init(category: Category) {
        self.init(style: .category)
        title = category.name
        body = category.body
        tracking = category.slug
        isSponsored = category.isSponsored
        callToAction = category.ctaCaption
        callToActionURL = category.ctaURL as URL?

        if let promotional = category.randomPromotional {
            imageURL = promotional.image?.oneColumnAttachment?.url as URL?
            user = promotional.user
        }
    }

    init(pagePromotional: PagePromotional) {
        self.init(style: .page)

        title = pagePromotional.header
        body = pagePromotional.subheader
        tracking = "general"
        imageURL = pagePromotional.tileURL as URL?
        user = pagePromotional.user
        callToAction = pagePromotional.ctaCaption
        callToActionURL = pagePromotional.ctaURL as URL?
    }
}
