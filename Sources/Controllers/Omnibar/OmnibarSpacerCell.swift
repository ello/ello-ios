////
///  OmnibarSpacerCell.swift
//

class OmnibarSpacerCell: TableViewCell {
    static let reuseIdentifier = "OmnibarSpacerCell"

    override func styleCell() {
        backgroundColor = .white
        contentView.backgroundColor = .white
    }
}
