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
        styleCell()
        bindActions()
        setText()
        arrange()
        layoutIfNeeded()
    }

    func styleCell() {}
    func bindActions() {}
    func setText() {}
    func arrange() {}
}
