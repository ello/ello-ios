////
///  CollectionViewCell.swift
//

class CollectionViewCell: UICollectionViewCell {
    convenience init() {
        self.init(frame: .default)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        style()
        bindActions()
        setText()
        arrange()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
        style()
        bindActions()
        setText()
        arrange()
    }

    override func traitCollectionDidChange(_ prev: UITraitCollection?) {
        super.traitCollectionDidChange(prev)
        style()
    }

    func setup() {}
    func style() {}
    func bindActions() {}
    func setText() {}
    func arrange() {}
}
