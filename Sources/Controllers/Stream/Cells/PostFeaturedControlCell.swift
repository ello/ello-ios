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

    override var isSelected: Bool {
        didSet {
            icon.isSelected = isSelected
            label.text = isSelected ? InterfaceString.Post.Featured : InterfaceString.Post.Feature
        }
    }

    override func style() {
        bg.backgroundColor = .greyF2
        icon.setImages(.badgeFeatured)
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
