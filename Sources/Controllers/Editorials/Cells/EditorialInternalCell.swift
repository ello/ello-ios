////
///  EditorialInternalCell.swift
//

class EditorialInternalCell: EditorialTitledCell {

    override func arrange() {
        super.arrange()

        subtitleWebView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(editorialContentView).inset(Size.defaultMargin)
            // make.trailing.lessThanOrEqualTo(editorialContentView).inset(Size.defaultMargin).priority(Priority.required)
            subtitleHeightConstraint = make.height.equalTo(0).constraint
        }
    }
}
