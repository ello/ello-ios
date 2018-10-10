////
///  TextHeaderCell.swift
//

class TextHeaderCell: CollectionViewCell {
    static let reuseIdentifier = "TextHeaderCell"
    struct Size {
        static let insets: CGFloat = 10
    }

    private let headerLabel = UILabel()

    var header: NSAttributedString? {
        get { return headerLabel.attributedText }
        set { headerLabel.attributedText = newValue }
    }

    override func style() {
        backgroundColor = UIColor.white
        headerLabel.numberOfLines = 0
    }

    override func arrange() {
        contentView.addSubview(headerLabel)

        headerLabel.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentView)
            make.leading.trailing.equalTo(contentView).inset(Size.insets)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        header = nil
    }

}
