////
///  PostedInCategoryCell.swift
//

class PostedInCategoryCell: CollectionViewCell {
    static let reuseIdentifier = "PostedInCategoryCell"
    struct Size {
        static let height: CGFloat = 40
        static let iconSpacing: CGFloat = 5
        static let textSpacing: CGFloat = 3
        static let textOffsetY: CGFloat = 1
        static let leftMargin: CGFloat = 10
    }

    var category: Category? {
        didSet {
            categoryLabel.text = category.map { $0.name } ?? "???"
        }
    }

    private let icon = UIImageView(image: InterfaceImage.arrowRight.normalImage)
    private let postedInLabel = StyledLabel(style: .smallGray)
    private let categoryLabel = StyledLabel(style: .smallGrayUnderlined)

    override func prepareForReuse() {
        super.prepareForReuse()
        category = nil
    }

    override func setText() {
        postedInLabel.text = InterfaceString.Post.PostedIn
    }

    override func style() {
        contentView.backgroundColor = .white
    }

    override func arrange() {
        contentView.addSubview(icon)
        contentView.addSubview(postedInLabel)
        contentView.addSubview(categoryLabel)

        icon.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(Size.leftMargin)
            make.centerY.equalTo(contentView)
        }

        postedInLabel.snp.makeConstraints { make in
            make.leading.equalTo(icon.snp.trailing).offset(Size.iconSpacing)
            make.centerY.equalTo(contentView).offset(Size.textOffsetY)
        }

        categoryLabel.snp.makeConstraints { make in
            make.leading.equalTo(postedInLabel.snp.trailing).offset(Size.textSpacing)
            make.centerY.equalTo(contentView).offset(Size.textOffsetY)
        }
    }
}
