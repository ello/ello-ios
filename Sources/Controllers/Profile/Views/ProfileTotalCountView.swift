////
///  ProfileTotalCountView.swift
//

class ProfileTotalCountView: ProfileBaseView {

    fileprivate let totalLabel = UILabel()
    fileprivate let badgeButton = UIButton()
    fileprivate let greyLine = UIView()

    struct Size {
        static let height: CGFloat = 60
        static let labelVerticalOffset: CGFloat = 3.5
        static let badgeMargin: CGFloat = 12
        static let badgeSize: CGFloat = 44
    }

    static let totalFont = UIFont.defaultFont(14)

    var count: String? {
        didSet {
            updateAttributedCountText()
        }
    }

    var badgeVisible: Bool {
        set { badgeButton.isHidden = !newValue }
        get { return !badgeButton.isHidden }
    }

    var onHeightMismatch: OnHeightMismatch?
}

extension ProfileTotalCountView {

    override func style() {
        clipsToBounds = true
        backgroundColor = .white
        totalLabel.textAlignment = .center
        badgeButton.setImages(.badgeCheck)
        greyLine.backgroundColor = .greyE5()
    }

    override func bindActions() {
        badgeButton.addTarget(self, action: #selector(badgeTapped), for: .touchUpInside)
    }

    override func setText() {
        updateAttributedCountText()
    }

    override func arrange() {
        addSubview(totalLabel)
        addSubview(badgeButton)
        addSubview(greyLine)

        totalLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self).offset(Size.labelVerticalOffset)
        }

        badgeButton.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.trailing.equalTo(self).inset(Size.badgeMargin)
            make.width.height.equalTo(Size.badgeSize)
        }

        greyLine.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.bottom.equalTo(self)
            make.leading.trailing.equalTo(self).inset(ProfileBaseView.Size.grayInset)
        }
    }

    func prepareForReuse() {
    }
}

extension ProfileTotalCountView {

    func badgeTapped() {
        guard let cell: UICollectionViewCell = self.findParentView() else { return }

        let responder = target(forAction: #selector(ProfileHeaderResponder.onCategoryBadgeTapped(_:)), withSender: self) as? ProfileHeaderResponder
        responder?.onCategoryBadgeTapped(cell)
    }
}


private extension ProfileTotalCountView {

    func updateAttributedCountText() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        if let count = count, !count.isEmpty {
            let attributedCount = NSAttributedString(count + " ", color: .black)
            let totalViewsText = NSAttributedString(InterfaceString.Profile.TotalViews, color: UIColor.greyA())

            let attributed = NSMutableAttributedString()
            attributed.append(attributedCount)
            attributed.append(totalViewsText)
            totalLabel.attributedText = attributed
            if frame.height == 0 {
                onHeightMismatch?(Size.height)
            }
        }
        else {
            totalLabel.text = ""
            if frame.height != 0 {
                onHeightMismatch?(0)
            }
        }

        setNeedsLayout()
    }
}

extension ProfileTotalCountView: ProfileViewProtocol {}
