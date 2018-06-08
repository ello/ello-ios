////
///  ProfileHeaderAvatarCell.swift
//

import FLAnimatedImage


class ProfileHeaderAvatarCell: ProfileHeaderCell {
    static let reuseIdentifier = "ProfileHeaderAvatarCell"

    struct Size {
        static let avatarSize: CGFloat = 180
        static let whiteBarHeight: CGFloat = 60
        static let ratio: CGFloat = 320 / 211

        static func calculateHeight(width: CGFloat) -> CGFloat {
            return ceil(width / ratio) + whiteBarHeight
        }
    }

    var avatarImage: UIImage? {
        get { return avatarImageView.image }
        set { avatarImageView.image = newValue }
    }

    var avatarURL: URL? {
        didSet {
            avatarImageView.pin_setImage(from: avatarURL) { _ in
                // we may need to notify the cell of this
                // previously we hid the loader here
            }
        }
    }

    private let avatarImageView = FLAnimatedImageView()
    private let whiteBar = UIView()

    override func style() {
        backgroundColor = .clear
        avatarImageView.backgroundColor = .greyF2
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        whiteBar.backgroundColor = .white
    }

    override func arrange() {
        super.arrange()

        addSubview(whiteBar)
        addSubview(avatarImageView)

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
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.layer.cornerRadius = Size.avatarSize / 2

        let desiredHeight = ProfileHeaderAvatarCell.Size.calculateHeight(width: frame.width)
        if desiredHeight != frame.height {
            heightMismatchOccurred(desiredHeight)
        }
    }
}

extension ProfileHeaderAvatarCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.pin_cancelImageDownload()
        avatarImageView.image = nil
        avatarURL = nil
    }
}
