////
///  EditorialExternalCell.swift
//

class EditorialExternalCell: EditorialTitledCell {

    override func style() {
        super.style()
    }

    override func bindActions() {
        super.bindActions()
    }

    override func updateConfig() {
        super.updateConfig()
    }

    override func arrange() {
        super.arrange()

        subtitleLabel.snp.makeConstraints { make in
            make.leading.bottom.equalTo(contentView).inset(Size.defaultMargin)
            make.trailing.lessThanOrEqualTo(contentView).inset(Size.defaultMargin).priority(Priority.required)
        }
    }
}
