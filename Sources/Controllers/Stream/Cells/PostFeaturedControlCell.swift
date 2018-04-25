////
///  PostFeaturedControlCell.swift
//

class PostFeaturedControlCell: CollectionViewCell {
    static let reuseIdentifier = "PostFeaturedControlCell"
    struct Size {
        static let height: CGFloat = 40
        static let spacing: CGFloat = 5
        static let bgInsets = UIEdgeInsets(bottom: 1)
    }

    private let bg = UIView()
    private let icon = UIButton()
    private let label = StyledLabel(style: .gray)

    var isFeatured: Bool {
        get { return icon.isSelected }
        set {
            icon.isSelected = newValue
            label.text = newValue ? InterfaceString.Post.Featured : InterfaceString.Post.Feature
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        isFeatured = false
    }

    override func style() {
        bg.backgroundColor = .greyF2
        icon.setImages(.badgeFeatured)
        icon.isUserInteractionEnabled = false
        label.text = InterfaceString.Post.Feature
    }

    override func arrange() {
        contentView.addSubview(bg)
        contentView.addSubview(icon)
        contentView.addSubview(label)

        let centerLayoutGuide = UILayoutGuide()
        contentView.addLayoutGuide(centerLayoutGuide)

        bg.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(Size.bgInsets)
        }

        icon.snp.makeConstraints { make in
            make.leading.centerY.equalTo(centerLayoutGuide)
        }

        label.snp.makeConstraints { make in
            make.trailing.centerY.equalTo(centerLayoutGuide)
            make.leading.equalTo(icon.snp.trailing).offset(Size.spacing)
        }

        centerLayoutGuide.snp.makeConstraints { make in
            make.center.equalTo(contentView)
        }
    }
}
