////
///  CategoryPostHistoryCell.swift
//

class CategoryPostHistoryCell: CollectionViewCell {
    static let reuseIdentifier = "CategoryPostHistoryCell"
    struct Size {
        static let height: CGFloat = 30
        static let iconSpacing: CGFloat = 5
        static let textOffsetY: CGFloat = 4
        static let leftMargin: CGFloat = 10
    }

    enum Label {
        case featuredByIn(User, Category)
        case featuredBy(User)
        case postedInto(Category)
        case addedToBy(Category, User)
    }

    var labels: [Label] = [] {
        didSet { updateLabels() }
    }

    private let icon = UIImageView(image: InterfaceImage.arrowRight.normalImage)
    private let label = UILabel()

    override func prepareForReuse() {
        super.prepareForReuse()
        labels = []
    }

    override func style() {
        label.numberOfLines = 1
        label.baselineAdjustment = .alignCenters
        contentView.backgroundColor = .white
    }

    override func arrange() {
        contentView.addSubview(icon)
        contentView.addSubview(label)

        icon.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(Size.leftMargin)
            make.centerY.equalTo(contentView)
        }

        label.snp.makeConstraints { make in
            make.leading.equalTo(icon.snp.trailing).offset(Size.iconSpacing)
            make.firstBaseline.equalTo(contentView.snp.centerY).offset(Size.textOffsetY)
        }
    }

    private func updateLabels() {
        var first = true
        let attributedText = NSMutableAttributedString()
        for label in labels {
            if !first {
                attributedText.append(NSAttributedString(label: ". ", style: .smallGray))
            }
            first = false

            switch label {
            case let .featuredByIn(user, category):
                attributedText.append(NSAttributedString(label: InterfaceString.Post.FeaturedBy + " ", style: .smallGray))
                attributedText.append(NSAttributedString(label: user.atName, style: .smallGrayUnderlined))
                attributedText.append(NSAttributedString(label: " in ", style: .smallGray))
                attributedText.append(NSAttributedString(label: category.name, style: .smallGrayUnderlined))
            case let .featuredBy(user):
                attributedText.append(NSAttributedString(label: InterfaceString.Post.FeaturedBy + " ", style: .smallGray))
                attributedText.append(NSAttributedString(label: user.atName, style: .smallGrayUnderlined))
            case let .postedInto(category):
                attributedText.append(NSAttributedString(label: InterfaceString.Post.PostedInto + " ", style: .smallGray))
                attributedText.append(NSAttributedString(label: category.name, style: .smallGrayUnderlined))
            case let .addedToBy(category, user):
                attributedText.append(NSAttributedString(label: InterfaceString.Post.AddedTo + " ", style: .smallGray))
                attributedText.append(NSAttributedString(label: category.name, style: .smallGrayUnderlined))
                attributedText.append(NSAttributedString(label: " by ", style: .smallGray))
                attributedText.append(NSAttributedString(label: user.atName, style: .smallGrayUnderlined))
            }
        }
        label.attributedText = attributedText
    }
}
