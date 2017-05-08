////
///  EditorialCell.swift
//

import SnapKit


class EditorialCell: UICollectionViewCell {
    static let reuseIdentifier = "EditorialCell"

    struct Size {
        static let aspect: CGFloat = 1
    }

    struct Config {
        init() {}
    }

    var config = Config() {
        didSet {
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        bindActions()
        arrange()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func style() {
    }

    func bindActions() {
    }

    func arrange() {
    }

}

extension EditorialCell {

    override func prepareForReuse() {
        config = Config()
    }
}
