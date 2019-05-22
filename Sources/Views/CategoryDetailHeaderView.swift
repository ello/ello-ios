////
///  CategoryDetailHeaderView.swift
//

import SnapKit
import PINRemoteImage


class CategoryDetailHeaderView: View {
    struct Size {
        static let height = calculateHeight()
        static let defaultMargin: CGFloat = 10
        static let textSpacing: CGFloat = 3
        static let titleTopMargin: CGFloat = calculateTopMargin()
        static let textSideMargin: CGFloat = 15
        static let subscribeTopMargin: CGFloat = 10
        static let avatarMargin: CGFloat = 10

        static private func calculateHeight() -> CGFloat {
            let aspect: CGFloat = 375.0 / 280.0
            return Globals.windowSize.width / aspect
        }

        static private func calculateTopMargin() -> CGFloat {
            return Globals.isIphoneX ? Globals.statusBarHeight : 22
        }
    }

    struct Config {
        let title: String
        let imageURL: URL?
        let user: User?
        let isSubscribed: Bool

        init(title: String = "", imageURL: URL? = nil, user: User? = nil, isSubscribed: Bool = false) {
            self.title = title
            self.imageURL = imageURL
            self.user = user
            self.isSubscribed = isSubscribed
        }
    }

    private let imageView = PINAnimatedImageView()
    private let imageOverlay = UIView()
    private let titleLabel = StyledLabel(style: .categoryHeaderScaledUp)
    private let subscribedButton = StyledButton(style: .subscribePill)
    private let headerByLabel = StyledLabel(style: .smallWhite)
    private let usernameButton = StyledButton(style: .smallWhiteUnderlined)
    private let postedByAvatar = AvatarButton()
    private let circle = PulsingCircle()
    private let failImage = UIImageView()
    private let failBackgroundView = UIView()

    var config: Config = Config() {
        didSet {
            updateConfig()
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: Globals.windowSize.width, height: Size.height)
    }

    override func setText() {
        headerByLabel.text = InterfaceString.Category.HeaderBy
        subscribedButton.setImage(.circleCheck, imageStyle: .white, for: .selected)
        subscribedButton.setImage(.circleCheck, imageStyle: .green, for: .normal)
    }

    override func style() {
        clipsToBounds = true
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.25
        titleLabel.baselineAdjustment = .alignCenters
        subscribedButton.contentEdgeInsets = UIEdgeInsets(top: 7, left: 5, bottom: 7, right: 15)
        subscribedButton.titleEdgeInsets = UIEdgeInsets(top: 2)
        subscribedButton.imageEdgeInsets = UIEdgeInsets(top: 2)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        failBackgroundView.backgroundColor = .white
    }

    override func bindActions() {
        usernameButton.addTarget(self, action: #selector(postedByTapped), for: .touchUpInside)
        postedByAvatar.addTarget(self, action: #selector(postedByTapped), for: .touchUpInside)
    }

    override func arrange() {
        addSubview(circle)
        addSubview(failBackgroundView)
        addSubview(failImage)
        addSubview(imageView)
        addSubview(imageOverlay)
        addSubview(titleLabel)
        addSubview(subscribedButton)
        addSubview(postedByAvatar)
        addSubview(headerByLabel)
        addSubview(usernameButton)

        circle.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }

        failBackgroundView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }

        failImage.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }

        imageView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }

        imageOverlay.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(self).inset(Size.textSideMargin)
            make.trailing.lessThanOrEqualTo(self).inset(Size.textSideMargin)
            make.top.equalTo(self).offset(Size.titleTopMargin)
        }

        subscribedButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Size.subscribeTopMargin)
            make.leading.equalTo(titleLabel)
        }

        postedByAvatar.snp.makeConstraints { make in
            make.size.equalTo(AvatarButton.Size.smallSize)
            make.trailing.bottom.equalTo(self).inset(Size.defaultMargin)
        }

        usernameButton.snp.makeConstraints { make in
            make.centerY.equalTo(postedByAvatar)
            make.trailing.equalTo(postedByAvatar.snp.leading).offset(-Size.textSpacing)
        }

        headerByLabel.snp.makeConstraints { make in
            make.centerY.equalTo(postedByAvatar)
            make.trailing.equalTo(usernameButton.snp.leading).offset(-Size.textSpacing)
        }
    }

    private func updateConfig() {
        usernameButton.title = config.user?.atName
        titleLabel.text = config.title

        setImageURL(config.imageURL)
        postedByAvatar.setUserAvatarURL(config.user?.avatarURL())

        subscribedButton.isSelected = config.isSubscribed
        subscribedButton.title = config.isSubscribed ? InterfaceString.Discover.Subscribed : InterfaceString.Discover.Subscribe
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

extension CategoryDetailHeaderView {
    @objc
    func postedByTapped() {
        guard let user = config.user else { return }
        let responder: UserTappedResponder? = findResponder()
        responder?.userTapped(user)
    }
}

private extension CategoryDetailHeaderView {

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

extension CategoryDetailHeaderView {
    class Specs {
        weak var target: CategoryDetailHeaderView!
        var postedByAvatar: AvatarButton! { return target.postedByAvatar }

        init(_ target: CategoryDetailHeaderView) {
            self.target = target
        }
    }

    func specs() -> Specs {
        return Specs(self)
    }
}
