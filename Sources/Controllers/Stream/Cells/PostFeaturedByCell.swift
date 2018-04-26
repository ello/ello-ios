////
///  PostFeaturedByCell.swift
//

class PostFeaturedByCell: CollectionViewCell {
    static let reuseIdentifier = "PostFeaturedByCell"
    struct Size {
        static let height: CGFloat = 40
        static let spacing: CGFloat = 5
        static let bgInsets = UIEdgeInsets(bottom: 1)
    }

    var text: String? {
        get { return label.text }
        set { label.text = newValue }
    }

    private let bg = UIView()
    private let label = StyledLabel(style: .gray)

    override func style() {
        bg.backgroundColor = .greyF2
    }

    override func arrange() {
        contentView.addSubview(bg)
        contentView.addSubview(label)

        bg.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(Size.bgInsets)
        }

        label.snp.makeConstraints { make in
            make.center.equalTo(contentView)
        }
    }
}
