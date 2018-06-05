////
///  CategoryHeaderCell.swift
//

import SnapKit
import FLAnimatedImage


class CategoryHeaderCell: CollectionViewCell {
    static let reuseIdentifier = "CategoryHeaderCell"

    struct Config {
        var title: String = ""
        var tracking: String = ""
        var imageURL: URL?
        var user: User?
        var isSubscribed = false
    }

    struct Size {
        static let height = calculateHeight()
        static let defaultMargin: CGFloat = 10
        static let titleMargin: CGFloat = 15
        static let avatarSize: CGFloat = 30
        static let subscribeIconSpacing: CGFloat = 0
        static let subscribeIconVerticalOffset: CGFloat = -20

        static private func calculateHeight() -> CGFloat {
            let aspect: CGFloat = 375.0 / 250.0
            return Globals.windowSize.width / aspect
        }
    }

    private let imageView = FLAnimatedImageView()
    private let imageOverlay = UIView()
    private let titleLabel = StyledLabel(style: .categoryHeader)
    private let subscribedIcon = UIImageView()
    private let postedByAvatar = AvatarButton()
    private let infoButton = StyledButton(style: .categoryInfo)
    private let circle = PulsingCircle()
    private let failImage = UIImageView()
    private let failBackgroundView = UIView()

    private var imageSize: CGSize?
    private var aspectRatio: CGFloat? {
        guard let imageSize = imageSize else { return nil }
        return imageSize.width / imageSize.height
    }

    var config: Config = Config() {
        didSet {
            updateConfig()
        }
    }

    override func style() {
        infoButton.title = InterfaceString.Info
        infoButton.contentEdgeInsets = UIEdgeInsets(tops: 10, sides: 20)
        infoButton.isUserInteractionEnabled = false
        titleLabel.numberOfLines = 0
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        failBackgroundView.backgroundColor = .white
    }

    override func bindActions() {
        postedByAvatar.addTarget(self, action: #selector(postedByTapped), for: .touchUpInside)
    }

    override func arrange() {
        contentView.addSubview(circle)
        contentView.addSubview(failBackgroundView)
        contentView.addSubview(failImage)

        contentView.addSubview(imageView)
        contentView.addSubview(imageOverlay)
        contentView.addSubview(titleLabel)
        contentView.addSubview(postedByAvatar)
        contentView.addSubview(subscribedIcon)
        contentView.addSubview(infoButton)

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
            make.leading.equalTo(contentView).inset(Size.titleMargin)
            make.trailing.lessThanOrEqualTo(contentView).inset(Size.titleMargin)
            make.centerY.equalTo(contentView)
        }

        subscribedIcon.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(-Size.subscribeIconSpacing)
            make.centerY.equalTo(titleLabel).offset(Size.subscribeIconVerticalOffset)
        }

        postedByAvatar.snp.makeConstraints { make in
            make.width.height.equalTo(Size.avatarSize)
            make.trailing.bottom.equalTo(contentView).inset(Size.defaultMargin)
        }

        infoButton.snp.makeConstraints { make in
            make.leading.bottom.equalTo(contentView).inset(Size.defaultMargin)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.config = Config()
    }

    private func updateConfig() {
        titleLabel.text = config.title

        setImageURL(config.imageURL)
        postedByAvatar.setUserAvatarURL(config.user?.avatarURL())

        subscribedIcon.setInterfaceImage(.circleCheckLarge, style: config.isSubscribed ? .green : .white)
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
}

extension CategoryHeaderCell {
    @objc
    func postedByTapped() {
        Tracker.shared.categoryHeaderPostedBy(config.tracking)

        let responder: UserResponder? = findResponder()
        responder?.userTappedAuthor(cell: self)
    }
}

private extension CategoryHeaderCell {

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

            if result.resultType != .memoryCache {
                self.imageView.alpha = 0
                elloAnimate {
                    self.imageView.alpha = 1
                }.done {
                    self.circle.stopPulse()
                }
            }
            else {
                self.imageView.alpha = 1
                self.circle.stopPulse()
            }

            self.layoutIfNeeded()
        }
    }

    func imageLoadFailed() {
        failImage.isVisible = true
        failBackgroundView.isVisible = true
        circle.stopPulse()
        UIView.animate(withDuration: 0.15, animations: {
            self.failImage.alpha = 1.0
            self.imageView.backgroundColor = UIColor.greyF1
            self.failBackgroundView.backgroundColor = UIColor.greyF1
            self.imageView.alpha = 1.0
            self.failBackgroundView.alpha = 1.0
        })
    }
}

extension CategoryHeaderCell.Config {

    init(pageHeader: PageHeader, isSubscribed: Bool) {
        self.init()

        title = pageHeader.header
        tracking = "general"
        imageURL = pageHeader.tileURL
        user = pageHeader.user
        self.isSubscribed = isSubscribed
    }
}

extension CategoryHeaderCell {
    class Specs {
        weak var target: CategoryHeaderCell!
        var postedByAvatar: AvatarButton! { return target.postedByAvatar }

        init(_ target: CategoryHeaderCell) {
            self.target = target
        }
    }

    func specs() -> Specs {
        return Specs(self)
    }
}
