////
///  EditorialSponsoredCell.swift
//

class EditorialSponsoredCell: EditorialTitledCell {
    let advertisingLabel = StyledButton(style: .greenPill)

    override func style() {
        super.style()
    }

    override func bindActions() {
        super.bindActions()
    }

    override func updateConfig() {
        super.updateConfig()
    }

    override func setText() {
        super.setText()
        advertisingLabel.title = InterfaceString.Editorials.Advertising
    }

    override func arrange() {
        super.arrange()

        contentView.addSubview(advertisingLabel)

        advertisingLabel.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(editorialContentView).inset(Size.defaultMargin)
        }

        subtitleWebView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(editorialContentView).inset(Size.defaultMargin)
            subtitleHeightConstraint = make.height.equalTo(0).constraint
        }
    }
}
