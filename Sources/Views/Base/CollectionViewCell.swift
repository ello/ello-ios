////
///  CollectionViewCell.swift
//

class CollectionViewCell: UICollectionViewCell {
    private var didInit = false
    convenience init() {
        self.init(frame: .default)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        didInit = true
        setup()
        style()
        bindActions()
        setText()
        arrange()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        didInit = true
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

    override func addSubview(_ view: UIView) {
        if didInit {
            print("should not add \(view) to self - add it to contentView")
        }
        super.addSubview(view)
    }
}
