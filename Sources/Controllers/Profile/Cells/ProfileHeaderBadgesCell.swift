////
///  ProfileBadgesView.swift
//

import FLAnimatedImage


class ProfileHeaderBadgesCell: ProfileHeaderCell {
    static let reuseIdentifier = "ProfileHeaderBadgesCell"

    struct Size {
        static let height: CGFloat = 60
        static let badgeSize = CGSize(width: 36, height: 44)
        static let imageEdgeInsets = UIEdgeInsets(top: 10, left: 6, bottom: 10, right: 6)
    }

    private static let maxBadges = 3

    var badges: [Badge] = [] {
        didSet { updateBadgeViews() }
    }
    var badgeButtons: [UIButton] = []

    private let badgesContainer = UIView()
    private let moreBadgesButton = UIButton()

    override func bindActions() {
        // the badgesContainer is "swallowing" tap events, but the entire badges area *other* than
        // the badge icons should open the "all badges" view.
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(moreBadgesTapped))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        badgesContainer.addGestureRecognizer(recognizer)

        moreBadgesButton.addTarget(self, action: #selector(moreBadgesTapped), for: .touchUpInside)
    }

    override func style() {
        backgroundColor = .white
    }

    override func arrange() {
        addSubview(moreBadgesButton)
        addSubview(badgesContainer)

        moreBadgesButton.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }

        badgesContainer.snp.makeConstraints { make in
            make.top.bottom.centerX.equalTo(self)
        }
    }

    private func updateBadgeViews() {
        for view in badgesContainer.subviews {
            view.removeFromSuperview()
        }

        badgeButtons = badges.safeRange(0 ..< ProfileHeaderBadgesCell.maxBadges).compactMap { (badge: Badge) -> UIButton? in
            guard let imageURL = badge.imageURL else { return nil }

            let button = UIButton()
            let imageView = FLAnimatedImageView()
            button.addTarget(self, action: #selector(badgeTapped(_:)), for: .touchUpInside)
            button.snp.makeConstraints { make in
                make.size.equalTo(Size.badgeSize)
            }
            button.imageEdgeInsets = Size.imageEdgeInsets

            imageView.pin_setImage(from: imageURL)
            button.addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.edges.equalTo(button).inset(Size.imageEdgeInsets)
            }

            return button
        }
        var badgeViews: [UIView] = badgeButtons

        if badges.count > ProfileHeaderBadgesCell.maxBadges {
            let view = UILabel()
            let remaining = badges.count - ProfileHeaderBadgesCell.maxBadges
            view.font = UIFont.defaultFont()
            view.text = "+\(remaining.numberToHuman())"
            view.textColor = .greyA
            badgeViews.append(view)
        }

        var prevView: UIView?
        for view in badgeViews {
            badgesContainer.addSubview(view)

            view.snp.makeConstraints { make in
                make.centerY.equalTo(badgesContainer)

                if let prevView = prevView {
                    make.leading.equalTo(prevView.snp.trailing)
                }
                else {
                    make.leading.equalTo(badgesContainer)
                }
            }

            prevView = view
        }

        if let prevView = prevView {
            prevView.snp.makeConstraints { make in
                make.trailing.equalTo(badgesContainer)
            }
        }
    }

}

extension ProfileHeaderBadgesCell {

    @objc
    func badgeTapped(_ sender: UIButton) {
        guard
            let buttonIndex = badgeButtons.index(of: sender)
        else { return }

        let badge = badges[buttonIndex]
        let responder: ProfileHeaderResponder? = findResponder()
        if badge.slug == "featured" {
            responder?.onCategoryBadgeTapped()
        }
        else {
            responder?.onBadgeTapped(badge.slug)
        }
    }

    @objc
    func moreBadgesTapped() {
        let responder: ProfileHeaderResponder? = findResponder()
        responder?.onMoreBadgesTapped()
    }

}
