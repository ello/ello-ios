////
///  TableViewCell.swift
//

class TableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier id: String?) {
        super.init(style: style, reuseIdentifier: id)
        styleCell()
        bindActions()
        setText()
        arrange()
        layoutIfNeeded()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        styleCell()
        bindActions()
        setText()
        arrange()
        layoutIfNeeded()
    }

    override func traitCollectionDidChange(_ prev: UITraitCollection?) {
        super.traitCollectionDidChange(prev)
        styleCell()
    }

    func styleCell() {}
    func bindActions() {}
    func setText() {}
    func arrange() {}
}
