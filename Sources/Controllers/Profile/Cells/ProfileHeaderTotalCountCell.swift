////
///  ProfileHeaderTotalCountCell.swift
//

class ProfileHeaderTotalCountCell: ProfileHeaderCell {
    static let reuseIdentifier = "ProfileHeaderTotalCountCell"

    private let totalLabel = UILabel()

    struct Size {
        static let height: CGFloat = 60
        static let labelVerticalOffset: CGFloat = 3.5
    }

    var count: String? {
        didSet {
            updateAttributedCountText()
        }
    }

    override func style() {
        clipsToBounds = true
        backgroundColor = .white
        totalLabel.textAlignment = .center
    }

    override func setText() {
        updateAttributedCountText()
    }

    override func arrange() {
        addSubview(totalLabel)

        totalLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self).offset(Size.labelVerticalOffset)
        }
    }
}

extension ProfileHeaderTotalCountCell {

    private func updateAttributedCountText() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        if let count = count, !count.isEmpty {
            let attributedCount = NSAttributedString(count + " ", color: .black)
            let totalViewsText = NSAttributedString(InterfaceString.Profile.TotalViews, color: UIColor.greyA)

            let attributed = NSMutableAttributedString()
            attributed.append(attributedCount)
            attributed.append(totalViewsText)
            totalLabel.attributedText = attributed
            if frame.height == 0 {
                heightMismatchOccurred(Size.height)
            }
        }
        else {
            totalLabel.text = ""
            if frame.height != 0 {
                heightMismatchOccurred(0)
            }
        }

        setNeedsLayout()
    }
}
