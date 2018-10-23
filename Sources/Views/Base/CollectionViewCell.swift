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
        style()
        bindActions()
        setText()
        arrange()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        didInit = true
        style()
        bindActions()
        setText()
        arrange()
    }

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
