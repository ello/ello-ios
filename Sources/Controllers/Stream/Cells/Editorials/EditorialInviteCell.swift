////
///  EditorialInviteCell.swift
//

class EditorialInviteCell: EditorialCell {
    fileprivate let subtitleLabel = StyledLabel(style: .largeWhite)

    override func style() {
        super.style()

        subtitleLabel.numberOfLines = 0
    }

    override func bindActions() {
        super.bindActions()
    }

    override func updateConfig() {
        super.updateConfig()

        subtitleLabel.text = config.subtitle
    }

    override func arrange() {
        super.arrange()

        contentView.addSubview(subtitleLabel)

        subtitleLabel.snp.makeConstraints { make in
            make.leading.bottom.equalTo(contentView).inset(Size.defaultMargin)
            make.trailing.lessThanOrEqualTo(contentView).inset(Size.defaultMargin).priority(Priority.required)
        }
    }
}
