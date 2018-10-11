////
///  EditorialExternalCell.swift
//

class EditorialExternalCell: EditorialTitledCell {

    override func arrange() {
        super.arrange()

        subtitleWebView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(editorialContentView).inset(Size.defaultMargin)
            subtitleHeightConstraint = make.height.equalTo(0).constraint
        }
    }
}
