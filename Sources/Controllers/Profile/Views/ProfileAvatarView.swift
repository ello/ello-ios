////
///  ProfileAvatarView.swift
//

class ProfileAvatarView: ProfileBaseView {

    struct Size {
        static let avatarSize: CGFloat = 180
        static let whiteBarHeight: CGFloat = 60

        static let badgeMarginTop: CGFloat = 8
        static let badgeMarginTrailing: CGFloat = -3
        static let badgeWidth: CGFloat = 44
        static let badgeHeight: CGFloat = 44
    }

    var avatarImage: UIImage? {
        get { return avatarImageView.image }
        set { avatarImageView.image = newValue }
    }

    var avatarURL: URL? {
        get { return _avatarURL }
        set {
            _avatarURL = newValue
            avatarImageView.pin_setImage(from: _avatarURL) { _ in
                // we may need to notify the cell of this
                // previously we hid the loader here
            }
        }
    }

    // temporarily move badge button here. Remove once Total Views is available
    fileprivate let badgeButton = UIButton()

    var badgeVisible: Bool {
        set { badgeButton.isHidden = !newValue }
        get { return !badgeButton.isHidden }
    }

    fileprivate let avatarImageView = FLAnimatedImageView()
    fileprivate let whiteBar = UIView()
    fileprivate var _avatarURL: URL?

    var onHeightMismatch: OnHeightMismatch?
}

extension ProfileAvatarView {

    override func style() {
        backgroundColor = .clear
        avatarImageView.backgroundColor = .greyF2()
        avatarImageView.clipsToBounds = true
        whiteBar.backgroundColor = .white
        badgeButton.setImages(.badgeCheck)
    }

    override func bindActions() {
        badgeButton.addTarget(self, action: #selector(badgeTapped), for: .touchUpInside)
    }

    override func setText() {}

    override func arrange() {
        super.arrange()

        addSubview(whiteBar)
        addSubview(avatarImageView)
        addSubview(badgeButton)

        avatarImageView.snp.makeConstraints { make in
            make.width.height.equalTo(Size.avatarSize)
            make.centerX.equalTo(self)
            make.bottom.equalTo(self)
        }

        whiteBar.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self)
            make.height.equalTo(Size.whiteBarHeight)
            make.bottom.equalTo(self.snp.bottom)
        }

        badgeButton.snp.makeConstraints { make in
            make.top.equalTo(whiteBar.snp.top).offset(Size.badgeMarginTop)
            make.trailing.equalTo(self).inset(Size.badgeMarginTrailing)
            make.width.equalTo(Size.badgeWidth)
            make.width.equalTo(Size.badgeWidth)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.layer.cornerRadius = Size.avatarSize / 2

        let desiredHeight = ProfileAvatarSizeCalculator.calculateHeight(maxWidth: frame.width)
        if desiredHeight != frame.height {
            onHeightMismatch?(desiredHeight)
        }
    }

    func prepareForReuse() {
        avatarImageView.pin_cancelImageDownload()
        avatarImageView.image = nil
        _avatarURL = nil
    }
}
extension ProfileAvatarView {

    func badgeTapped() {
        guard let cell: UICollectionViewCell = self.findParentView() else { return }

        let responder = target(forAction: #selector(ProfileHeaderResponder.onCategoryBadgeTapped(_:)), withSender: self) as? ProfileHeaderResponder
        responder?.onCategoryBadgeTapped(cell)
    }
}

extension ProfileAvatarView: ProfileViewProtocol {}
