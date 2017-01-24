////
///  TextHeaderCell.swift
//

class TextHeaderCell: UICollectionViewCell {
    static let reuseIdentifier = "TextHeaderCell"
    struct Size {
        static let insets: CGFloat = 10
    }

    fileprivate let headerLabel = UILabel()

    var header: NSAttributedString? {
        get { return headerLabel.attributedText }
        set { headerLabel.attributedText = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white

        style()
        arrange()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func style() {
        headerLabel.numberOfLines = 0
    }

    fileprivate func arrange() {
        addSubview(headerLabel)

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
