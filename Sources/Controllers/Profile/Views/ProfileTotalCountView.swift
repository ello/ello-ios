////
///  ProfileTotalCountView.swift
//

public class ProfileTotalCountView: ProfileBaseView {

    private let totalLabel = UILabel()
    private let badgeButton = UIButton()
    private let greyLine = UIView()

    public struct Size {
        static let height: CGFloat = 60
        static let labelVerticalOffset: CGFloat = 3.5
        static let badgeMargin: CGFloat = 12
        static let badgeSize: CGFloat = 44
    }

    static let totalFont = UIFont.defaultFont(14)

    public var count: String? {
        didSet {
            updateAttributedCountText()
        }
    }

    public var badgeVisible: Bool {
        set { badgeButton.hidden = !newValue }
        get { return !badgeButton.hidden }
    }

    var onHeightMismatch: OnHeightMismatch?
}

extension ProfileTotalCountView {

    override func style() {
        clipsToBounds = true
        backgroundColor = .whiteColor()
        totalLabel.textAlignment = .Center
        badgeButton.setImages(.BadgeCheck)
        greyLine.backgroundColor = .greyE5()
    }

    override func bindActions() {
        badgeButton.addTarget(self, action: #selector(badgeTapped), forControlEvents: .TouchUpInside)
    }

    override func setText() {
        updateAttributedCountText()
    }

    override func arrange() {
        addSubview(totalLabel)
        addSubview(badgeButton)
        addSubview(greyLine)

        totalLabel.snp_makeConstraints { make in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self).offset(Size.labelVerticalOffset)
        }

        badgeButton.snp_makeConstraints { make in
            make.centerY.equalTo(self)
            make.trailing.equalTo(self).inset(Size.badgeMargin)
            make.width.height.equalTo(Size.badgeSize)
        }

        greyLine.snp_makeConstraints { make in
            make.height.equalTo(1)
            make.bottom.equalTo(self)
            make.leading.trailing.equalTo(self).inset(ProfileBaseView.Size.grayInset)
        }
    }

    public func prepareForReuse() {
    }
}

extension ProfileTotalCountView {

    func badgeTapped() {
        guard let cell: UICollectionViewCell = self.findParentView() else { return }

        let responder = targetForAction(#selector(ProfileHeaderResponder.onCategoryBadgeTapped(_:)), withSender: self) as? ProfileHeaderResponder
        responder?.onCategoryBadgeTapped(cell)
    }
}


private extension ProfileTotalCountView {

    func updateAttributedCountText() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Center

        if let count = count where count != "" {
            let attributedCount = NSAttributedString(count + " ", color: .blackColor())
            let totalViewsText = NSAttributedString(InterfaceString.Profile.TotalViews, color: UIColor.greyA())

            let attributed = NSMutableAttributedString()
            attributed.appendAttributedString(attributedCount)
            attributed.appendAttributedString(totalViewsText)
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
