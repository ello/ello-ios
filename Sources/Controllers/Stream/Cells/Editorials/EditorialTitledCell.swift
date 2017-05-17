////
///  EditorialTitledCell.swift
//

class EditorialTitledCell: EditorialCell {

    fileprivate let titleLabel = StyledLabel(style: .giantWhite)

    override func style() {
        super.style()
        titleLabel.numberOfLines = 0
    }

    override func bindActions() {
    }

    override func updateConfig() {
        super.updateConfig()
        titleLabel.text = config.title
    }

    override func arrange() {
        contentView.addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(Size.topMargin)
            make.leading.trailing.equalTo(contentView).inset(Size.defaultMargin)
        }
    }

}
