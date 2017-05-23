////
///  EditorialTitledCell.swift
//

class EditorialTitledCell: EditorialCell {
    let titleLabel = StyledLabel(style: .giantWhite)
    let subtitleLabel = StyledLabel(style: .largeWhite)

    override func style() {
        super.style()
        titleLabel.numberOfLines = 0
        subtitleLabel.numberOfLines = 0
    }

    override func bindActions() {
    }

    override func updateConfig() {
        super.updateConfig()
        titleLabel.text = config.title
        subtitleLabel.text = config.subtitle
    }

    override func arrange() {
        super.arrange()

        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(Size.topMargin)
            make.leading.trailing.equalTo(contentView).inset(Size.defaultMargin)
        }
    }

}
